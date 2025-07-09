-- lua/plugins/neorg.lua
return {
	"nvim-neorg/neorg",
	lazy = false,
	version = "*",
	keys = {
		{ "<leader>nj", "<cmd>Neorg journal today<CR>", desc = "Neorg: Open Daily Journal" },
	},
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/code/neorg/notes",
							team = "~/code/neorg/team",
						},
						default_workspace = "notes",
					},
				},
			},
		})

		vim.wo.foldlevel = 99
		vim.wo.conceallevel = 2
	end,
}
