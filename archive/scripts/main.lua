local imgui = require('docs.reaimgui-master 3.shims.imgui')
local menus = require('menus')
local ctx = imgui.CreateContext('DevToolbox')

function loop()
  local visible, open = imgui.Begin(ctx, 'DevToolbox', true, imgui.WindowFlags_MenuBar)
  if visible then
    menus.draw(ctx)
    imgui.Text(ctx, 'Welcome to ReaImGui Toolbox!')
  end
  imgui.End(ctx)
  if open then reaper.defer(loop) end
end

reaper.defer(loop)
