-- Style Editor Panel (Backup/Fallback Version)
-- Simplified version to prevent crashes

local M = {}

function M.init()
    -- Initialize panel
    print("Style editor panel initialized (fallback mode)")
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
    
    ImGui.Text(ctx, "🎨 Style Editor")
    ImGui.Separator(ctx)
    
    ImGui.Text(ctx, "Advanced style editing features coming soon...")
    ImGui.Spacing(ctx)
    
    ImGui.Text(ctx, "For now, use the Enhanced Theming Panel for:")
    ImGui.Text(ctx, "• Theme color customization")
    ImGui.Text(ctx, "• Real-time theme switching")
    ImGui.Text(ctx, "• Custom theme creation")
    ImGui.Text(ctx, "• Theme export/import")
    
    ImGui.Spacing(ctx)
    ImGui.TextColored(ctx, 0x888888FF, "This panel is in development.")
end

function M.shutdown()
    -- Cleanup
end

return M
