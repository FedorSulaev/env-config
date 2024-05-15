vim.g.mapleader = " "
vim.g.maplocalleader = " "

local whichKey = require("which-key")
whichKey.setup()
-- Document existing key chains
require("which-key").register({
	["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
	["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
	["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
	["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
	["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
	["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
})
-- Visual mode
require("which-key").register({
	["<leader>h"] = { name = "Git [H]unk" },
}, { mode = "v" })
