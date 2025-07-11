-- /scripts/enhanced_theming_panel.lua
-- Enhanced theming panel based on demo.lua ShowStyleEditor

local M = {}

-- Get console logger reference
local console_logger = _G.console_logger or require('console_logger')

function M.init()
    -- Initialize the enhanced theming panel
    -- Nothing special needed for initialization
    if console_logger then
        console_logger.log("Enhanced theming panel initialized")
    end
end

-- Store colors as packed integers like ReaImGui expects (0xRRGGBBAA format)
local theme_colors = {
    background = 0x333333FF,     -- Dark gray
    text = 0xFFFFFFFF,           -- White  
    button = 0x4D4D80FF,         -- Blue-gray
    button_hovered = 0x6666B3FF, -- Lighter blue
    button_active = 0x333366FF,  -- Darker blue
}
local color_names = {"background", "text", "button", "button_hovered", "button_active"}

local presets = {
    ["Dark"] = {
        background = 0x2B2B2BFF,     -- Dark gray
        text = 0xFFFFFFFF,           -- Pure white
        button = 0x404040FF,         -- Medium gray
        button_hovered = 0x505050FF, -- Lighter gray
        button_active = 0x606060FF,  -- Even lighter gray
    },
    ["Light"] = {
        background = 0xF0F0F0FF,     -- Light gray
        text = 0x202020FF,           -- Very dark gray
        button = 0xD0D0D0FF,         -- Light button
        button_hovered = 0xE0E0E0FF, -- Very light button
        button_active = 0xC0C0C0FF,  -- Medium light button
    },
    ["Blue"] = {
        background = 0x1E3A8AFF,     -- Deep blue
        text = 0xFFFFFFFF,           -- White text
        button = 0x3B82F6FF,         -- Bright blue
        button_hovered = 0x60A5FAFF, -- Light blue
        button_active = 0x2563EBFF,  -- Medium blue
    },
    ["Green"] = {
        background = 0x064E3BFF,     -- Dark green
        text = 0xF0FDF4FF,           -- Light green tint
        button = 0x10B981FF,         -- Emerald green
        button_hovered = 0x34D399FF, -- Light emerald
        button_active = 0x059669FF,  -- Dark emerald
    },
    ["Purple"] = {
        background = 0x581C87FF,     -- Deep purple
        text = 0xFAF5FFFF,           -- Light purple tint
        button = 0x9333EAFF,         -- Bright purple
        button_hovered = 0xA855F7FF, -- Light purple
        button_active = 0x7C3AEDFF,  -- Medium purple
    },
    ["Orange"] = {
        background = 0x9A3412FF,     -- Dark orange/brown
        text = 0xFFF7EDFF,           -- Light orange tint
        button = 0xF97316FF,         -- Bright orange
        button_hovered = 0xFB923CFF, -- Light orange
        button_active = 0xEA580CFF,  -- Dark orange
    },
    ["Slate"] = {
        background = 0x0F172AFF,     -- Very dark blue-gray
        text = 0xF1F5F9FF,           -- Light gray
        button = 0x475569FF,         -- Medium slate
        button_hovered = 0x64748BFF, -- Light slate
        button_active = 0x334155FF,  -- Dark slate
    }
}

-- Conversion helpers (Lua 5.1 compatible)
local function packed_to_rgba(packed)
    local a = math.floor(packed / 16777216) % 256  -- (packed >> 24) & 0xFF
    local b = math.floor(packed / 65536) % 256     -- (packed >> 16) & 0xFF
    local g = math.floor(packed / 256) % 256       -- (packed >> 8) & 0xFF
    local r = packed % 256                         -- packed & 0xFF
    return r/255, g/255, b/255, a/255
end

local function rgba_to_packed(r, g, b, a)
    return math.floor(a*255) * 16777216 + math.floor(b*255) * 65536 + math.floor(g*255) * 256 + math.floor(r*255)  -- (a<<24) | (b<<16) | (g<<8) | r
end

