local imgui = require("docs.reaimgui-master 3.shims.imgui")
local theme_store = require("archive.lib.theme_store")
local ctx = imgui.CreateContext("Font Browser")
local font = nil
local font_dir = reaper.GetResourcePath() .. "/Fonts/"
local font_files = {}
local font_index = 1
local font_size = 18

-- Load theme (font name + size)
theme_store.load()
local theme = theme_store.theme
font_index = theme.font_index or 1
font_size = theme.font_size or 18

function list_fonts()
  local i = 0
  local info = reaper.EnumerateFiles(font_dir, i)
  while info do
    if info:match("%.ttf$") or info:match("%.otf$") then
      table.insert(font_files, info)
    end
    i = i + 1
    info = reaper.EnumerateFiles(font_dir, i)
  end
end

function load_font(name, size)
  local path = font_dir .. name
  local f = imgui.CreateFont(path, size)
  imgui.AttachFont(ctx, f)
  return f
end

list_fonts()
if font_files[font_index] then
  font = load_font(font_files[font_index], font_size)
end

function loop()
  imgui.SetNextWindowSize(ctx, 500, 280, imgui.Cond_Once)
  if imgui.Begin(ctx, "Font Browser + Theme Save") then
    local changed = false
    changed, font_index = imgui.Combo(ctx, "Font File", font_index, font_files)
    if changed and font_files[font_index] then
      font = load_font(font_files[font_index], font_size)
    end

    changed, font_size = imgui.SliderInt(ctx, "Font Size", font_size, 8, 48)
    if changed and font_files[font_index] then
      font = load_font(font_files[font_index], font_size)
    end

    if imgui.Button(ctx, "Save Theme") then
      theme.font_index = font_index
      theme.font_size = font_size
      theme_store.save()
    end

    imgui.Separator()
    if font then imgui.PushFont(ctx, font) end
    imgui.Text(ctx, "Live preview with saved theme settings")
    if font then imgui.PopFont(ctx) end
  end
  imgui.End(ctx)
  reaper.defer(loop)
end

reaper.defer(loop)
