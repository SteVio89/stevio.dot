return {
	"renerocksai/telekasten.nvim",
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-telekasten/calendar-vim" },
	config = function()
		require("telekasten").setup({
			home = vim.fn.expand("~/code/zettelkasten"),
		})
		vim.keymap.set("n", "<leader>na", "<cmd>Telekasten goto_today<CR>")
		vim.keymap.set("n", "<leader>nf", "<cmd>Telekasten find_notes<CR>")
		vim.keymap.set("n", "<leader>nt", "<cmd>Telekasten toggle_todo<CR>")
		vim.keymap.set("n", "<leader>ni", "o- [ ] ")
		vim.keymap.set("n", "<leader>nn", "<cmd>Telekasten new_note<CR>")
		vim.keymap.set("n", "<leader>ng", "<cmd>Telekasten search_notes<CR>")
		vim.keymap.set("n", "<leader>nc", "<cmd>Telekasten show_calendar<CR>")
	end,
}