-- File operations
local function save_theme()
    if not reaper then return end
    local theme_file_path = reaper.GetResourcePath() .. "/devtoolbox_theme.txt"
    local file = io.open(theme_file_path, "w")
    if file then
        for _, name in ipairs(color_names) do
            file:write(name .. "=" .. string.format("0x%08X", theme_colors[name]) .. "\n")
        end
        file:close()
        if console_logger then
            console_logger.log("INFO", "Theme saved to " .. theme_file_path)
        end
    else
        if console_logger then
            console_logger.log("ERROR", "Failed to save theme")
        end
    end
end

local function load_theme()
    if not reaper then return end
    local theme_file_path = reaper.GetResourcePath() .. "/devtoolbox_theme.txt"
    local file = io.open(theme_file_path, "r")
    if file then
        for line in file:lines() do
            local name, hex_color = line:match("([^=]+)=(.+)")
            if name and hex_color and theme_colors[name] then
                theme_colors[name] = tonumber(hex_color)
            end
        end
        file:close()
        if console_logger then
            console_logger.log("INFO", "Theme loaded from " .. theme_file_path)
        end
    else
        if console_logger then
            console_logger.log("WARNING", "No theme file found")
        end
    end
end

-- Help marker helper (from demo)
local function help_marker(ctx, ImGui, desc)
    ImGui.TextDisabled(ctx, '(?)')
    if ImGui.BeginItemTooltip(ctx) then
        local font_size = ImGui.GetFontSize(ctx)
        if type(font_size) == "number" then
            ImGui.PushTextWrapPos(ctx, font_size * 35.0)
        else
            ImGui.PushTextWrapPos(ctx, 400) -- fallback width
        end
        ImGui.Text(ctx, desc)
        ImGui.PopTextWrapPos(ctx)
        ImGui.EndTooltip(ctx)
    end
end

