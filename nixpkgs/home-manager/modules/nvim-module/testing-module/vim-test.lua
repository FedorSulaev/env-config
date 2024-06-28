vim.g.mapleader = " "
vim.cmd("let test#strategy = 'vimux'")
vim.cmd("let test#java#gradletest#executable = 'bb test'")
-- Vim-test
vim.keymap.set("n", "<leader>t", ":TestNearest<CR>")
vim.keymap.set("n", "<leader>T", ":TestFile<CR>")
vim.keymap.set("n", "<leader>a", ":TestSuite<CR>")
vim.keymap.set("n", "<leader>l", ":TestLast<CR>")
vim.keymap.set("n", "<leader>g", ":TestVisit<CR>")
