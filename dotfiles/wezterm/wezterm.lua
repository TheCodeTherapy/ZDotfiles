local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.window_background_opacity = 0.85
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 999999
config.window_padding = {
  left = 30,
  right = 30,
  top = 30,
  bottom = 30,
}
config.window_decorations = "RESIZE"

return config