-- Main render function
function M.render(ctx)
    -- Use global ImGui from main.lua - this avoids the constant definition issues
    local ImGui = _G.ImGui
    if not ImGui then
        -- Debug: print to console if available
        if console_logger then
            console_logger.log("ERROR", "Enhanced theming panel: _G.ImGui not found")
        end
        return false
    end

    -- Create a separate floating window for the theming panel
    local window_flags = 0 -- WindowFlags_None
    ImGui.SetNextWindowSize(ctx, 550, 650, 4) -- Cond_FirstUseEver = 4
    ImGui.SetNextWindowPos(ctx, 200, 200, 4)  -- Cond_FirstUseEver = 4
    
    local visible, open = ImGui.Begin(ctx, 'Enhanced Theme Editor', true, window_flags)
    if not visible then
        return false -- Window was closed
    end

    ImGui.Text(ctx, "DevToolbox Advanced Theme Editor")
    ImGui.Separator(ctx)
    
    -- Theme presets section
    ImGui.Text(ctx, "Theme Presets")
    ImGui.Separator(ctx)
    
    -- Display presets in a 2x4 grid layout for better visibility
    local preset_names = {"Dark", "Light", "Blue", "Green", "Purple", "Orange", "Slate"}
    local buttons_per_row = 4
    local button_count = 0
    
    for _, preset_name in ipairs(preset_names) do
        if presets[preset_name] then
            if ImGui.Button(ctx, preset_name, 120, 0) then -- Fixed width buttons
                for name, color in pairs(presets[preset_name]) do
                    theme_colors[name] = color
                end
                if console_logger then
                    console_logger.log("INFO", "Applied " .. preset_name .. " theme")
                end
            end
            
            button_count = button_count + 1
            -- Add SameLine for first 3 buttons in each row, then NewLine
            if button_count % buttons_per_row ~= 0 then
                ImGui.SameLine(ctx)
            end
        end
    end
    ImGui.NewLine(ctx)
    
    ImGui.Separator(ctx)
    
    -- Color editing section (demo-style)
    ImGui.Text(ctx, "Color Customization")
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Click on color squares to edit colors:")
    ImGui.SameLine(ctx)
    help_marker(ctx, ImGui, "Left-click to open color picker.\nChanges apply to the main window in real-time.\nRGB values are shown in hex format for easy copying.")
    
    -- Helper function to get ImGui flags with compatibility
    local function get_imgui_flag(flag_name, fallback_value)
        local flag = ImGui[flag_name]
        if flag then
            if type(flag) == "function" then
                return flag()
            else
                return flag
            end
        end
        return fallback_value
    end

    -- Start a child window for better organization
    local child_flags = get_imgui_flag("ChildFlags_Border", 2)
    local window_flags = get_imgui_flag("WindowFlags_AlwaysVerticalScrollbar", 0x20000)
    
    if ImGui.BeginChild(ctx, "##colors", 0, 250, child_flags) then
        ImGui.PushItemWidth(ctx, ImGui.GetFontSize(ctx) * -12)
        
        for _, name in ipairs(color_names) do
            ImGui.PushID(ctx, name)
            
            -- Use packed color format for ColorEdit4
            local rv, packed_color = ImGui.ColorEdit4(ctx, "##" .. name, theme_colors[name])
            
            if rv then
                theme_colors[name] = packed_color
            end
            
            ImGui.SameLine(ctx)
            ImGui.Text(ctx, name:gsub("_", " "):upper())
            
            -- Show hex value
            ImGui.SameLine(ctx)
            local color_value = theme_colors[name] or 0
            ImGui.TextDisabled(ctx, string.format("(0x%08X)", color_value))
            
            ImGui.PopID(ctx)
        end
        
        ImGui.PopItemWidth(ctx)
        ImGui.EndChild(ctx)
    end
    
    ImGui.Separator(ctx)
    
    -- File operations section
    ImGui.Text(ctx, "Theme Management")
    ImGui.Separator(ctx)
    if ImGui.Button(ctx, "💾 Save Theme") then 
        save_theme() 
    end
    ImGui.SameLine(ctx)
    if ImGui.Button(ctx, "📁 Load Theme") then 
        load_theme() 
    end
    ImGui.SameLine(ctx)
    help_marker(ctx, ImGui, "Themes are saved to REAPER's resource directory.\nThey persist between sessions and can be shared between projects.")
    
    -- Export section
    ImGui.Separator(ctx)
    if ImGui.Button(ctx, "📋 Export to Clipboard") then
        ImGui.LogToClipboard(ctx)
        ImGui.LogText(ctx, "-- DevToolbox theme colors (copy this into your script)\n")
        ImGui.LogText(ctx, "local theme_colors = {\n")
        for _, name in ipairs(color_names) do
            ImGui.LogText(ctx, string.format("    %s = 0x%08X,\n", name, theme_colors[name]))
        end
        ImGui.LogText(ctx, "}\n")
        ImGui.LogFinish(ctx)
        if console_logger then
            console_logger.log("INFO", "Theme exported to clipboard")
        end
    end
    ImGui.SameLine(ctx)
    if ImGui.Button(ctx, "🔄 Reset to Default") then
        theme_colors = {
            background = 0x333333FF,
            text = 0xFFFFFFFF,
            button = 0x4D4D80FF,
            button_hovered = 0x6666B3FF,
            button_active = 0x333366FF,
        }
    end
    
    -- Current colors preview section
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Live Preview")
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Background:"); ImGui.SameLine(ctx)
    ImGui.ColorButton(ctx, "bg_preview", packed_to_rgba(theme_colors.background), 0x02, 40, 20) -- ColorEditFlags_AlphaBar
    
    ImGui.Text(ctx, "Text:      "); ImGui.SameLine(ctx)
    ImGui.ColorButton(ctx, "text_preview", packed_to_rgba(theme_colors.text), 0x02, 40, 20)
    
    ImGui.Text(ctx, "Button:    "); ImGui.SameLine(ctx)  
    ImGui.ColorButton(ctx, "btn_preview", packed_to_rgba(theme_colors.button), 0x02, 40, 20)
    
    -- Usage instructions
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Usage Tips")
    ImGui.Separator(ctx)
    ImGui.BulletText(ctx, "Changes are applied immediately to the main window")
    ImGui.BulletText(ctx, "Use presets for quick theme switching")
    ImGui.BulletText(ctx, "Save your custom themes for future use")
    ImGui.BulletText(ctx, "Export themes to share with others")

    ImGui.End(ctx)
    return open
