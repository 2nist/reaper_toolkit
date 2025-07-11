-- panels/tool_browser_panel.lua
-- Tool Browser Panel for DevToolbox

local M = {}

local script_manager = require("script_manager")

M.metadata = {
  label = "🧰 Tool Browser",
  icon = "🧰",
  category = "Utility",
  active = true
}

function M.init() 
  -- Initialize the panel
end

function M.shutdown() 
  -- Cleanup
end

function M.draw(ctx)
  -- Compatibility shim for ImGui
  local ImGui
  if reaper and reaper.ImGui_CreateContext then
    ImGui = setmetatable({}, {
      __index = function(t, k)
        local v = reaper["ImGui_" .. k]
        if v ~= nil then return v end
        return rawget(t, k)
      end
    })
    -- Add missing constants
    ImGui.SelectableFlags_AllowDoubleClick = type(reaper.ImGui_SelectableFlags_AllowDoubleClick) == "number" and reaper.ImGui_SelectableFlags_AllowDoubleClick or 2
  else
    ImGui = require 'imgui' '0.9.2'
    ImGui.SelectableFlags_AllowDoubleClick = ImGui.SelectableFlags_AllowDoubleClick or 2
  end

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

  local child_flags = get_imgui_flag("ChildFlags_Border", 1)
  
  if ImGui.BeginChild(ctx, "ToolBrowser", -1, -1, child_flags) then
    ImGui.Text(ctx, "🧰 Available Tools")
    ImGui.Separator(ctx)

    local tools_registry = script_manager.get_registry()
    local tool_order = script_manager.get_tool_order()
    
    if not tool_order or #tool_order == 0 then
      ImGui.Text(ctx, "No tools available")
    else
      for i = 1, #tool_order do
        local name = tool_order[i]
        local tool = tools_registry[name]
        if tool then
          -- Use pcall to protect against ID stack issues
          local ok, err = pcall(function()
            ImGui.PushID(ctx, name)
            
            local is_active = script_manager.is_tool_active(name)
            local label = string.format("%s %s", tool.icon or "🛠", tool.label or name)
            
            -- Create selectable item that can be double-clicked to toggle
            if ImGui.Selectable(ctx, label, is_active, ImGui.SelectableFlags_AllowDoubleClick) then
              if ImGui.IsMouseDoubleClicked and ImGui.IsMouseDoubleClicked(ctx, 0) then
                script_manager.toggle_tool(name)
              end
            end
            
            -- Show activation toggle button
            ImGui.SameLine(ctx)
            
            -- Safely handle style colors
            local style_pushed = false
            if is_active then
              local ok = pcall(ImGui.PushStyleColor, ctx, ImGui.Col_Button or 21, 0x00FF00FF) -- Green for active
              style_pushed = ok
            else
              local ok = pcall(ImGui.PushStyleColor, ctx, ImGui.Col_Button or 21, 0xFF0000FF) -- Red for inactive  
              style_pushed = ok
            end
            
            if ImGui.Button(ctx, is_active and "ON" or "OFF", 35) then
              script_manager.toggle_tool(name)
            end
            
            if style_pushed then
              pcall(ImGui.PopStyleColor, ctx)
            end
            
            -- Show category
            ImGui.SameLine(ctx)
            ImGui.TextColored(ctx, 0x888888FF, "(" .. (tool.category or "Unknown") .. ")")
            
            ImGui.PopID(ctx)
          end)
          
          if not ok then
            -- If there was an error, make sure we don't leave any dangling ID stack
            ImGui.Text(ctx, "Error rendering tool: " .. name)
          end
        end
      end
    end
    
    ImGui.EndChild(ctx)
  end
end

return M
