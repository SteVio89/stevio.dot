vim.pack.add({
	{ src = "https://github.com/Bekaboo/dropbar.nvim", name = "dropbar" },
})

require("dropbar").setup({
	bar = {
		-- The git review and unsaved triage panels set their own winbar hints.
		enable = function(buf, win, _)
			if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win)) then
				return false
			end
			if vim.g.git_review_active then
				return false
			end
			return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
		end,
	},
})
