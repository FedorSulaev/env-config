vim.g.mapleader = " "
vim.g.maplocalleader = " "

local whichKey = require("which-key")
whichKey.setup()
-- Document existing key chains
require("which-key").add({
	{ "<leader>c", name = "[C]ode" },
	{ "<leader>d", name = "[D]ocument" },
	{ "<leader>r", name = "[R]ename" },
	{ "<leader>s", name = "[S]earch" },
	{ "<leader>w", name = "[W]orkspace" },
	{ "<leader>h", name = "Git [H]unk" },
})
-- Visual mode
require("which-key").add({
	{ "<leader>h", name = "Git [H]unk" },
}, { mode = "v" })
