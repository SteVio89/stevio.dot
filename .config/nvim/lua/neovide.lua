vim.g.neovide_opacity = 0.85
vim.g.neovide_window_blurred = true

local function zoxide_pick(on_choice)
	local dirs = vim.fn.systemlist({ "zoxide", "query", "-l" })
	if vim.v.shell_error ~= 0 or vim.tbl_isempty(dirs) then
		vim.notify("zoxide: no results (is zoxide installed?)", vim.log.levels.WARN)
		return
	end
	require("fzf-lua").fzf_exec(dirs, {
		prompt = "Zoxide> ",
		actions = {
			["default"] = function(selected)
				if selected and selected[1] then
					on_choice(selected[1])
				end
			end,
		},
	})
end

vim.keymap.set("n", "<leader>oo", function()
	zoxide_pick(function(dir)
		vim.system({ "zoxide", "add", dir }) -- feed the pick back into the shared DB
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[buf].buflisted then
				pcall(vim.api.nvim_buf_delete, buf, { force = false }) -- keeps unsaved buffers
			end
		end

		for _, client in ipairs(vim.lsp.get_clients()) do
			client:stop()
		end

		vim.fn.chdir(dir)
		require("fzf-lua").files({ cwd = dir })
	end)
end, { desc = "Open project (zoxide)" })

vim.keymap.set("n", "<leader>oO", function()
	zoxide_pick(function(dir)
		vim.system({ "zoxide", "add", dir })
		vim.system({ "neovide", "." }, { cwd = dir, detach = true })
	end)
end, { desc = "Open project in new window" })
