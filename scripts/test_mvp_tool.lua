-- /scripts/test_mvp_tool.lua
-- Minimal working tool for DevToolbox UI testing

local M = {}

function M.init()
    reaper.ShowConsoleMsg("test_mvp_tool initialized\n")
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
    ImGui.Text(ctx, "MVP Test Tool Loaded!")
    if ImGui.Button(ctx, "Log Hello") then
        reaper.ShowConsoleMsg("Hello from test_mvp_tool!\n")
    end
end

function M.shutdown()
    reaper.ShowConsoleMsg("test_mvp_tool shutdown\n")
end

return M
