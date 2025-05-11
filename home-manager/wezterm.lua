local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "GruvboxDark"
config.font = wezterm.font("JetBrainsMono NF", { weight = "DemiBold" })
config.font_size = 14
config.hide_tab_bar_if_only_one_tab = true
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

return config
