local imgui = require("docs.reaimgui-master 3.shims.imgui")
local theme_store = require("lib.theme_store")

local menu = {}
menu.entries = {}

function menu.register(name, callback)
  table.insert(menu.entries, {name = name, callback = callback})
end

function menu.draw(ctx)
  if imgui.BeginMenuBar(ctx) then
    if imgui.BeginMenu(ctx, "DevToolbox") then
      for _, entry in ipairs(menu.entries) do
        if imgui.MenuItem(ctx, entry.name) then
          entry.callback()
        end
      end
      if imgui.MenuItem(ctx, "Save Theme") then
        theme_store.save()
      end
      if imgui.MenuItem(ctx, "Load Theme") then
        theme_store.load()
      end
      imgui.EndMenu(ctx)
    end
    imgui.EndMenuBar(ctx)
  end
end

return menu
