local json = require("lib.json")
local config_path = reaper.GetResourcePath() .. "/Scripts/devtoolbox-reaper/config/theme.json"

local theme = {
  bg = {0.12, 0.12, 0.12, 1},
  fg = {1, 1, 1, 1},
  accent = {0.3, 0.7, 1, 1}
}

local function save_theme()
  local f = io.open(config_path, "w")
  if f then
    f:write(json.encode(theme))
    f:close()
  end
end

local function load_theme()
  local f = io.open(config_path, "r")
  if f then
    local contents = f:read("*a")
    f:close()
    local ok, decoded = pcall(json.decode, contents)
    if ok and type(decoded) == "table" then
      theme = decoded
    end
  end
end

return {
  theme = theme,
  save = save_theme,
  load = load_theme
}
