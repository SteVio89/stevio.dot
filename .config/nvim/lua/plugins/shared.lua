vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
	{ src = "https://github.com/hakonharnes/img-clip.nvim", name = "img-clip" },
	{ src = "https://github.com/neovim/nvim-lspconfig", name = "nvim-lspconfig" },
	{ src = "https://github.com/MunifTanjim/nui.nvim", name = "nui" },
})

require("img-clip").setup({})
