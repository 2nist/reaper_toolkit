-- /scripts/theming_panel.lua
-- A simple theming panel for the DevToolbox


local M = {}
local color = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }

function M.init()
    -- Optionally load a saved theme here
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
    ImGui.Text(ctx, "Theming Panel")
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Pick a background color:")
    local color_changed = false
    if type(ImGui.ColorEdit4) == 'function' then
        local ok, changed, r, g, b, a = pcall(ImGui.ColorEdit4, ctx, "Background", {color.r, color.g, color.b, color.a})
        if ok and changed then
            color.r, color.g, color.b, color.a = r, g, b, a
            color_changed = true
        end
    end
    if not color_changed and type(ImGui.ColorEdit3) == 'function' then
        local ok, changed, r, g, b = pcall(ImGui.ColorEdit3, ctx, "Background", {color.r, color.g, color.b})
        if ok and changed then
            color.r, color.g, color.b = r, g, b
            color_changed = true
        end
    end
    if not color_changed then
        ImGui.Text(ctx, "[Color picker not available]")
    end
    ImGui.Spacing(ctx)
    ImGui.Text(ctx, string.format("Current RGBA: %.2f, %.2f, %.2f, %.2f", color.r, color.g, color.b, color.a))
    if ImGui.Button(ctx, "Reset") then
        color = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }
    end
end

function M.get_theme_color()
    return {color.r, color.g, color.b, color.a}
end

function M.shutdown()
end

return M
