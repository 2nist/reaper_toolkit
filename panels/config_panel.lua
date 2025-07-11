-- /scripts/config_panel.lua
-- Configuration panel for the DevToolbox

local M = {}

local theme_manager -- will be loaded in init
local font_manager -- will be loaded in init
local script_manager -- will be loaded in init
local console_logger -- will be loaded in init

-- UI state variables
local selected_font_index = 1
local selected_size_index = 8 -- Default to 14px (index 8 in the sizes array)
local font_path_buffer = ""
local status_message = ""
local status_timer = 0

function M.init()
    print("Config panel init started")
    print("Current working directory:", reaper and reaper.GetResourcePath() or "Not in REAPER")
    
    -- Load theme manager for global theming support
    local ok, tm = pcall(require, 'theme_manager')
    if ok then
        theme_manager = tm
        theme_manager.init()
        print("Theme manager loaded successfully")
    else
        print("Theme manager failed to load:", tm)
    end
    
    -- Load font manager for font configuration
    print("Attempting to load font manager...")
    local ok_font, fm = pcall(require, 'font_manager')
    if ok_font and fm then
        font_manager = fm
        print("Font manager module loaded, attempting init...")
        local init_ok, init_err = pcall(font_manager.init)
        if init_ok then
            print("✅ Font manager loaded and initialized successfully")
            
            -- Test basic functionality
            local fonts_ok, fonts = pcall(font_manager.get_available_fonts)
            if fonts_ok and fonts then
                print("✅ Found", #fonts, "available fonts")
            else
                print("❌ Failed to get available fonts:", fonts)
            end
        else
            print("❌ Font manager init error:", init_err)
            font_manager = nil
        end
    else
        print("❌ Font manager failed to load:", fm)
        font_manager = nil
    end
    
    if font_manager then
        -- Initialize font selection from saved config
        local current_font, current_size = font_manager.get_current_font()
        if current_font then
            local fonts = font_manager.get_available_fonts()
            for i, font in ipairs(fonts) do
                if font.name == current_font.name then
                    selected_font_index = i
                    break
                end
            end
            
            local sizes = font_manager.get_font_sizes()
            for i, size in ipairs(sizes) do
                if size == current_size then
                    selected_size_index = i
                    break
                end
            end
        end
        
        print("Config panel initialization complete")
    else
        print("Font manager could not be loaded from any path")
    end
    
    -- Load script manager for live reload functionality
    print("Attempting to load script manager...")
    local ok_script, sm = pcall(require, 'script_manager')
    if ok_script and sm then
        script_manager = sm
        print("✅ Script manager loaded successfully")
    else
        print("❌ Script manager failed to load:", sm)
        script_manager = nil
    end
    
    -- Load console logger for diagnostics
    print("Attempting to load console logger...")
    local ok_console, cl = pcall(require, 'console_logger')
    if ok_console and cl then
        console_logger = cl
        print("✅ Console logger loaded successfully")
    else
        print("❌ Console logger failed to load:", cl)
        -- Create a fallback logger
        console_logger = {
            log = function(msg) print("[LOG] " .. tostring(msg)) end,
            clear = function() end,
            get_messages = function() return {} end
        }
    end
end

function M.draw(ctx)
    local ImGui
    if reaper and reaper.ImGui_CreateContext then
      ImGui = setmetatable({}, {
        __index = function(t, k)
          local fn = reaper["ImGui_" .. k]
          if fn then return fn end
          return rawget(t, k)
        end
      })
    else
      ImGui = require 'imgui' '0.9.2'
    end
    
    -- Don't apply theme in child window context to avoid stack issues
    -- Theme colors are inherited from the parent window automatically
    local colors_pushed = 0
    
    -- Use themed text and buttons
    if theme_manager then
        theme_manager.themed_text(ctx, ImGui, "Global Toolbox Configuration")
    else
        ImGui.Text(ctx, "Global Toolbox Configuration")
    end
    
    ImGui.Separator(ctx)
    
    -- Theme Status Section
    if theme_manager then
        theme_manager.themed_text(ctx, ImGui, "Theme System:")
        ImGui.SameLine(ctx)
        if theme_manager.is_theming_available() then
            ImGui.TextColored(ctx, 0x00FF00FF, "✅ Active")
        else
            ImGui.TextColored(ctx, 0xFF0000FF, "❌ Not Available")
        end
        
        ImGui.Spacing(ctx)
        
        if theme_manager.themed_button(ctx, ImGui, "Reload Theme System") then
            theme_manager.reload()
        end
        
        ImGui.Separator(ctx)
    end
    
    -- Configuration Options
    ImGui.Text(ctx, "Configuration Options:")
    
    -- Font Configuration Section
    if font_manager then
        ImGui.Spacing(ctx)
        if theme_manager then
            theme_manager.themed_text(ctx, ImGui, "🔤 Font Configuration:")
        else
            ImGui.Text(ctx, "🔤 Font Configuration:")
        end
        
        ImGui.Separator(ctx)
        
        -- Font Selection with better error handling
        local fonts = {}
        local fonts_ok, fonts_err = pcall(font_manager.get_available_fonts)
        if fonts_ok and fonts_err then
            fonts = fonts_err
        else
            fonts = {
                { name = "Default ImGui", family = "default", description = "Built-in ImGui font" },
                { name = "System Default", family = "system", description = "System default font" }
            }
            if not fonts_ok then
                status_message = "⚠️ Font loading issue: " .. tostring(fonts_err)
                status_timer = 300
            end
        end
        
        if #fonts > 0 then
            local font_names_string = ""
            for i, font in ipairs(fonts) do
                font_names_string = font_names_string .. font.name
                if i < #fonts then
                    font_names_string = font_names_string .. "\0"
                end
            end
            -- Add final null terminator
            font_names_string = font_names_string .. "\0"
            
            local changed_font, new_font_index = ImGui.Combo(ctx, "Font Family", selected_font_index - 1, font_names_string)
            if changed_font then
                selected_font_index = new_font_index + 1 -- Convert back to 1-based indexing
            end
        else
            ImGui.Text(ctx, "❌ No fonts available")
        end
        
        -- Font Size Selection with better layout
        local sizes = {}
        local sizes_ok, sizes_err = pcall(font_manager.get_font_sizes)
        if sizes_ok and sizes_err then
            sizes = sizes_err
        else
            sizes = { 8, 9, 10, 11, 12, 13, 14, 16, 18, 20, 22, 24, 28, 32 }
        end
        
        if #sizes > 0 then
            local size_names_string = ""
            for i, size in ipairs(sizes) do
                size_names_string = size_names_string .. tostring(size) .. "px"
                if i < #sizes then
                    size_names_string = size_names_string .. "\0"
                end
            end
            -- Add final null terminator
            size_names_string = size_names_string .. "\0"
            
            local changed_size, new_size_index = ImGui.Combo(ctx, "Font Size", selected_size_index - 1, size_names_string)
            if changed_size then
                selected_size_index = new_size_index + 1 -- Convert back to 1-based indexing
            end
        else
            ImGui.Text(ctx, "❌ No font sizes available")
        end
        
        -- Apply font changes with better validation
        if (changed_font or changed_size) and fonts[selected_font_index] and sizes[selected_size_index] then
            local selected_font = fonts[selected_font_index]
            local selected_size = sizes[selected_size_index]
            
            local save_ok, save_err = pcall(font_manager.set_current_font, selected_font, selected_size)
            if save_ok then
                status_message = "✅ Font settings saved: " .. selected_font.name .. " @ " .. selected_size .. "px"
                status_timer = 180
            else
                status_message = "❌ Failed to save font: " .. tostring(save_err)
                status_timer = 300
            end
        end
        
        ImGui.Spacing(ctx)
        
        -- Font preview with live testing
        if fonts[selected_font_index] and sizes[selected_size_index] then
            ImGui.Spacing(ctx)
            ImGui.Text(ctx, "Font Preview:")
            ImGui.Separator(ctx)
            
            local selected_font = fonts[selected_font_index]
            local selected_size = sizes[selected_size_index]
            
            -- Font information display
            ImGui.BulletText(ctx, "Name: " .. selected_font.name)
            ImGui.BulletText(ctx, "Size: " .. selected_size .. "px")
            if selected_font.description then
                ImGui.BulletText(ctx, "Type: " .. selected_font.description)
            end
            if selected_font.path then
                ImGui.BulletText(ctx, "Source: Custom font file")
                ImGui.BulletText(ctx, "Path: " .. selected_font.path)
            else
                ImGui.BulletText(ctx, "Source: System font")
            end
            
            ImGui.Spacing(ctx)
            
            -- Live font preview
            ImGui.Text(ctx, "Preview Text:")
            local preview_text = "The quick brown fox jumps over the lazy dog 🦊\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789 !@#$%^&*()"
            
            -- Simple preview without font switching to avoid attachment issues
            ImGui.TextWrapped(ctx, preview_text)
            
            -- Show font status without actually switching fonts
            if selected_font.path then
                -- Test font loading capability without using it
                local font_test_ok, font_message = font_manager.test_font_creation(selected_font, selected_size)
                if font_test_ok then
                    ImGui.TextColored(ctx, 0x00FF00FF, "✅ " .. font_message)
                else
                    ImGui.TextColored(ctx, 0xFF8800FF, "⚠️ " .. font_message)
                end
            else
                ImGui.TextColored(ctx, 0x888888FF, "ℹ️ System font (rendered with default font)")
            end
            
            ImGui.Spacing(ctx)
            
            -- Test button for font functionality using safe testing
            if ImGui.Button(ctx, "🧪 Test Font Loading") then
                local test_ok, test_message = font_manager.test_font_creation(selected_font, selected_size)
                if test_ok then
                    status_message = "✅ " .. test_message
                else
                    status_message = "❌ " .. test_message
                end
                status_timer = 300
            end
        end
        
        ImGui.Spacing(ctx)
        
        -- Advanced font management and diagnostics
        ImGui.Separator(ctx)
        ImGui.Text(ctx, "🔧 Advanced Tools:")
        
        if ImGui.Button(ctx, "📊 System Diagnostics") then
            console_logger.log("=== FONT SYSTEM DIAGNOSTICS ===")
            console_logger.log("REAPER available: " .. tostring(reaper ~= nil))
            if reaper then
                console_logger.log("REAPER version: " .. (reaper.GetAppVersion() or "Unknown"))
                console_logger.log("ImGui_CreateFont available: " .. tostring(reaper.ImGui_CreateFont ~= nil))
                console_logger.log("ImGui_CreateContext available: " .. tostring(reaper.ImGui_CreateContext ~= nil))
            end
            console_logger.log("Font manager loaded: " .. tostring(font_manager ~= nil))
            if font_manager then
                local cache_info = font_manager.get_cache_info()
                console_logger.log("Font cache entries: " .. tostring(cache_info.count))
                console_logger.log("Fonts directory: " .. tostring(font_manager.get_fonts_directory()))
            end
            console_logger.log("Current working directory: " .. (reaper and reaper.GetResourcePath() or "Unknown"))
            console_logger.log("===============================")
            status_message = "📊 Diagnostics logged to console"
            status_timer = 180
        end
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "🧹 Clear Font Cache") then
            if font_manager and font_manager.clear_font_cache then
                local cleared = font_manager.clear_font_cache()
                status_message = "🧹 Font cache cleared (" .. cleared .. " items)"
                status_timer = 180
            else
                status_message = "❌ Font cache clear not available"
                status_timer = 180
            end
        end
        
        -- Live reload test
        ImGui.Spacing(ctx)
        if ImGui.Button(ctx, "🔄 Test Live Reload") then
            if script_manager and script_manager.reload_scripts_live then
                script_manager.reload_scripts_live()
                status_message = "🔄 Live reload executed"
                status_timer = 180
            else
                status_message = "❌ Live reload not available"
                status_timer = 180
            end
        end
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "📋 Copy Debug Info") then
            local debug_info = "DevToolbox Debug Info:\n"
            debug_info = debug_info .. "- REAPER: " .. tostring(reaper ~= nil) .. "\n"
            if reaper then
                debug_info = debug_info .. "- REAPER Version: " .. (reaper.GetAppVersion() or "Unknown") .. "\n"
            end
            debug_info = debug_info .. "- Font Manager: " .. tostring(font_manager ~= nil) .. "\n"
            debug_info = debug_info .. "- Script Manager: " .. tostring(script_manager ~= nil) .. "\n"
            debug_info = debug_info .. "- Available Fonts: " .. #fonts .. "\n"
            debug_info = debug_info .. "- Available Sizes: " .. #sizes .. "\n"
            
            ImGui.SetClipboardText(ctx, debug_info)
            status_message = "📋 Debug info copied to clipboard"
            status_timer = 180
        end
        
        ImGui.Spacing(ctx)
        
        -- Custom Font Installation
        ImGui.Text(ctx, "📁 Install Custom Font:")
        
        local path_changed = false
        path_changed, font_path_buffer = ImGui.InputText(ctx, "TTF/OTF File Path", font_path_buffer, 512)
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Browse...") then
            local file_path = reaper.GetUserFileNameForRead("", "Select Font File", "ttf,otf")
            if file_path and file_path ~= "" then
                font_path_buffer = tostring(file_path)
            end
        end
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Install Font") then
            if font_path_buffer and font_path_buffer ~= "" then
                local success, message = font_manager.install_ttf_from_path(font_path_buffer)
                status_message = success and ("✅ " .. message) or ("❌ " .. message)
                status_timer = 300 -- Show for 5 seconds
                
                if success then
                    font_path_buffer = ""
                    -- Refresh font list
                    fonts = font_manager.get_available_fonts()
                end
            else
                status_message = "❌ Please select a font file first"
                status_timer = 180
            end
        end
        
        ImGui.Spacing(ctx)
        
        -- Font Management Buttons
        ImGui.Text(ctx, "🛠️ Font Management:")
        
        if ImGui.Button(ctx, "Export Font List") then
            font_manager.export_font_list(ctx)
            status_message = "📋 Font list copied to clipboard"
            status_timer = 180
        end
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Open Fonts Folder") then
            local fonts_dir = font_manager.get_fonts_directory()
            -- Use reaper.ShowInFolder or fallback to system command
            if reaper.CF_ShellExecute then
                reaper.CF_ShellExecute(fonts_dir)
            else
                -- Fallback for systems without SWS extension
                local command = ""
                if reaper.GetOS():find("Win") then
                    command = 'explorer "' .. fonts_dir .. '"'
                elseif reaper.GetOS():find("OSX") then
                    command = 'open "' .. fonts_dir .. '"'
                else
                    command = 'xdg-open "' .. fonts_dir .. '"'
                end
                os.execute(command)
            end
        end
        
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Refresh Fonts") then
            font_manager.scan_custom_fonts()
            fonts = font_manager.get_available_fonts()
            status_message = "🔄 Font list refreshed"
            status_timer = 180
        end
        
        -- Remove custom font option
        if fonts[selected_font_index] and fonts[selected_font_index].path then
            ImGui.Spacing(ctx)
            if ImGui.Button(ctx, "🗑️ Remove Selected Custom Font") then
                local success, message = font_manager.remove_custom_font(fonts[selected_font_index])
                status_message = success and ("✅ " .. message) or ("❌ " .. message)
                status_timer = 300
                
                if success then
                    fonts = font_manager.get_available_fonts()
                    selected_font_index = math.min(selected_font_index, #fonts)
                end
            end
        end
        
        ImGui.Spacing(ctx)
        ImGui.Separator(ctx)
    else
        ImGui.BulletText(ctx, "Font manager not available")
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "🔄 Retry Loading") then
            -- Try to reload font manager
            M.init()
        end
    end
    
    -- Other Configuration Options
    ImGui.Text(ctx, "📋 Other Options:")
    ImGui.BulletText(ctx, "Window layout preferences") 
    ImGui.BulletText(ctx, "Tool auto-loading")
    ImGui.BulletText(ctx, "Debug logging levels")
    
    -- Basic font configuration fallback if font manager isn't available
    if not font_manager then
        ImGui.Spacing(ctx)
        ImGui.Text(ctx, "🔤 Basic Font Configuration:")
        ImGui.Separator(ctx)
        
        local font_families = {"sans-serif", "serif", "monospace", "cursive", "fantasy"}
        local font_sizes = {8, 10, 12, 14, 16, 18, 20, 24, 28, 32}
        
        -- Simple font family selection
        selected_font_index = selected_font_index or 1
        local changed_font, new_font_index = ImGui.Combo(ctx, "Font Family", selected_font_index - 1, table.concat(font_families, "\0"))
        if changed_font then
            selected_font_index = new_font_index + 1
            status_message = "✅ Font family selection saved!"
            status_timer = 180
        end
        
        -- Simple font size selection  
        selected_size_index = selected_size_index or 8
        local size_strings = {}
        for _, size in ipairs(font_sizes) do
            table.insert(size_strings, tostring(size) .. "px")
        end
        local changed_size, new_size_index = ImGui.Combo(ctx, "Font Size", selected_size_index - 1, table.concat(size_strings, "\0"))
        if changed_size then
            selected_size_index = new_size_index + 1
            status_message = "✅ Font size selection saved!"
            status_timer = 180
        end
        
        ImGui.Spacing(ctx)
        ImGui.Text(ctx, "Selected: " .. font_families[selected_font_index] .. " @ " .. font_sizes[selected_size_index] .. "px")
        ImGui.Text(ctx, "📝 Note: Advanced font features require font manager")
        
        ImGui.Spacing(ctx)
        ImGui.Separator(ctx)
    end
    
    -- Status Messages
    if status_message ~= "" and status_timer > 0 then
        ImGui.Spacing(ctx)
        ImGui.TextColored(ctx, 0x00FF00FF, status_message)
        status_timer = status_timer - 1
        if status_timer <= 0 then
            status_message = ""
        end
    end
    
    ImGui.Spacing(ctx)
    ImGui.Text(ctx, "🚧 More configuration options coming soon...")
    
    -- No theme cleanup needed since we're not applying themes in child windows
end

function M.shutdown()
end

-- Tool metadata
M.metadata = {
    label = "Config Panel",
    icon = "⚙",
    category = "Configuration",
    active = true
}

return M
