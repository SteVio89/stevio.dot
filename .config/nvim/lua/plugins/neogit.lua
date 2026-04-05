vim.pack.add({
  { src = 'https://github.com/NeogitOrg/neogit', name = 'neogit' },
})

require("neogit").setup({})

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open neogit" })
