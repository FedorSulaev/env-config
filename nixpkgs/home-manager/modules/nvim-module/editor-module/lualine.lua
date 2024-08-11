require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "gruvbox",
		component_separators = "|",
		section_separators = "",
	},
	sections = {
		lualine_x = {
			{
				require("noice").api.status.mode.get,
				cond = require("noice").api.status.mode.has,
				color = { fg = "#ff9e64" },
			},
			{
				require("noice").api.status.command.get,
				cond = require("noice").api.status.command.has,
				color = { fg = "#ff9e64" },
			},
		},
		lualine_a = {
			{
				"buffers",
			},
		},
	},
})
