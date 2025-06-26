local imgui = require("docs.reaimgui-master 3.shims.imgui")
local ctx = imgui.CreateContext("Font Selector")
local font = nil
local font_path = reaper.GetResourcePath() .. "/Fonts/DejaVuSans.ttf"
local font_size = 18
local font_path_buf = imgui.CreateBuffer(256)

function load_font(path, size)
  local f = imgui.CreateFont(path, size)
  imgui.AttachFont(ctx, f)
  return f
end

function loop()
  imgui.SetNextWindowSize(ctx, 500, 220, imgui.Cond_Once)
  if imgui.Begin(ctx, "Font Selector") then
    imgui.Text(ctx, "Set Font Path:")
    imgui.InputText(ctx, "##path", font_path_buf)
    imgui.SameLine()
    if imgui.Button(ctx, "Load Font") then
      font_path = imgui.GetBufferText(font_path_buf)
      font = load_font(font_path, font_size)
    end

    changed, font_size = imgui.SliderInt(ctx, "Font Size", font_size, 8, 48)
    if changed and font_path then
      font = load_font(font_path, font_size)
    end

    imgui.Separator()
    if font then imgui.PushFont(ctx, font) end
    imgui.Text(ctx, "This is a test of the custom font!")
    if font then imgui.PopFont(ctx) end
  end
  imgui.End(ctx)
  reaper.defer(loop)
end

reaper.defer(loop)
