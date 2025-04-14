vim.g.mapleader = " "
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<leader>op", "<cmd>Precognition toggle<cr>", { noremap = true, silent = true, desc = 'Toggle Precognition'} )
