-- /modules/theming.lua
-- Handles loading, applying, and saving themes.

local M = {}

local current_theme = {
    name = "Default",
    colors = {
        -- ImGui.Col_... = {r, g, b, a}
    }
}

function M.apply_theme(ctx)
    -- Pushes colors from current_theme to ImGui style
end

function M.load_theme(filename)
    -- loads a theme from a file
end

function M.save_theme(filename)
    -- saves the current theme to a file
end

function M.get_current_theme()
    return current_theme
end

return M
