local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.font_size = 22
-- config.line_height = 1.4

config.font_size = 16
-- config.line_height = 1.1
config.enable_tab_bar = false
config.adjust_window_size_when_changing_font_size = false
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	-- "GeistMono Nerd Font",
	-- "MonaspiceKr Nerd Font",
	{ family = "Symbols Nerd Font Mono" },
})
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
-- config.window_padding = {
-- 	left = 40,
-- 	right = 20,
-- 	top = 15,
-- 	bottom = 20,
-- }
-- https://github.com/joshmedeski/dotfiles/blob/main/.config/wezterm/wezterm.lua
config.color_scheme = "Catppuccin Mocha"
config.keys = {
	{ key = "n", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
}

return config
