local imgui = require("docs.reaimgui-master 3.shims.imgui")
local ctx = imgui.CreateContext("Font Loader Demo")

local font_path = reaper.GetResourcePath() .. "/Fonts/DejaVuSans.ttf"
local my_font = imgui.CreateFont(font_path, 18)

imgui.AttachFont(ctx, my_font)

function loop()
  imgui.SetNextWindowSize(ctx, 400, 200, imgui.Cond_Once)
  if imgui.Begin(ctx, "Font Loader") then
    imgui.Text(ctx, "Default Font")
    imgui.Separator()

    imgui.PushFont(ctx, my_font)
    imgui.Text(ctx, "DejaVuSans 18pt")
    imgui.PopFont(ctx)
  end
  imgui.End(ctx)
  reaper.defer(loop)
end

reaper.defer(loop)
