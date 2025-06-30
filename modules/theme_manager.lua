-- /modules/theme_manager.lua
-- Global theme management for DevToolbox modules

local M = {}

local console_logger = require 'console_logger'

-- Reference to the enhanced theming panel (loaded on demand)
local theming_panel = nil

-- Initialize theme manager
function M.init()
    -- Try to load enhanced theming panel
    local ok, panel = pcall(require, 'enhanced_theming_panel')
    if ok then
        theming_panel = panel
        console_logger.info("Theme manager initialized with enhanced theming panel")
    else
        console_logger.warn("Theme manager: Enhanced theming panel not available")
    end
end

-- Get current theme colors
function M.get_theme_colors()
    if theming_panel and theming_panel.get_theme_colors then
        return theming_panel.get_theme_colors()
    else
        -- Return default theme colors
        return {
            background = 0x333333FF,     -- Dark gray
            text = 0xFFFFFFFF,           -- White  
            button = 0x4D4D80FF,         -- Blue-gray
            button_hovered = 0x6666B3FF, -- Lighter blue
            button_active = 0x333366FF,  -- Darker blue
        }
    end
end

-- Get a specific theme color by name
function M.get_theme_color(color_name)
    local colors = M.get_theme_colors()
    return colors[color_name] or 0xFFFFFFFF -- Default to white
end

-- Apply theme to ImGui context (returns number of colors pushed for cleanup)
function M.apply_theme(ctx, ImGui)
    if not ctx or not ImGui then return 0 end
    
    local colors = M.get_theme_colors()
    local colors_pushed = 0
    
    -- Safely get ImGui color constants
    local function get_imgui_constant(name, default)
        if type(ImGui[name]) == "function" then
            return ImGui[name]()
        elseif type(ImGui[name]) == "number" then
            return ImGui[name]
        else
            return default
        end
    end
    
    -- Apply theme colors
    local color_mappings = {
        {constant = "Col_WindowBg", color = colors.background, default = 2},
        {constant = "Col_Text", color = colors.text, default = 0},
        {constant = "Col_Button", color = colors.button, default = 21},
        {constant = "Col_ButtonHovered", color = colors.button_hovered, default = 22},
        {constant = "Col_ButtonActive", color = colors.button_active, default = 23},
    }
    
    for _, mapping in ipairs(color_mappings) do
        local col_id = get_imgui_constant(mapping.constant, mapping.default)
        ImGui.PushStyleColor(ctx, col_id, mapping.color)
        colors_pushed = colors_pushed + 1
    end
    
    return colors_pushed
end

-- Clean up applied theme (pop style colors)
function M.cleanup_theme(ctx, ImGui, colors_pushed)
    if ctx and ImGui and colors_pushed > 0 then
        ImGui.PopStyleColor(ctx, colors_pushed)
    end
end

-- Create a themed wrapper for any ImGui window
function M.create_themed_window(ctx, ImGui, window_name, window_function, ...)
    local colors_pushed = M.apply_theme(ctx, ImGui)
    
    local visible, open = ImGui.Begin(ctx, window_name, ...)
    local result = nil
    
    if visible then
        result = window_function(ctx, ImGui)
        ImGui.End(ctx)
    end
    
    M.cleanup_theme(ctx, ImGui, colors_pushed)
    return result, open
end

-- Helper for modules to easily create themed UI elements
function M.themed_button(ctx, ImGui, text, ...)
    local colors = M.get_theme_colors()
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Button and ImGui.Col_Button() or 21, colors.button)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered and ImGui.Col_ButtonHovered() or 22, colors.button_hovered)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive and ImGui.Col_ButtonActive() or 23, colors.button_active)
    
    local result = ImGui.Button(ctx, text, ...)
    
    ImGui.PopStyleColor(ctx, 3)
    return result
end

-- Helper for themed text
function M.themed_text(ctx, ImGui, text)
    local colors = M.get_theme_colors()
    
    ImGui.PushStyleColor(ctx, ImGui.Col_Text and ImGui.Col_Text() or 0, colors.text)
    ImGui.Text(ctx, text)
    ImGui.PopStyleColor(ctx, 1)
end

-- Check if theming is available
function M.is_theming_available()
    return theming_panel ~= nil
end

-- Reload theming panel (useful for development)
function M.reload()
    package.loaded['enhanced_theming_panel'] = nil
    M.init()
end

return M
