local M = {}

M.default_theme = {
  bg_color = 0x202020FF,
  fg_color = 0xFFFFFFFF,
  accent = 0xFF8800FF
}

local current_theme = M.default_theme

function M.get_theme()
  return current_theme
end

function M.set_bg_color(val)
  current_theme.bg_color = val
end

function M.set_fg_color(val)
  current_theme.fg_color = val
end

function M.set_accent_color(val)
  current_theme.accent = val
end

return M