end

-- Compatibility function for main.lua (original API used 'draw')
function M.draw(ctx)
    -- Enhanced theming panel using direct reaper.ImGui calls
    if not ctx then
        return false
    end
    
    -- Header
    reaper.ImGui_Text(ctx, "🎨 Enhanced Theming Panel")
    reaper.ImGui_Separator(ctx)
    
    -- Theme Presets Section
    reaper.ImGui_Text(ctx, "Theme Presets:")
    reaper.ImGui_Spacing(ctx)
    
    -- Apply preset buttons
    local preset_names = {"Dark", "Light", "Blue", "Green", "Purple", "Orange", "Slate"}
    local buttons_per_row = 4
    local button_count = 0
    
    for _, preset_name in ipairs(preset_names) do
        if reaper.ImGui_Button(ctx, preset_name, 120, 0) then -- Fixed width buttons
            if presets[preset_name] then
                for color_name, color_value in pairs(presets[preset_name]) do
                    theme_colors[color_name] = color_value
                end
                if _G.console_logger then
                    _G.console_logger.log("Applied " .. preset_name .. " theme preset")
                end
            end
        end
        
        button_count = button_count + 1
        -- Add SameLine for first 3 buttons in each row, then NewLine
        if button_count % buttons_per_row ~= 0 then
            reaper.ImGui_SameLine(ctx)
        end
    end
    
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    
    -- Color Customization Section
    reaper.ImGui_Text(ctx, "Color Customization:")
    reaper.ImGui_Spacing(ctx)
    
    -- Color editors for each theme color with simple preview
    for _, name in ipairs(color_names) do
        reaper.ImGui_Text(ctx, name:gsub("_", " "):upper() .. ":")
        reaper.ImGui_SameLine(ctx)
        local color_value = theme_colors[name] or 0xFF000000
        
        -- Show color value in hex format
        reaper.ImGui_Text(ctx, string.format("0x%08X", color_value))
        
        -- Add simple RGB display for easier reading
        local r = math.floor(color_value / 16777216) % 256  -- (color_value >> 24) & 0xFF
        local g = math.floor(color_value / 65536) % 256     -- (color_value >> 16) & 0xFF
        local b = math.floor(color_value / 256) % 256       -- (color_value >> 8) & 0xFF
        local a = color_value % 256                         -- color_value & 0xFF
        reaper.ImGui_SameLine(ctx)
        reaper.ImGui_Text(ctx, string.format("RGB(%d,%d,%d,%d)", r, g, b, a))
        
        -- Add buttons to modify colors manually
        reaper.ImGui_SameLine(ctx)
        if reaper.ImGui_Button(ctx, "Edit##" .. name) then
            -- Log current color for manual editing
            if _G.console_logger then
                _G.console_logger.log("To edit " .. name .. " color:")
                _G.console_logger.log("Current: 0x" .. string.format("%08X", color_value))
                _G.console_logger.log("Copy this to modify and use 'Load Custom' button")
            end
        end
    end
    
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Text(ctx, "Custom Theme Controls:")
    
    -- Quick color adjustment buttons
    if reaper.ImGui_Button(ctx, "Darken All") then
        for _, name in ipairs(color_names) do
            if name ~= "text" then -- Don't darken text
                local color = theme_colors[name]
                local r = math.max(0, (math.floor(color / 16777216) % 256) - 30)  -- ((color >> 24) & 0xFF) - 30
                local g = math.max(0, (math.floor(color / 65536) % 256) - 30)     -- ((color >> 16) & 0xFF) - 30
                local b = math.max(0, (math.floor(color / 256) % 256) - 30)       -- ((color >> 8) & 0xFF) - 30
                local a = color % 256                                             -- color & 0xFF
                theme_colors[name] = a * 16777216 + b * 65536 + g * 256 + r       -- (r << 24) | (g << 16) | (b << 8) | a
            end
        end
        if _G.console_logger then
            _G.console_logger.log("Darkened all colors")
        end
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Lighten All") then
        for _, name in ipairs(color_names) do
            if name ~= "text" then -- Don't lighten text
                local color = theme_colors[name]
                local r = math.min(255, (math.floor(color / 16777216) % 256) + 30)  -- ((color >> 24) & 0xFF) + 30
                local g = math.min(255, (math.floor(color / 65536) % 256) + 30)     -- ((color >> 16) & 0xFF) + 30
                local b = math.min(255, (math.floor(color / 256) % 256) + 30)       -- ((color >> 8) & 0xFF) + 30
                local a = color % 256                                               -- color & 0xFF
                theme_colors[name] = a * 16777216 + b * 65536 + g * 256 + r         -- (r << 24) | (g << 16) | (b << 8) | a
            end
        end
        if _G.console_logger then
            _G.console_logger.log("Lightened all colors")
        end
    end
    
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Separator(ctx)
    
    -- Theme Management Section
    reaper.ImGui_Text(ctx, "Theme Management:")
    reaper.ImGui_Spacing(ctx)
    
    if reaper.ImGui_Button(ctx, "Export Theme") then
        -- Enhanced export - save to clipboard and console
        local export_text = "DevToolbox Theme Export:\n"
        for name, color in pairs(theme_colors) do
            export_text = export_text .. name .. " = 0x" .. string.format("%08X", color) .. "\n"
        end
        
        -- Save to clipboard if available
        if reaper.ImGui_SetClipboardText then
            reaper.ImGui_SetClipboardText(ctx, export_text)
        end
        
        if _G.console_logger then
            _G.console_logger.log("Theme exported to clipboard:")
            _G.console_logger.log(export_text)
        end
        
        -- Also save to file for persistence
        save_theme()
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Load Custom") then
        -- Try to load custom theme template
        local custom_themes_loaded = false
        
        -- Try to load the custom theme template
        local ok, custom_themes = pcall(require, 'custom_theme_template')
        if ok and custom_themes then
            -- Show available custom themes in console
            if _G.console_logger then
                _G.console_logger.log("Available custom themes:")
                for theme_name, theme_data in pairs(custom_themes) do
                    _G.console_logger.log("  " .. theme_name)
                    -- Apply the first found custom theme
                    if not custom_themes_loaded then
                        for color_name, color_value in pairs(theme_data) do
                            if theme_colors[color_name] then
                                theme_colors[color_name] = color_value
                            end
                        end
                        _G.console_logger.log("Applied " .. theme_name .. " custom theme")
                        custom_themes_loaded = true
                    end
                end
            end
        else
            if _G.console_logger then
                _G.console_logger.log("No custom_theme_template.lua found")
                _G.console_logger.log("See custom_theme_template.lua for instructions on creating custom themes")
            end
        end
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Reset to Default") then
        -- Reset to default colors
        theme_colors.background = 0x333333FF
        theme_colors.text = 0xFFFFFFFF
        theme_colors.button = 0x4D4D80FF
        theme_colors.button_hovered = 0x6666B3FF
        theme_colors.button_active = 0x333366FF
        if _G.console_logger then
            _G.console_logger.log("Reset theme to default colors")
        end
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "🎲 Generate Random") then
        -- Generate random theme colors using HSL color space for better results
        local function hsl_to_rgb(h, s, l)
            h = h / 360
            local r, g, b
            if s == 0 then
                r, g, b = l, l, l
            else
                local function hue2rgb(p, q, t)
                    if t < 0 then t = t + 1 end
                    if t > 1 then t = t - 1 end
                    if t < 1/6 then return p + (q - p) * 6 * t end
                    if t < 1/2 then return q end
                    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
                    return p
                end
                local q = l < 0.5 and l * (1 + s) or l + s - l * s
                local p = 2 * l - q
                r = hue2rgb(p, q, h + 1/3)
                g = hue2rgb(p, q, h)
                b = hue2rgb(p, q, h - 1/3)
            end
            return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
        end
        
        -- Generate cohesive theme using HSL color space
        local base_hue = math.random() * 360
        local bg_r, bg_g, bg_b = hsl_to_rgb(base_hue, 0.3, 0.15) -- Dark background
        local text_r, text_g, text_b = hsl_to_rgb((base_hue + 180) % 360, 0.2, 0.9) -- Light contrasting text
        local btn_r, btn_g, btn_b = hsl_to_rgb(base_hue, 0.6, 0.4) -- Medium saturation button
        local btn_h_r, btn_h_g, btn_h_b = hsl_to_rgb(base_hue, 0.7, 0.5) -- Brighter hover
        local btn_a_r, btn_a_g, btn_a_b = hsl_to_rgb(base_hue, 0.8, 0.3) -- Darker active
        
        theme_colors.background = 0xFF * 16777216 + bg_b * 65536 + bg_g * 256 + bg_r    -- (bg_r << 24) | (bg_g << 16) | (bg_b << 8) | 0xFF
        theme_colors.text = 0xFF * 16777216 + text_b * 65536 + text_g * 256 + text_r      -- (text_r << 24) | (text_g << 16) | (text_b << 8) | 0xFF
        theme_colors.button = 0xFF * 16777216 + btn_b * 65536 + btn_g * 256 + btn_r        -- (btn_r << 24) | (btn_g << 16) | (btn_b << 8) | 0xFF
        theme_colors.button_hovered = 0xFF * 16777216 + btn_h_b * 65536 + btn_h_g * 256 + btn_h_r  -- (btn_h_r << 24) | (btn_h_g << 16) | (btn_h_b << 8) | 0xFF
        theme_colors.button_active = 0xFF * 16777216 + btn_a_b * 65536 + btn_a_g * 256 + btn_a_r   -- (btn_a_r << 24) | (btn_a_g << 16) | (btn_a_b << 8) | 0xFF
        
        if _G.console_logger then
            _G.console_logger.log(string.format("Random theme generated with base hue %.1f°", base_hue))
        end
    end
    
    reaper.ImGui_Spacing(ctx)
    reaper.ImGui_Text(ctx, "✨ Enhanced theming panel is now working!")
    
    return true
