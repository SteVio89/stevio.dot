return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"bash",
			"go",
			"rust",
			"zig",
			"c",
			"vim",
			"vimdoc",
			"query",
		},
		highlight = {
			enable = true,
		},
		indent = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
