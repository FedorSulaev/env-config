local oil = require("oil")
oil.setup({
	columns = { "icon" },
	keymaps = {
		["<C-h>"] = false,
		["<M-h>"] = "actions.select_split",
	},
	view_options = {
		show_hidden = true,
	},
})

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Open parent directory in the current window
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Open parent directory in floating window
vim.keymap.set("n", "<leader>-", oil.toggle_float, { desc = "Open directory in float" })