end

-- Embedded render function (for use within other windows)
function M.render_embedded(ctx)
    local ImGui = _G.ImGui
    if not ImGui then
        if console_logger then
            console_logger.log("ERROR: Enhanced theming panel - _G.ImGui not found")
        end
        return false
    end

    if console_logger then
        console_logger.log("Enhanced theming panel render_embedded() called")
    end

    -- Add try/catch for safety
    local success, err = pcall(function()
        ImGui.Text(ctx, "DevToolbox Advanced Theme Editor")
        ImGui.Separator(ctx)
        
        -- Theme Presets section
        ImGui.Text(ctx, "Theme Presets")
        ImGui.Separator(ctx)
        
        local preset_names = {}
        for name, _ in pairs(presets) do
            table.insert(preset_names, name)
        end
        table.sort(preset_names)
        
        for _, preset_name in ipairs(preset_names) do
            ImGui.PushID(ctx, preset_name)
            if ImGui.Button(ctx, "Apply " .. preset_name, 100) then
                for color_name, color_value in pairs(presets[preset_name]) do
                    theme_colors[color_name] = color_value
                end
                if console_logger then
                    console_logger.log("Applied theme preset: " .. preset_name)
                end
            end
            ImGui.PopID(ctx)
            ImGui.SameLine(ctx)
            ImGui.Text(ctx, preset_name .. " theme")
        end
        
        ImGui.Spacing(ctx)
        
        -- Color Customization section
        ImGui.Text(ctx, "Color Customization")
        ImGui.Separator(ctx)
    end)
    
    if not success then
        if console_logger then
            console_logger.log("ERROR in enhanced theming panel: " .. tostring(err))
        end
        -- Fallback simple content
        ImGui.Text(ctx, "Enhanced Theming Panel")
        ImGui.Text(ctx, "Error loading advanced features: " .. tostring(err))
        ImGui.Text(ctx, "Basic theming functionality available")
        return false
    end
    
    for _, name in ipairs(color_names) do
        ImGui.PushID(ctx, name)
        
        -- Color picker for each theme color
        local r, g, b, a = packed_to_rgba(theme_colors[name])
        
        -- Use ColorEdit3 instead of ColorEdit4 for simplicity, and pass color as packed integer
        local color_val = theme_colors[name] or 0xFF000000 -- Default to black
        local changed, new_color = ImGui.ColorEdit3(ctx, "##" .. name, color_val)
        if changed then
            theme_colors[name] = new_color
        end
        
        ImGui.SameLine(ctx)
        ImGui.Text(ctx, name:gsub("_", " "):upper())
        
        -- Show hex value
        ImGui.SameLine(ctx)
        local color_value = theme_colors[name] or 0
        ImGui.TextDisabled(ctx, string.format("(0x%08X)", color_value))
        
        ImGui.PopID(ctx)
    end
    
    ImGui.Spacing(ctx)
    
    -- Theme Management section  
    ImGui.Text(ctx, "Theme Management")
    ImGui.Separator(ctx)
    
    if ImGui.Button(ctx, "Export Theme to Clipboard") then
        local export_data = "-- DevToolbox Theme Export\nlocal theme = {\n"
        for _, name in ipairs(color_names) do
            export_data = export_data .. string.format("    %s = 0x%08X,\n", name, theme_colors[name])
        end
        export_data = export_data .. "}\nreturn theme"
        
        ImGui.SetClipboardText(ctx, export_data)
        if console_logger then
            console_logger.log("INFO", "Theme exported to clipboard")
        end
    end
    
    ImGui.SameLine(ctx)
    if ImGui.Button(ctx, "Reset to Default") then
        theme_colors = {
            background = 0x333333FF,
            text = 0xFFFFFFFF,
            button = 0x4D4D80FF,
            button_hovered = 0x6666B3FF,
            button_active = 0x333366FF,
        }
        if console_logger then
            console_logger.log("INFO", "Theme reset to default")
        end
    end
    
    ImGui.SameLine(ctx)
    if ImGui.Button(ctx, "🎲 Generate Random") then
        -- Generate random theme colors
        local function random_color()
            return 0xFF * 16777216 + math.random(0, 255) * 65536 + math.random(0, 255) * 256 + math.random(0, 255)  -- (r << 24) | (g << 16) | (b << 8) | 0xFF
        end
        
        -- Generate a random base color for cohesion
        local base_hue = math.random() * 360
        local function hsl_to_rgb(h, s, l)
            h = h / 360
            local r, g, b
            if s == 0 then
                r, g, b = l, l, l
            else
                local function hue2rgb(p, q, t)
                    if t < 0 then t = t + 1 end
                    if t > 1 then t = t - 1 end
                    if t < 1/6 then return p + (q - p) * 6 * t end
                    if t < 1/2 then return q end
                    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
                    return p
                end
                local q = l < 0.5 and l * (1 + s) or l + s - l * s
                local p = 2 * l - q
                r = hue2rgb(p, q, h + 1/3)
                g = hue2rgb(p, q, h)
                b = hue2rgb(p, q, h - 1/3)
            end
            return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
        end
        
        -- Generate cohesive theme using HSL color space
        local bg_r, bg_g, bg_b = hsl_to_rgb(base_hue, 0.3, 0.15) -- Dark background
        local text_r, text_g, text_b = hsl_to_rgb((base_hue + 180) % 360, 0.2, 0.9) -- Light contrasting text
        local btn_r, btn_g, btn_b = hsl_to_rgb(base_hue, 0.6, 0.4) -- Medium saturation button
        local btn_h_r, btn_h_g, btn_h_b = hsl_to_rgb(base_hue, 0.7, 0.5) -- Brighter hover
        local btn_a_r, btn_a_g, btn_a_b = hsl_to_rgb(base_hue, 0.8, 0.3) -- Darker active
        
        theme_colors = {
            background = 0xFF * 16777216 + bg_b * 65536 + bg_g * 256 + bg_r,      -- (bg_r << 24) | (bg_g << 16) | (bg_b << 8) | 0xFF
            text = 0xFF * 16777216 + text_b * 65536 + text_g * 256 + text_r,        -- (text_r << 24) | (text_g << 16) | (text_b << 8) | 0xFF
            button = 0xFF * 16777216 + btn_b * 65536 + btn_g * 256 + btn_r,         -- (btn_r << 24) | (btn_g << 16) | (btn_b << 8) | 0xFF
            button_hovered = 0xFF * 16777216 + btn_h_b * 65536 + btn_h_g * 256 + btn_h_r,  -- (btn_h_r << 24) | (btn_h_g << 16) | (btn_h_b << 8) | 0xFF
            button_active = 0xFF * 16777216 + btn_a_b * 65536 + btn_a_g * 256 + btn_a_r,   -- (btn_a_r << 24) | (btn_a_g << 16) | (btn_a_b << 8) | 0xFF
        }
        
        if console_logger then
            console_logger.log("INFO", string.format("Random theme generated with base hue %.1f°", base_hue))
        end
    end
    
    ImGui.Spacing(ctx)
    
    -- Usage Tips
    ImGui.Text(ctx, "Usage Tips")
    ImGui.Separator(ctx)
    ImGui.BulletText(ctx, "Changes apply immediately to the main window")
    ImGui.BulletText(ctx, "Use presets for quick theme switching")
    ImGui.BulletText(ctx, "🎲 Generate Random creates cohesive color schemes")
    ImGui.BulletText(ctx, "Export themes to share with others")
    
    return true
