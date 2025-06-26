local reaper = reaper
local imgui = require("docs.reaimgui-master 3.shims.imgui")
local theme = require("theming")
local imgui = require("docs.reaimgui-master 3.shims.imgui")
local theme_store = require("lib.theme_store")


local menu = {}
menu.entries = {}

function menu.register(name, callback)
  table.insert(menu.entries, {name = name, callback = callback})
end

-- Auto-register panels from scripts/panels/
local panels_dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper/scripts/panels/"
local i = 0
while true do
  local fname = reaper.EnumerateFiles(panels_dir, i)
  if not fname then break end
  if fname:match("%.lua$") then
    local panel_name = fname:gsub("%.lua$", "")
    menu.register(panel_name, function()
      local panel = dofile(panels_dir .. fname)
      if type(panel) == "table" and panel.draw then
        panel.draw(ctx) -- You may want to set a flag to show/hide in your main loop
      end
    end)
  end
  i = i + 1
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
