return {
	"nvim-telescope/telescope.nvim",
	branch = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"debugloop/telescope-undo.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffer" })
		vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<cr>", { desc = "Undo history" })
	end,
}
