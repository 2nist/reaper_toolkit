-- Enhanced Font Manager with ReaImGui Best Practices
-- Based on official ReaImGui font loading guide

local M = {}

-- Font registry to track loaded fonts
local font_registry = {}
local fonts_dir = ""
local config_file = ""

-- Current font state for persistence
local current_font = nil
local current_size = 14

-- Available system fonts and sizes
local system_fonts = {
    { name = "Sans Serif", family = "sans-serif" },
    { name = "Serif", family = "serif" }, 
    { name = "Monospace", family = "monospace" },
    { name = "Cursive", family = "cursive" },
    { name = "Fantasy", family = "fantasy" }
}

local font_sizes = { 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 28, 32, 36, 48 }

function M.init()
    if reaper then
        fonts_dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper-master/fonts/"
        config_file = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper-master/font_config.lua"
        
        -- Ensure fonts directory exists
        if reaper.RecursiveCreateDirectory then
            reaper.RecursiveCreateDirectory(fonts_dir, 1)
        end
    else
        -- Fallback for testing
        fonts_dir = "./fonts/"
        config_file = "./font_config.lua"
    end
    
    M.scan_custom_fonts()
    print("Font manager initialized - fonts dir:", fonts_dir)
end

function M.scan_custom_fonts()
    -- Reset custom fonts list
    for i = #system_fonts + 1, #font_registry do
        font_registry[i] = nil
    end
    
    -- Start with system fonts
    font_registry = {}
    for _, font in ipairs(system_fonts) do
        table.insert(font_registry, font)
    end
    
    -- Add custom fonts from fonts directory
    if reaper and reaper.EnumerateFiles then
        local i = 0
        while true do
            local file = reaper.EnumerateFiles(fonts_dir, i)
            if not file then break end
            
            if file:match("%.ttf$") or file:match("%.otf$") then
                local name = file:gsub("%.[^%.]+$", "") -- Remove extension
                table.insert(font_registry, {
                    name = name,
                    filename = file,
                    path = fonts_dir .. file
                })
            end
            i = i + 1
        end
    end
    
    print("Scanned fonts - found", #font_registry, "total fonts")
end

function M.get_available_fonts()
    return font_registry
end

function M.get_font_sizes()
    return font_sizes
end

-- Get current font configuration
function M.get_current_font()
    return current_font, current_size
end

-- Set current font configuration
function M.set_current_font(font_info, size)
    current_font = font_info
    current_size = size
    
    -- Save to config file if possible
    if config_file and config_file ~= "" then
        local config_content = string.format([[
-- Font configuration
return {
    font_name = %q,
    font_family = %q,
    font_path = %q,
    font_size = %d
}
]], font_info.name or "", font_info.family or "", font_info.path or "", size)
        
        local file = io.open(config_file, "w")
        if file then
            file:write(config_content)
            file:close()
            print("Font configuration saved:", font_info.name, "@", size .. "px")
        end
    end
end

-- Get fonts directory path
function M.get_fonts_directory()
    return fonts_dir
end

-- Create and attach font following ReaImGui best practices
function M.load_font(font_info, size, ctx)
    if not reaper or not ctx then
        print("Font loading failed: No REAPER or context")
        return nil
    end
    
    local font_instance = nil
    
    -- Try different ReaImGui font creation approaches
    if font_info.path then
        -- Load custom font from file path
        if reaper.ImGui_CreateFont then
            font_instance = reaper.ImGui_CreateFont(font_info.path, size)
        end
    else
        -- For system fonts, we might need a different approach
        -- Some versions of ReaImGui don't support generic family names
        print("System font loading not fully supported, using default")
        return nil
    end
    
    -- Attach font to context if successfully created
    if font_instance then
        local attach_ok = false
        
        -- Try different attachment methods
        if reaper.ImGui_Attach then
            local ok, err = pcall(reaper.ImGui_Attach, ctx, font_instance)
            if ok then
                attach_ok = true
                print("Font attached with ImGui_Attach:", font_info.name, "size:", size)
            else
                print("ImGui_Attach failed:", err)
            end
        end
        
        -- If attachment failed, the font might not be usable
        if not attach_ok then
            print("Warning: Font created but not attached:", font_info.name)
            -- Still return the font instance - it might work in some contexts
        end
    else
        print("Font creation failed for:", font_info.name, "size:", size)
    end
    
    return font_instance
end

-- Safe font usage with push/pop pattern
function M.use_font(ctx, font_instance, draw_function)
    if not font_instance or not reaper.ImGui_PushFont or not ctx then
        -- Fallback to default font
        if draw_function then draw_function() end
        return
    end
    
    -- Try to push the font - this will fail if font is not attached to context
    local push_ok, push_err = pcall(reaper.ImGui_PushFont, ctx, font_instance)
    if not push_ok then
        print("Font push failed (font not attached?):", push_err)
        -- Fallback to default font
        if draw_function then draw_function() end
        return
    end
    
    -- Execute the drawing function with the font active
    if draw_function then
        local ok, err = pcall(draw_function)
        if not ok then
            print("Font drawing error:", err)
        end
    end
    
    -- Always pop the font to maintain stack balance
    reaper.ImGui_PopFont(ctx)
end

-- Install TTF/OTF font file
function M.install_font(file_path)
    if not file_path or file_path == "" then
        return false, "No file path provided"
    end
    
    if not fonts_dir or fonts_dir == "" then
        return false, "Fonts directory not initialized"
    end
    
    local filename = file_path:match("([^/\\]+)$")
    local destination = fonts_dir .. filename
    
    -- Check if already exists
    if reaper and reaper.file_exists and reaper.file_exists(destination) then
        return false, "Font file already exists: " .. filename
    end
    
    -- Manual file copy
    local source = io.open(file_path, "rb")
    if not source then
        return false, "Cannot read source font file"
    end
    
    local content = source:read("*all")
    source:close()
    
    local dest = io.open(destination, "wb")
    if not dest then
        return false, "Cannot write to fonts directory"
    end
    
    dest:write(content)
    dest:close()
    
    -- Rescan fonts after installation
    M.scan_custom_fonts()
    
    return true, "Font installed successfully: " .. filename
end

-- Export font list for debugging
function M.export_font_list()
    local list = "Available Fonts:\n\n"
    
    for i, font in ipairs(font_registry) do
        list = list .. i .. ". " .. font.name
        if font.family then
            list = list .. " (family: " .. font.family .. ")"
        end
        if font.path then
            list = list .. " (file: " .. font.filename .. ")"
        end
        list = list .. "\n"
    end
    
    list = list .. "\nAvailable sizes: " .. table.concat(font_sizes, ", ") .. "\n"
    
    return list
end

return M