end

-- Get current theme colors (for main window to use)
function M.get_theme_colors()
    return theme_colors
end

-- Set theme colors (for external control)
function M.set_theme_colors(colors)
    for name, color in pairs(colors) do
        if theme_colors[name] then
            theme_colors[name] = color
        end
    end
end

-- Apply theme colors to an ImGui context (for modules to use)
function M.apply_theme_to_context(ctx, ImGui)
    if not ctx or not ImGui then return end
    
    -- Apply the current theme colors as ImGui style colors
    local col_window_bg = type(ImGui.Col_WindowBg) == "function" and ImGui.Col_WindowBg() or 2
    local col_text = type(ImGui.Col_Text) == "function" and ImGui.Col_Text() or 0
    local col_button = type(ImGui.Col_Button) == "function" and ImGui.Col_Button() or 21
    local col_button_hovered = type(ImGui.Col_ButtonHovered) == "function" and ImGui.Col_ButtonHovered() or 22
    local col_button_active = type(ImGui.Col_ButtonActive) == "function" and ImGui.Col_ButtonActive() or 23
    
    -- Push theme colors to ImGui style stack
    ImGui.PushStyleColor(ctx, col_window_bg, theme_colors.background)
    ImGui.PushStyleColor(ctx, col_text, theme_colors.text)
    ImGui.PushStyleColor(ctx, col_button, theme_colors.button)
    ImGui.PushStyleColor(ctx, col_button_hovered, theme_colors.button_hovered)
    ImGui.PushStyleColor(ctx, col_button_active, theme_colors.button_active)
    
    return 5 -- Return number of colors pushed (for PopStyleColor)
