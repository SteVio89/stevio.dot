return {
	"NeogitOrg/neogit",
	version = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",

		"nvim-telescope/telescope.nvim",
	},
  keys = {
    {
      "<leader>gg",
      "<cmd>Neogit<cr>",
      desc = "Open neogit",
      mode = "n"
    }
  },
	opts = {},
	cmd = "Neogit",
	config = function(_, opts)
		require("neogit").setup(opts)
	end,
}
