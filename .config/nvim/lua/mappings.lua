vim.g.mapleader = " "
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<leader>op", "<cmd>Precognition toggle<cr>", { noremap = true, silent = true, desc = "Toggle Precognition" })
vim.keymap.set("n", "<leader>oh", "<cmd>Hardtime toggle<cr>", { noremap = true, silent = true, desc = "Toggle Hardtime" })
vim.keymap.set("n", "<leader>ow", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
vim.keymap.set("n", "<leader>bc", "<cmd>bd<cr>", { desc = "Close current buffer" })
