-- Font Selector Panel for DevToolbox
-- Implements the FONT_MANAGER_API_SOP.txt guidelines


local M = {}

function M.draw(ctx)
    reaper.ImGui_Text(ctx, "Font Preview")
    reaper.ImGui_Separator(ctx)
    if _G.devtoolbox_font then
        reaper.ImGui_PushFont(ctx, _G.devtoolbox_font)
    end
    reaper.ImGui_TextWrapped(ctx, "The quick brown fox jumps over the lazy dog 0123456789")
    if _G.devtoolbox_font then
        reaper.ImGui_PopFont(ctx)
    end
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Current Font: Arial 16px (global)")
    reaper.ImGui_Text(ctx, "Font is now applied globally to all panels.")
end

return M
