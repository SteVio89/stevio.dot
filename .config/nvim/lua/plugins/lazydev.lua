vim.pack.add({
	{ src = "https://github.com/folke/lazydev.nvim", name = "lazydev" },
})

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
	integrations = {
		lspconfig = true,
	},
	enabled = function(root_dir)
		return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
	end,
})
