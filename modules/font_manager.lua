-- Font Manager Module for DevToolbox
-- Handles font loading, selection, and custom TTF integration

local M = {}

-- Font configuration storage
local font_config = {
    current_font = nil,
    current_font_size = 14,
    custom_fonts = {},
    system_fonts = {
        { name = "Default", family = "sans-serif" },
        { name = "Sans Serif", family = "sans-serif" },
        { name = "Serif", family = "serif" },
        { name = "Monospace", family = "monospace" },
        { name = "Cursive", family = "cursive" },
        { name = "Fantasy", family = "fantasy" }
    },
    font_sizes = { 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 28, 32, 36, 48 }
}

-- Storage paths
local fonts_dir = ""
local config_file = ""

function M.init()
    -- Check if we're running in REAPER
    if not reaper then
        -- Running outside REAPER - use fallback paths
        fonts_dir = "./fonts/"
        config_file = "./font_config.lua"
        
        -- Create fonts directory if it doesn't exist
        os.execute("mkdir -p " .. fonts_dir)
    else
        -- Running in REAPER - use proper paths
        fonts_dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper-master/fonts/"
        config_file = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper-master/font_config.lua"
        
        -- Ensure fonts directory exists
        reaper.RecursiveCreateDirectory(fonts_dir, 1)
    end
    
    -- Load saved font configuration
    M.load_config()
    
    -- Scan for custom TTF files
    M.scan_custom_fonts()
end

