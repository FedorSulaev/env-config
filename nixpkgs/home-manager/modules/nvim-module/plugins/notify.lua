vim.o.termguicolors = true

local notify = require("notify")
notify.setup({})
vim.notify = notify
