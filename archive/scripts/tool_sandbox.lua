-- DevToolbox Launcher (ReaImGui Only)
local base = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper/"
package.path = base .. "?.lua;" .. base .. "?/init.lua;" .. base .. "scripts/?.lua;" .. base .. "scripts/?/init.lua;" .. base .. "scripts/lib/?.lua;" .. package.path

local config = require("config")
local gui_mode = config.load().gui

if gui_mode == "ImGui" then
  dofile(base .. "scripts/main.lua")
else
  reaper.ShowMessageBox("Only ReaImGui is supported in this version.", "GUI Error", 0)
end
