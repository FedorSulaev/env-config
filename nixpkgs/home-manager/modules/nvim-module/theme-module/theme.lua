require("gruvbox").setup()
-- Load the colorscheme here.
-- Like many other themes, this one has different styles, and you could load
-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
vim.cmd.colorscheme("gruvbox")

-- You can configure highlights by doing something like:
-- vim.cmd.hi("Comment gui=none")
-- Noice
vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCalculator", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderFilter", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderHelp", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderLua", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderInput", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderIncRename", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceConfirmBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NoiceSplitBorder", { fg = "#fbf1c7" })

-- Notify
vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NotifyERRORBorder", { fg = "#cc241d" })
vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { fg = "#fbf1c7" })
vim.api.nvim_set_hl(0, "NotifyWARNBorder", { fg = "#fb4934" })
