vim.pack.add({
	{ src = "https://github.com/SteVio89/just-stevio.nvim", name = "just-stevio" },
})

require("just-stevio").setup({
	keymaps = { open = "<leader>j" },
})
