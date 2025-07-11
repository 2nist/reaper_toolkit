-- /scripts/template_tool.lua
-- A template for creating new tools for the DevToolbox.

local M = {}

function M.init()
    -- This function is called once when the script is loaded or reloaded.
    -- Use it for one-time setup.
    reaper.ShowConsoleMsg("Template Tool Initialized\n")
end

function M.draw(ctx)
    -- This function is called on every frame to draw the UI.
    -- 'ctx' is the ReaImGui context.
    
    -- Validate context before proceeding
    if not ctx then
        return
    end
    
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
    
    -- Use pcall to protect against context errors
    local ok, err = pcall(function()
        ImGui.Text(ctx, "This is the template tool.")
        ImGui.BulletText(ctx, "You can copy this file to create a new tool.")
        if ImGui.Button(ctx, "Click Me") then
            reaper.ShowConsoleMsg("Template Tool button clicked!\n")
        end
    end)
    
    if not ok then
        -- Fallback display if context is corrupted
        if reaper then
            reaper.ShowConsoleMsg("Template Tool: ImGui context error: " .. tostring(err) .. "\n")
        end
    end
end

function M.shutdown()
    -- This function is called when the script is reloaded or the toolbox is closed.
    -- Use it for cleanup.
    reaper.ShowConsoleMsg("Template Tool Shutdown\n")
end

-- Tool metadata
M.metadata = {
    label = "📋 Template Tool",
    icon = "📋",
    category = "Development",
    active = true
}

return M
