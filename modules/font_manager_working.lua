-- Working Font Manager for REAPER DevToolbox
-- Based on ReaImGui documentation and working examples

local M = {}

-- Font registry and state
local font_instances = {}
local current_font_name = "Default"
local current_size = 14
local fonts_dir = ""

-- Available fonts and sizes
local available_fonts = {
    { name = "Default", family = "default", path = nil },
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
        print("Font manager initialized with REAPER, fonts dir:", fonts_dir)
    else
        fonts_dir = "./fonts/"
        print("Font manager initialized without REAPER")
    end
    
    M.scan_custom_fonts()
end

function M.scan_custom_fonts()
    -- Reset to system fonts only
    available_fonts = {
        { name = "Default", family = "default", path = nil },
        { name = "Monospace", family = "monospace", path = nil }
    }
    
    if not reaper then 
        print("Cannot scan fonts without REAPER")
        return 
    end
    
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
            print("Found custom font:", font_name, "at", font_path)
        end
        i = i + 1
    end
    
    print("Font scan complete. Total fonts:", #available_fonts)
end

function M.get_available_fonts()
    return available_fonts
end

function M.get_font_sizes()
    return font_sizes
end

function M.get_current_font()
    -- Find current font in available fonts
    for _, font in ipairs(available_fonts) do
        if font.name == current_font_name then
            return font, current_size
        end
    end
    return available_fonts[1], current_size
end

function M.set_current_font(font_info, size)
    if font_info then
        current_font_name = font_info.name
        print("Set current font to:", current_font_name)
    end
    if size then
        current_size = size
        print("Set current size to:", current_size)
    end
end

-- Create font instance for ReaImGui
function M.load_font(font_info, size, ctx)
    if not reaper or not ctx then
        print("Font loading requires REAPER and context")
        return nil
    end
    
    local cache_key = (font_info.name or "default") .. "_" .. size
    
    -- Check if we already have this font loaded
    if font_instances[cache_key] then
        print("Using cached font:", cache_key)
        return font_instances[cache_key]
    end
    
    local font_instance = nil
    
    if font_info.path and font_info.path ~= "" then
        -- Try to load custom font from file
        print("Attempting to load custom font:", font_info.path, "size:", size)
        
        -- Try different ReaImGui font creation methods
        if reaper.ImGui_CreateFont then
            local ok, result = pcall(reaper.ImGui_CreateFont, font_info.path, size)
            if ok and result then
                font_instance = result
                print("✅ Custom font created with ImGui_CreateFont")
            else
                print("❌ ImGui_CreateFont failed:", result)
            end
        end
        
        -- Alternative method if available
        if not font_instance and reaper.ImGui_CreateFontFromFile then
            local ok, result = pcall(reaper.ImGui_CreateFontFromFile, font_info.path, size)
            if ok and result then
                font_instance = result
                print("✅ Custom font created with ImGui_CreateFontFromFile")
            else
                print("❌ ImGui_CreateFontFromFile failed:", result)
            end
        end
    else
        print("System font requested:", font_info.name, "- using default")
        -- For system fonts, we'll return nil to use default
        -- ReaImGui doesn't support loading system fonts by name
    end
    
    -- Try to attach font to context if we have one
    if font_instance then
        if reaper.ImGui_Attach then
            local ok, err = pcall(reaper.ImGui_Attach, ctx, font_instance)
            if ok then
                print("✅ Font attached to context successfully")
                font_instances[cache_key] = font_instance
            else
                print("❌ Font attachment failed:", err)
                font_instance = nil
            end
        else
            print("⚠️ ImGui_Attach not available - font may not work")
            font_instances[cache_key] = font_instance
        end
    end
    
    return font_instance
end

-- Use font with proper push/pop
function M.use_font(ctx, font_instance, draw_function)
    if not ctx or not draw_function then
        if draw_function then draw_function() end
        return
    end
    
    if font_instance and reaper.ImGui_PushFont then
        -- Try to push the font
        local ok, err = pcall(reaper.ImGui_PushFont, ctx, font_instance)
        if ok then
            draw_function()
            if reaper.ImGui_PopFont then
                pcall(reaper.ImGui_PopFont, ctx)
            end
        else
            print("Font push failed:", err)
            draw_function() -- Use default font
        end
    else
        -- No font or no push function - use default
        draw_function()
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
    print("Installing font from:", file_path, "to:", dest_path)
    
    -- Copy file to fonts directory
    local success = false
    if reaper then
        local source_file = io.open(file_path, "rb")
        if source_file then
            local content = source_file:read("*all")
            source_file:close()
            
            local dest_file = io.open(dest_path, "wb")
            if dest_file then
                dest_file:write(content)
                dest_file:close()
                success = true
                print("✅ Font file copied successfully")
            else
                print("❌ Failed to write destination file")
            end
        else
            print("❌ Failed to read source file")
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
    print("Font list exported:", font_list)
    return font_list
end

function M.get_fonts_directory()
    return fonts_dir
end

-- Debug function to check ReaImGui font functions
function M.check_font_api()
    if not reaper then
        print("❌ REAPER not available")
        return
    end
    
    print("=== ReaImGui Font API Check ===")
    local font_functions = {
        "ImGui_CreateFont",
        "ImGui_CreateFontFromFile", 
        "ImGui_Attach",
        "ImGui_PushFont",
        "ImGui_PopFont"
    }
    
    for _, func_name in ipairs(font_functions) do
        if reaper[func_name] then
            print("✅", func_name, "available")
        else
            print("❌", func_name, "not available")
        end
    end
    print("================================")
end

return M
