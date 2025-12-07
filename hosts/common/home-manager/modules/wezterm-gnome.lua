local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "GruvboxDark"
config.font = wezterm.font("JetBrainsMono NF", { weight = "DemiBold" })
config.hide_tab_bar_if_only_one_tab = true
config.front_end = "WebGpu"
config.font_size = 10
config.webgpu_power_preference = "HighPerformance"

config.window_decorations = "TITLE|RESIZE"
config.enable_wayland = false

return config
