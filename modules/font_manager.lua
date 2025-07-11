-- Font Manager Module for DevToolbox
-- Handles font loading, selection, and custom TTF integration

local M = {}

-- Font configuration storage
local font_config = {
    current_font = nil,
    current_font_size = 14,
    custom_fonts = {},
    system_fonts = {
        { name = "Default ImGui", family = "default", description = "Built-in ImGui font" },
        { name = "Arial", family = "Arial", description = "System Arial font" },
        { name = "Calibri", family = "Calibri", description = "System Calibri font" },
        { name = "Consolas", family = "Consolas", description = "System Consolas monospace font" },
        { name = "Courier New", family = "Courier New", description = "System Courier New monospace font" },
        { name = "Georgia", family = "Georgia", description = "System Georgia serif font" },
        { name = "Helvetica", family = "Helvetica", description = "System Helvetica font" },
        { name = "Impact", family = "Impact", description = "System Impact font" },
        { name = "Lucida Console", family = "Lucida Console", description = "System Lucida Console monospace font" },
        { name = "Segoe UI", family = "Segoe UI", description = "System Segoe UI font" },
        { name = "Tahoma", family = "Tahoma", description = "System Tahoma font" },
        { name = "Times New Roman", family = "Times New Roman", description = "System Times New Roman serif font" },
        { name = "Trebuchet MS", family = "Trebuchet MS", description = "System Trebuchet MS font" },
        { name = "Verdana", family = "Verdana", description = "System Verdana font" }
    },
    font_sizes = { 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 28, 32, 36, 48 }
}

-- Font instance cache to prevent excessive font creation
local font_cache = {}

-- Storage paths
local fonts_dir = ""
local config_file = ""

