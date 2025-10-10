return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		spec = {
			{ "<leader>f", group = "file" },
			{ "<leader>n", group = "notes" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>g", group = "goto" },
			{ "<leader>c", group = "code" },
			{ "<leader>o", group = "other" },
			{ "<leader>t", group = "trouble" },
			{ "<leader>z", group = "zen" },
			{ "<leader>s", group = "sessions" },
			{ "<leader>o", group = "other" },
      { "<leader>v", group = "löve2d"}
		},
	},
}
