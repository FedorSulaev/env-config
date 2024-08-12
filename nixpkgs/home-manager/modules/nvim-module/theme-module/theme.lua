require("gruvbox").setup()
-- Load the colorscheme here.
-- Like many other themes, this one has different styles, and you could load
-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
vim.cmd.colorscheme("gruvbox")

-- You can configure highlights by doing something like:
-- vim.cmd.hi("Comment gui=none")
-- Noice
vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCalculator", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderFilter", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderHelp", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderLua", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderInput", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderIncRename", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NoiceSplitBorder", { fg = "#fe8019" })

-- Notify
vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = "#cc241d" })
vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = "#fe8019" })
vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = "#fb4934" })