function M.init()
    -- Clear any existing font cache to prevent issues
    font_cache = {}
    
    -- Check if we're running in REAPER
    if not reaper then
        -- Running outside REAPER - use fallback paths
        fonts_dir = "./fonts/"
        config_file = "./font_config.lua"
        
        -- Create fonts directory if it doesn't exist
        os.execute("mkdir -p " .. fonts_dir)
    else
        -- Running in REAPER - determine script path dynamically
        local info = debug.getinfo(1, 'S')
        local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
        if script_path then
            -- Go up one level from modules to get the base path
            script_path = script_path:gsub("modules[/\\]?$", "")
            fonts_dir = script_path .. "fonts/"
            config_file = script_path .. "font_config.lua"
        else
            -- Fallback to the old path structure
            fonts_dir = reaper.GetResourcePath() .. "/Scripts/reaper_toolkit-1/fonts/"
            config_file = reaper.GetResourcePath() .. "/Scripts/reaper_toolkit-1/font_config.lua"
        end
        
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
            command = 'dir "' .. fonts_dir:gsub("/", "\\") .. '*.ttf" /b 2>nul'
        else
            command = 'ls "' .. fonts_dir .. '"*.ttf 2>/dev/null'
        end
        
        local handle = io.popen(command)
        if handle then
            for line in handle:lines() do
                local file_name = line:match("([^/\\]+)$") or line -- Get just the filename or use whole line
                if file_name and file_name:match("%.ttf$") then
                    local font_name = file_name:gsub("%.ttf$", "")
                    -- Better name formatting
                    font_name = font_name:gsub("_", " "):gsub("-", " ")
                    
                    -- Special cases for known fonts
                    if font_name:lower():find("firacode") then
                        font_name = "Fira Code"
                    elseif font_name:lower():find("jetbrainsmono") then
                        font_name = "JetBrains Mono"
                    elseif font_name:lower():find("sourcecodepro") then
                        font_name = "Source Code Pro"
                    elseif font_name:lower():find("robotomono") then
                        font_name = "Roboto Mono"
                    elseif font_name:lower():find("opensans") then
                        font_name = "Open Sans"
                    else
                        -- General capitalization
                        font_name = font_name:gsub("(%w)(%w*)", function(first, rest)
                            return first:upper() .. rest:lower()
                        end)
                    end
                    
                    table.insert(font_config.custom_fonts, {
                        name = font_name .. " (TTF)",
                        path = fonts_dir .. file_name,
                        filename = file_name
                    })
                end
            end
            handle:close()
        end
        
        -- Also scan for OTF files
        if os.getenv("OS") and os.getenv("OS"):find("Windows") then
            command = 'dir "' .. fonts_dir:gsub("/", "\\") .. '*.otf" /b 2>nul'
        else
            command = 'ls "' .. fonts_dir .. '"*.otf 2>/dev/null'
        end
        
        handle = io.popen(command)
        if handle then
            for line in handle:lines() do
                local file_name = line:match("([^/\\]+)$") or line -- Get just the filename or use whole line
                if file_name and file_name:match("%.otf$") then
                    local font_name = file_name:gsub("%.otf$", "")
                    -- Better name formatting
                    font_name = font_name:gsub("_", " "):gsub("-", " ")
                    
                    -- Special cases for known fonts
                    if font_name:lower():find("firacode") then
                        font_name = "Fira Code"
                    elseif font_name:lower():find("jetbrainsmono") then
                        font_name = "JetBrains Mono"
                    elseif font_name:lower():find("sourcecodepro") then
                        font_name = "Source Code Pro"
                    elseif font_name:lower():find("robotomono") then
                        font_name = "Roboto Mono"
                    elseif font_name:lower():find("opensans") then
                        font_name = "Open Sans"
                    else
                        -- General capitalization
                        font_name = font_name:gsub("(%w)(%w*)", function(first, rest)
                            return first:upper() .. rest:lower()
                        end)
                    end
                    
                    table.insert(font_config.custom_fonts, {
                        name = font_name .. " (OTF)",
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
    -- Create cache key for this font+size combination
    local cache_key = (font_info.path or font_info.family or font_info.name) .. "_" .. tostring(size)
    
    -- Return cached font if available
    if font_cache[cache_key] then
        return font_cache[cache_key]
    end
    
    local font_instance = nil
    
    -- Only create actual font instances when running in REAPER
    if reaper and reaper.ImGui_CreateFont then
        if font_info.path then
            -- Custom font from file
            local success, result = pcall(function()
                return reaper.ImGui_CreateFont(font_info.path, size)
            end)
            
            if success and result then
                font_instance = result
                
                -- Attach to context if provided and attachment function exists
                if ctx and reaper.ImGui_AttachFont then
                    local attach_ok, attach_err = pcall(reaper.ImGui_AttachFont, ctx, font_instance)
                    if not attach_ok then
                        -- Font created but couldn't attach - still cache it for later use
                        print("Font attachment warning: " .. tostring(attach_err))
                    end
                end
            end
        elseif font_info.family and font_info.family ~= "default" then
            -- System font family - create if possible
            local success, result = pcall(function()
                return reaper.ImGui_CreateFont(font_info.family, size)
            end)
            
            if success and result then
                font_instance = result
                
                -- Attach to context if provided
                if ctx and reaper.ImGui_AttachFont then
                    local attach_ok, attach_err = pcall(reaper.ImGui_AttachFont, ctx, font_instance)
                    if not attach_ok then
                        print("Font attachment warning: " .. tostring(attach_err))
                    end
                end
            end
        else
            -- Default font - don't create, return nil for default handling
            return nil
        end
        
        -- Cache the font instance if successfully created
        if font_instance then
            font_cache[cache_key] = font_instance
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

-- Clear font cache (useful for cleanup or troubleshooting)
function M.clear_font_cache()
    font_cache = {}
end

-- Get cache status for debugging
function M.get_cache_info()
    local count = 0
    for _ in pairs(font_cache) do
        count = count + 1
    end
    return {
        cached_fonts = count,
        cache_keys = font_cache
    }
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

-- Safe font testing function that doesn't require context attachment
function M.test_font_creation(font_info, size)
    if not font_info or not size then
        return false, "Invalid font info or size"
    end
    
    if not reaper or not reaper.ImGui_CreateFont then
        return false, "REAPER ImGui not available"
    end
    
    local success = false
    local message = ""
    
    if font_info.path then
        -- Test custom font file
        local test_ok, font_result = pcall(function()
            return reaper.ImGui_CreateFont(font_info.path, size)
        end)
        
        if test_ok and font_result then
            success = true
            message = "Custom font file loaded successfully"
            -- Clean up test font if needed
            if reaper.ImGui_DestroyFont then
                pcall(reaper.ImGui_DestroyFont, font_result)
            end
        else
            success = false
            message = "Failed to load custom font: " .. tostring(font_result)
        end
    elseif font_info.family and font_info.family ~= "default" then
        -- Test system font
        local test_ok, font_result = pcall(function()
            return reaper.ImGui_CreateFont(font_info.family, size)
        end)
        
        if test_ok and font_result then
            success = true
            message = "System font loaded successfully"
            -- Clean up test font if needed
            if reaper.ImGui_DestroyFont then
                pcall(reaper.ImGui_DestroyFont, font_result)
            end
        else
            success = false
            message = "Failed to load system font: " .. tostring(font_result)
        end
    else
        success = true
        message = "Default font (no creation needed)"
    end
    
    return success, message
end

return M