end

-- Get a specific theme color by name
function M.get_theme_color(color_name)
    return theme_colors[color_name] or 0xFFFFFFFF -- Default to white if not found
end

-- Theme-aware helper for modules
function M.create_themed_imgui_wrapper(base_imgui)
    -- Create a wrapper that automatically applies theming
    return setmetatable({}, {
        __index = function(t, k)
            local base_func = base_imgui[k]
            if not base_func then return nil end
            
            -- For window creation functions, auto-apply theme
            if k == "Begin" then
                return function(ctx, name, ...)
                    local colors_pushed = M.apply_theme_to_context(ctx, base_imgui)
                    local result = {base_func(ctx, name, ...)}
                    -- Store cleanup info for End function
                    t._theme_cleanup = colors_pushed
                    return table.unpack(result)
                end
            elseif k == "End" then
                return function(ctx)
                    local result = base_func(ctx)
                    -- Clean up pushed colors
                    if t._theme_cleanup and t._theme_cleanup > 0 then
                        base_imgui.PopStyleColor(ctx, t._theme_cleanup)
                        t._theme_cleanup = nil
                    end
                    return result
                end
            else
                return base_func
            end
        end
    })
end

-- Tool metadata
M.metadata = {
    label = "Enhanced Theming",
    icon = "🎨",
    category = "UI",
    active = true
}

return M
