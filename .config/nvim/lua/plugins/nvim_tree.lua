vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-tree.lua", name = "nvim-tree" },
})

require("nvim-tree").setup({
	-- Leave directory buffers to the fzf explorer autocmd in plugins/fzf.lua.
	hijack_netrw = false,
	hijack_unnamed_buffer_when_opening = false,
	-- setup_auto_root() rewrites cwd on every BufEnter, so tracking it would re-root the
	-- tree mid-navigation. Re-root deliberately with '~' inside the tree instead.
	sync_root_with_cwd = false,
	update_focused_file = { enable = true, update_root = false },
	view = {
		side = "left",
		width = 34,
		preserve_window_proportions = true,
	},
	renderer = {
		group_empty = true,
	},
	actions = { open_file = { quit_on_open = true } },
	git = { enable = true },
	modified = { enable = false },
	diagnostics = { enable = false },
	filters = { dotfiles = false, git_ignored = true },
	on_attach = function(bufnr)
		local api = require("nvim-tree.api")
		api.config.mappings.default_on_attach(bufnr)
		vim.keymap.set("n", "~", function()
			api.tree.change_root(vim.fn.getcwd())
		end, { buffer = bufnr, nowait = true, desc = "Re-root tree to cwd" })
	end,
})

vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
