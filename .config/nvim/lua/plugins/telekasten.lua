return {
	"renerocksai/telekasten.nvim",
	dependencies = { "nvim-telescope/telescope.nvim", "nvim-telekasten/calendar-vim" },
	config = function()
		require("telekasten").setup({
			home = vim.fn.expand("~/code/zettelkasten"),
		})
		vim.keymap.set("n", "<leader>na", "<cmd>Telekasten goto_today<CR>", { desc = "Open daily note file" })
		vim.keymap.set("n", "<leader>nf", "<cmd>Telekasten find_notes<CR>", { desc = "Search notes" })
		vim.keymap.set("n", "<leader>nt", "<cmd>Telekasten toggle_todo<CR>", { desc = "Toggle todo" })
		vim.keymap.set("n", "<leader>nid", function()
			local current_date = os.date("%Y-%m-%d")
			local current_line = vim.api.nvim_get_current_line()
			if current_line:match("^%s*$") then
				vim.api.nvim_feedkeys("i" .. current_date .. ":\n", "n", true)
			else
				vim.api.nvim_feedkeys("o" .. current_date .. ":\n", "n", true)
			end
		end, { desc = "Add current date (adapts to blank line)" })
		vim.keymap.set("n", "<leader>nit", function()
			local current_line = vim.api.nvim_get_current_line()
			if current_line:match("^%s*$") then
				vim.api.nvim_feedkeys("i- [ ] ", "n", true)
			else
				vim.api.nvim_feedkeys("o- [ ] ", "n", true)
			end
		end, { desc = "New task (adapts to blank line)" })
		vim.keymap.set("n", "<leader>nin", function()
			local current_line = vim.api.nvim_get_current_line()
			if current_line:match("^%s*$") then
				vim.api.nvim_feedkeys("i- ", "n", true)
			else
				vim.api.nvim_feedkeys("o- ", "n", true)
			end
		end, { desc = "New note (adapts to blank line)" })
		vim.keymap.set("n", "<leader>nn", "<cmd>Telekasten new_note<CR>", { desc = "New note file" })
		vim.keymap.set("n", "<leader>ng", "<cmd>Telekasten search_notes<CR>", { desc = "Search in notes" })
		vim.keymap.set("n", "<leader>nc", "<cmd>Telekasten show_calendar<CR>", { desc = "Show calendar" })
	end,
}
