local font_manager = require 'font_manager'

local function ensure_context()
    local ctx = reaper.ImGui_CreateContext('DevToolbox')
    local font_info, size = font_manager.get_current_font()
    local font_inst = font_manager.create_font(font_info, size, ctx)
    if not font_inst then
        reaper.MB("Failed to load font: "..font_info.name, "Font Error", 0)
    end
    return ctx
end

local function main()
    local ctx = ensure_context()
    while reaper.ImGui_IsWindowOpen(ctx) do
        reaper.ImGui_NewFrame(ctx)
        local font_info, size = font_manager.get_current_font()
        local font_inst = font_manager.create_font(font_info, size, ctx)
        if font_inst then reaper.ImGui_PushFont(ctx, font_inst) end
        reaper.ImGui_Text(ctx, "Hello, DevToolbox!")
        if font_inst then reaper.ImGui_PopFont(ctx) end
        reaper.ImGui_EndFrame(ctx)
    end
end

main()