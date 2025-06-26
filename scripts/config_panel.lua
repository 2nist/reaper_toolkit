-- /scripts/config_panel.lua
-- Configuration panel for the DevToolbox

local M = {}

local theme_module -- will be loaded in init

function M.init()
    -- load theme manager
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
    ImGui.Text(ctx, "Global Toolbox Configuration")
    ImGui.Separator(ctx)
    ImGui.Text(ctx, "Theming options will go here.")
    ImGui.Spacing(ctx)
    ImGui.Text(ctx, "Font options will go here.")
end

function M.shutdown()
end

return M
