local imgui = require("docs.reaimgui-master 3.shims.imgui")
local theme_store = require("lib.theme_store")

local config = {}
local state = {
  font_name = theme_store.get("font_name", "Arial"),
  font_size = theme_store.get("font_size", 16),
  theme_color = theme_store.get("theme_color", {0.3, 0.3, 0.3, 1.0}),
}

function config.draw(ctx)
  imgui.Begin(ctx, "DevToolbox Config Panel")

  changed_font, state.font_name = imgui.InputText(ctx, "Font Name", state.font_name or "", 128)
  changed_size, state.font_size = imgui.SliderInt(ctx, "Font Size", state.font_size, 8, 64)

  local color = state.theme_color
  changed_color, color = imgui.ColorEdit4(ctx, "Theme Color", table.unpack(color))
  if changed_color then state.theme_color = color end

  if imgui.Button(ctx, "Save Settings") then
    theme_store.set("font_name", state.font_name)
    theme_store.set("font_size", state.font_size)
    theme_store.set("theme_color", state.theme_color)
    theme_store.save()
  end

  imgui.SameLine(ctx)
  if imgui.Button(ctx, "Reload Settings") then
    state.font_name = theme_store.get("font_name")
    state.font_size = theme_store.get("font_size")
    state.theme_color = theme_store.get("theme_color")
  end

  imgui.End(ctx)
end

return config
