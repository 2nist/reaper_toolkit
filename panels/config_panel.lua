-- /scripts/config_panel.lua
-- Configuration panel for the DevToolbox

local M = {}

local theme_manager -- will be loaded in init
local font_manager -- will be loaded in init

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
    end
    
    -- Load font manager for font configuration
    local font_manager_paths = {
        'font_manager_working',      -- New working version
        'font_manager_simple',       
        'font_manager_v2',
        'font_manager',
        'modules/font_manager_working',
        'modules/font_manager_simple',
        'modules/font_manager_v2',
        'modules/font_manager',
        '../modules/font_manager_working',
        '../modules/font_manager_simple',
        '../modules/font_manager_v2',
        '../modules/font_manager'
    }
    
    for _, path in ipairs(font_manager_paths) do
        local ok_font, fm = pcall(require, path)
        if ok_font then
            font_manager = fm
            local init_ok, init_err = pcall(font_manager.init)
            if init_ok then
                print("Font manager loaded successfully from:", path)
                break
            else
                print("Font manager init error:", init_err)
            end
        else
            print("Font manager load attempt failed for path:", path, "Error:", fm)
        end
    end
    
    -- If require failed, try direct dofile approach
    if not font_manager then
        local script_path = debug.getinfo(1,'S').source:match("@?(.*)")
        if script_path then
            local script_dir = script_path:match("(.*/)")
            if script_dir then
                local font_manager_files = {
                    script_dir .. "../modules/font_manager_working.lua",
                    script_dir .. "../modules/font_manager_simple.lua",
                    script_dir .. "../modules/font_manager_v2.lua", 
                    script_dir .. "../modules/font_manager.lua"
                }
                
                for _, font_manager_file in ipairs(font_manager_files) do
                    print("Trying dofile approach:", font_manager_file)
                    local ok_dofile, fm = pcall(dofile, font_manager_file)
                    if ok_dofile and fm then
                        font_manager = fm
                        local init_ok, init_err = pcall(font_manager.init)
                        if init_ok then
                            print("Font manager loaded via dofile:", font_manager_file)
                            break
                        else
                            print("Font manager dofile init error:", init_err)
                            font_manager = nil
                        end
                    else
                        print("Dofile failed for", font_manager_file, ":", fm)
                    end
                end
            end
        end
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
        
        -- Check ReaImGui font API availability
        if font_manager.check_font_api then
            font_manager.check_font_api()
        end
    else
        print("Font manager could not be loaded from any path")
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
        
        -- Font Selection
        local fonts = font_manager.get_available_fonts()
        local font_names_string = ""
        for i, font in ipairs(fonts) do
            font_names_string = font_names_string .. font.name
            if i < #fonts then
                font_names_string = font_names_string .. "\0"
            end
        end
        -- Add final null terminator
        if #fonts > 0 then
            font_names_string = font_names_string .. "\0"
        end
        
        local changed_font = false
        if #fonts > 0 then
            changed_font, selected_font_index = ImGui.Combo(ctx, "Font Family", selected_font_index - 1, font_names_string)
            selected_font_index = selected_font_index + 1 -- Convert back to 1-based indexing
        end
        
        -- Font Size Selection
        local sizes = font_manager.get_font_sizes()
        local size_names_string = ""
        for i, size in ipairs(sizes) do
            size_names_string = size_names_string .. tostring(size) .. "px"
            if i < #sizes then
                size_names_string = size_names_string .. "\0"
            end
        end
        -- Add final null terminator
        if #sizes > 0 then
            size_names_string = size_names_string .. "\0"
        end
        
        local changed_size = false
        if #sizes > 0 then
            changed_size, selected_size_index = ImGui.Combo(ctx, "Font Size", selected_size_index - 1, size_names_string)
            selected_size_index = selected_size_index + 1 -- Convert back to 1-based indexing
        end
        
        -- Apply font changes
        if (changed_font or changed_size) and fonts[selected_font_index] and sizes[selected_size_index] then
            font_manager.set_current_font(fonts[selected_font_index], sizes[selected_size_index])
            status_message = "✅ Font settings saved!"
            status_timer = 180 -- Show for 3 seconds at 60fps
        end
        
        ImGui.Spacing(ctx)
        
        -- Font preview
        if fonts[selected_font_index] and sizes[selected_size_index] then
            ImGui.Text(ctx, "Preview:")
            ImGui.SameLine(ctx)
            
            -- Debug info
            local selected_font = fonts[selected_font_index]
            local selected_size = sizes[selected_size_index]
            print("Font preview attempt:", selected_font.name, "size:", selected_size)
            
            -- Try to create and apply the selected font for preview
            local preview_font = font_manager.load_font(selected_font, selected_size, ctx)
            if preview_font then
                print("Preview font loaded successfully")
                font_manager.use_font(ctx, preview_font, function()
                    ImGui.Text(ctx, "The quick brown fox jumps over the lazy dog 🦊")
                end)
            else
                print("Preview font failed - using default")
                ImGui.Text(ctx, "Font preview: " .. selected_font.name .. " @ " .. selected_size .. "px")
                ImGui.Text(ctx, "The quick brown fox jumps over the lazy dog 🦊")
            end
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
                local success, message = font_manager.install_font(font_path_buffer)
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

return M
