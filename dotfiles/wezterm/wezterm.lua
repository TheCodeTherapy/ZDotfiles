local wezterm = require "wezterm"

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 14.0
config.window_background_opacity = 0.9
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 999999
-- config.window_padding = {
--   left = 30,
--   right = 30,
--   top = 30,
--   bottom = 30,
-- }
config.window_decorations = "RESIZE"
config.window_frame = {
  font = wezterm.font { family = "JetBrains Mono", weight = "Bold" },
  font_size = 12.0,
  active_titlebar_bg = "#1e1e2e",
  inactive_titlebar_bg = "#1e1e2e",
}

config.colors = {
  tab_bar = {
    background = "#1e1e2e",
    active_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#eeeeee",
      intensity = "Normal",
      underline = "Single", -- "None", "Single" or "Double"
      italic = true,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#777777",
    },
    inactive_tab_hover = {
      bg_color = "#1e1e2e",
      fg_color = "#eeeeee",
      italic = true,
    },
    new_tab = {
      bg_color = "#1e1e2e",
      fg_color = "#aaaaaa",
    },
    new_tab_hover = {
      bg_color = "#1e1e2e",
      fg_color = "#eeeeee",
      italic = true,
    },
  },
}

return config
