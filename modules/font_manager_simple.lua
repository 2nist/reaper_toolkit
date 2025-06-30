-- Simple Font Manager - Focus on working font loading
-- Based on ReaImGui best practices for REAPER environment

local M = {}

-- Simple font state
local current_font_instance = nil
local current_size = 14
local fonts_dir = ""

-- Available fonts and sizes
local available_fonts = {
    { name = "Default", family = "default", path = nil },
    { name = "Sans Serif", family = "sans-serif", path = nil },
    { name = "Monospace", family = "monospace", path = nil }
}

local font_sizes = { 8, 10, 12, 14, 16, 18, 20, 24, 28, 32 }

function M.init()
    if reaper then
        fonts_dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper-master/fonts/"
        -- Ensure fonts directory exists
        if reaper.RecursiveCreateDirectory then
            reaper.RecursiveCreateDirectory(fonts_dir, 1)
        end
    else
        fonts_dir = "./fonts/"
    end
    
    M.scan_custom_fonts()
    print("Simple font manager initialized")
end

function M.scan_custom_fonts()
    -- Reset custom fonts (keep first 3 system fonts)
    local system_count = 3
    while #available_fonts > system_count do
        table.remove(available_fonts)
    end
    
    if not reaper then return end
    
    -- Scan for TTF and OTF files
    local i = 0
    while true do
        local file = reaper.EnumerateFiles(fonts_dir, i)
        if not file then break end
        
        local ext = file:match("%.([^%.]+)$")
        if ext and (ext:lower() == "ttf" or ext:lower() == "otf") then
            local font_name = file:gsub("%..*$", "") -- Remove extension
            local font_path = fonts_dir .. file
            
            table.insert(available_fonts, {
                name = font_name,
                family = "custom",
                path = font_path
            })
            print("Found custom font:", font_name)
        end
        i = i + 1
    end
end

function M.get_available_fonts()
    return available_fonts
end

function M.get_font_sizes()
    return font_sizes
end

function M.get_current_font()
    -- Return first font and current size as defaults
    return available_fonts[1], current_size
end

function M.set_current_font(font_info, size)
    current_size = size or 14
    print("Set current font:", font_info.name, "size:", current_size)
    
    -- Don't actually load fonts yet - just save the selection
    -- This prevents errors while we debug the font loading
end

function M.load_font(font_info, size, ctx)
    if not reaper or not ctx then
        print("Font loading requires REAPER and context")
        return nil
    end
    
    print("Font load request:", font_info.name, "size:", size)
    
    -- Try to create font if it's a custom font with a path
    if font_info.path and reaper.ImGui_CreateFont then
        local font_instance = reaper.ImGui_CreateFont(font_info.path, size)
        if font_instance then
            print("✅ Font created:", font_info.name)
            
            -- Try to attach font to context
            if reaper.ImGui_Attach then
                local ok, err = pcall(reaper.ImGui_Attach, ctx, font_instance)
                if ok then
                    print("✅ Font attached:", font_info.name)
                    return font_instance
                else
                    print("❌ Font attachment failed:", err)
                end
            else
                print("❌ ImGui_Attach function not available")
            end
        else
            print("❌ Font creation failed:", font_info.name)
        end
    else
        print("ℹ️ System font or no path - using default font:", font_info.name)
    end
    
    return nil -- Use default font
end

function M.use_font(ctx, font_instance, draw_function)
    if not font_instance or not reaper.ImGui_PushFont or not ctx then
        -- Use default font
        print("Using default font")
        if draw_function then 
            draw_function() 
        end
        return
    end
    
    -- Try to use the custom font
    local ok, err = pcall(reaper.ImGui_PushFont, ctx, font_instance)
    if ok then
        print("✅ Font pushed successfully")
        if draw_function then
            draw_function()
        end
        -- Pop the font
        local pop_ok, pop_err = pcall(reaper.ImGui_PopFont, ctx)
        if not pop_ok then
            print("❌ Font pop failed:", pop_err)
        end
    else
        print("❌ Font push failed:", err)
        -- Fallback to default font
        if draw_function then 
            draw_function() 
        end
    end
end

function M.install_font(file_path)
    if not file_path or file_path == "" then
        return false, "No file path provided"
    end
    
    local file_name = file_path:match("([^/\\]+)$") or "unknown.ttf"
    local ext = file_name:match("%.([^%.]+)$")
    
    if not ext or (ext:lower() ~= "ttf" and ext:lower() ~= "otf") then
        return false, "File must be TTF or OTF format"
    end
    
    local dest_path = fonts_dir .. file_name
    
    -- Copy file to fonts directory
    local success = false
    if reaper then
        -- Try using REAPER's file operations if available
        local source_file = io.open(file_path, "rb")
        if source_file then
            local content = source_file:read("*all")
            source_file:close()
            
            local dest_file = io.open(dest_path, "wb")
            if dest_file then
                dest_file:write(content)
                dest_file:close()
                success = true
            end
        end
    end
    
    if success then
        M.scan_custom_fonts() -- Refresh font list
        return true, "Font installed successfully: " .. file_name
    else
        return false, "Failed to copy font file"
    end
end

function M.export_font_list()
    local font_list = "Available Fonts:\n"
    for i, font in ipairs(available_fonts) do
        font_list = font_list .. i .. ". " .. font.name .. 
                   (font.path and " (Custom)" or " (System)") .. "\n"
    end
    
    if reaper and reaper.ImGui_SetClipboardText then
        -- This might not work - ReaImGui clipboard functions vary
        print("Font list:", font_list)
    end
    
    return font_list
end

function M.get_fonts_directory()
    return fonts_dir
end

return M
