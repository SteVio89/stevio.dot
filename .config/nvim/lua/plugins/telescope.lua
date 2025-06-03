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
		vim.keymap.set("n", "<leader>fd", function()
			builtin.diagnostics({ bufnr = 0 })
		end, { desc = "Diagnostics this buffer" })
		vim.keymap.set("n", "<leader>fD", builtin.diagnostics, { desc = "Diagnostics all buffers" })
    vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Reference under the cursor" })
		vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Symbols this buffer" })
		vim.keymap.set("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Symbols alls buffers" })
	end,
}