function M.scan_custom_fonts()
    font_config.custom_fonts = {}
    
    if reaper and reaper.EnumerateFiles then
        -- Use REAPER's file enumeration
        local i = 0
        local file_info = reaper.EnumerateFiles(fonts_dir, i)
        
        while file_info do
            local file_name = file_info
            local file_path = fonts_dir .. file_name
            
            -- Check for TTF and OTF files
            if file_name:match("%.ttf$") or file_name:match("%.otf$") then
                local font_name = file_name:gsub("%.ttf$", ""):gsub("%.otf$", "")
                font_name = font_name:gsub("_", " "):gsub("-", " ")
                -- Capitalize first letter of each word
                font_name = font_name:gsub("(%w)(%w*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                
                table.insert(font_config.custom_fonts, {
                    name = font_name .. " (Custom)",
                    path = file_path,
                    filename = file_name
                })
            end
            
            i = i + 1
            file_info = reaper.EnumerateFiles(fonts_dir, i)
        end
    else
        -- Fallback: scan directory manually (for testing outside REAPER)
        local command = ""
        if os.getenv("OS") and os.getenv("OS"):find("Windows") then
            command = 'dir "' .. fonts_dir .. '*.ttf" /b /a-d 2>nul && dir "' .. fonts_dir .. '*.otf" /b /a-d 2>nul'
        else
            command = 'ls "' .. fonts_dir .. '"*.ttf "' .. fonts_dir .. '"*.otf 2>/dev/null'
        end
        
        local handle = io.popen(command)
        if handle then
            for line in handle:lines() do
                local file_name = line:match("([^/\\]+)$") -- Get just the filename
                if file_name and (file_name:match("%.ttf$") or file_name:match("%.otf$")) then
                    local font_name = file_name:gsub("%.ttf$", ""):gsub("%.otf$", "")
                    font_name = font_name:gsub("_", " "):gsub("-", " ")
                    font_name = font_name:gsub("(%w)(%w*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end)
                    
                    table.insert(font_config.custom_fonts, {
                        name = font_name .. " (Custom)",
                        path = fonts_dir .. file_name,
                        filename = file_name
                    })
                end
            end
            handle:close()
        end
    end
end

function M.get_available_fonts()
    local fonts = {}
    
    -- Add system fonts
    for _, font in ipairs(font_config.system_fonts) do
        table.insert(fonts, font)
    end
    
    -- Add custom fonts
    for _, font in ipairs(font_config.custom_fonts) do
        table.insert(fonts, font)
    end
    
    return fonts
end

function M.get_font_sizes()
    return font_config.font_sizes
end

function M.create_font(font_info, size, ctx)
    local font_instance = nil
    
    -- Only create actual font instances when running in REAPER
    if reaper and reaper.ImGui_CreateFont then
        if font_info.path then
            -- Custom font from file
            font_instance = reaper.ImGui_CreateFont(font_info.path, size)
        else
            -- System font family
            font_instance = reaper.ImGui_CreateFont(font_info.family, size)
        end
        
        if font_instance and ctx and reaper.ImGui_AttachFont then
            reaper.ImGui_AttachFont(ctx, font_instance)
        end
    end
    
    return font_instance
end

function M.set_current_font(font_info, size)
    font_config.current_font = font_info
    font_config.current_font_size = size
    M.save_config()
end

function M.get_current_font()
    return font_config.current_font, font_config.current_font_size
end

function M.install_ttf_from_path(file_path)
    if not file_path or file_path == "" then
        return false, "No file path provided"
    end
    
    -- Check if file exists
    local file_exists = false
    if reaper and reaper.file_exists then
        file_exists = reaper.file_exists(file_path)
    else
        -- Fallback file existence check
        local f = io.open(file_path, "r")
        if f then
            f:close()
            file_exists = true
        end
    end
    
    if not file_exists then
        return false, "Font file does not exist"
    end
    
    -- Check if it's a font file
    local ext = file_path:match("%.([^%.]+)$")
    if not (ext and (ext:lower() == "ttf" or ext:lower() == "otf")) then
        return false, "File must be a .ttf or .otf font file"
    end
    
    -- Get filename
    local filename = file_path:match("([^/\\]+)$")
    local destination = fonts_dir .. filename
    
    -- Check if already exists
    local dest_exists = false
    if reaper and reaper.file_exists then
        dest_exists = reaper.file_exists(destination)
    else
        local f = io.open(destination, "r")
        if f then
            f:close()
            dest_exists = true
        end
    end
    
    if dest_exists then
        return false, "Font file already exists: " .. filename
    end
    
    -- Copy file to fonts directory (manual copy since CF_CopyFile requires SWS extension)
    local source_file = io.open(file_path, "rb")
    if not source_file then
        return false, "Failed to open source font file"
    end
    
    local content = source_file:read("*all")
    source_file:close()
    
    local dest_file = io.open(destination, "wb")
    if not dest_file then
        return false, "Failed to create destination font file"
    end
    
    dest_file:write(content)
    dest_file:close()
    
    -- Rescan custom fonts
    M.scan_custom_fonts()
    
    return true, "Font installed successfully: " .. filename
end

function M.remove_custom_font(font_info)
    if not font_info.path then
        return false, "Not a custom font"
    end
    
    -- Delete the font file
    local success = os.remove(font_info.path)
    if success then
        -- Rescan custom fonts
        M.scan_custom_fonts()
        return true, "Font removed successfully"
    else
        return false, "Failed to remove font file"
    end
end

function M.save_config()
    local config_text = "-- DevToolbox Font Configuration\nreturn {\n"
    
    if font_config.current_font then
        config_text = config_text .. "  current_font = {\n"
        config_text = config_text .. "    name = " .. string.format("%q", font_config.current_font.name) .. ",\n"
        
        if font_config.current_font.family then
            config_text = config_text .. "    family = " .. string.format("%q", font_config.current_font.family) .. ",\n"
        end
        
        if font_config.current_font.path then
            config_text = config_text .. "    path = " .. string.format("%q", font_config.current_font.path) .. ",\n"
        end
        
        if font_config.current_font.filename then
            config_text = config_text .. "    filename = " .. string.format("%q", font_config.current_font.filename) .. ",\n"
        end
        
        config_text = config_text .. "  },\n"
    end
    
    config_text = config_text .. "  current_font_size = " .. font_config.current_font_size .. ",\n"
    config_text = config_text .. "}\n"
    
    local file = io.open(config_file, "w")
    if file then
        file:write(config_text)
        file:close()
    end
end

function M.load_config()
    local file_exists = false
    if reaper and reaper.file_exists then
        file_exists = reaper.file_exists(config_file)
    else
        local f = io.open(config_file, "r")
        if f then
            f:close()
            file_exists = true
        end
    end
    
    if file_exists then
        local ok, config = pcall(dofile, config_file)
        if ok and config then
            if config.current_font then
                font_config.current_font = config.current_font
            end
            if config.current_font_size then
                font_config.current_font_size = config.current_font_size
            end
        end
    end
end

function M.get_fonts_directory()
    return fonts_dir
end

function M.export_font_list(ctx)
    local fonts = M.get_available_fonts()
    local export_text = "DevToolbox Available Fonts:\n\n"
    
    export_text = export_text .. "System Fonts:\n"
    for _, font in ipairs(font_config.system_fonts) do
        export_text = export_text .. "- " .. font.name .. " (" .. font.family .. ")\n"
    end
    
    export_text = export_text .. "\nCustom Fonts:\n"
    for _, font in ipairs(font_config.custom_fonts) do
        export_text = export_text .. "- " .. font.name .. " (" .. font.filename .. ")\n"
    end
    
    export_text = export_text .. "\nCurrent Selection:\n"
    if font_config.current_font then
        export_text = export_text .. "Font: " .. font_config.current_font.name .. "\n"
        export_text = export_text .. "Size: " .. font_config.current_font_size .. "px\n"
    else
        export_text = export_text .. "Using default font\n"
    end
    
    -- Copy to clipboard if context provided  
    if ctx then
        -- Use the same ImGui metatable approach as main.lua
        local ImGui = setmetatable({}, {
            __index = function(t, k)
                local fn = reaper["ImGui_" .. k]
                if fn then return fn end
                return rawget(t, k)
            end
        })
        
        if ImGui.SetClipboardText then
            ImGui.SetClipboardText(ctx, export_text)
        end
    end
    return export_text
end

-- Test function to verify font loading works
function M.test_font(font_info, size)
    if not reaper or not reaper.ImGui_CreateContext then
        return true, "Font test skipped (not in REAPER environment)"
    end
    
    local test_ctx = reaper.ImGui_CreateContext()
    if not test_ctx then
        return false, "Failed to create test context"
    end
    
    local font_instance = M.create_font(font_info, size, test_ctx)
    
    if font_instance then
        reaper.ImGui_DestroyContext(test_ctx)
        return true, "Font loaded successfully"
    else
        reaper.ImGui_DestroyContext(test_ctx)
        return false, "Failed to load font"
    end
end

return M
