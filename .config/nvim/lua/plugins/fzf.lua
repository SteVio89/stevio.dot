vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua", name = "fzf" },
})

local fzf = require("fzf-lua")
fzf.setup({
	formatter = "path.filename_first",
	files = {
		actions = {
			["ctrl-g"] = { fn = fzf.actions.toggle_ignore, reuse = true },
		},
	},
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find file" })
vim.keymap.set("n", "<leader>f.", fzf.resume, { desc = "Resume last picker" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep files" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffer" })
vim.keymap.set("n", "<leader>fc", fzf.changes, { desc = "Find change (changelist)" })
vim.keymap.set("n", "<leader>fd", function()
	fzf.diagnostics_document()
end, { desc = "Diagnostics this buffer" })

local workspace_populated = false

vim.keymap.set("n", "<leader>fD", function()
	if not workspace_populated then
		local bufnr = vim.api.nvim_get_current_buf()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		if #clients == 0 then
			vim.notify("No LSP client attached — showing loaded buffers only", vim.log.levels.WARN)
		else
			for _, client in ipairs(clients) do
				require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
			end
			workspace_populated = true
			vim.notify("Populating workspace diagnostics — reopen for the full list", vim.log.levels.INFO)
		end
	end
	fzf.diagnostics_workspace()
end, { desc = "Diagnostics all buffers" })

vim.keymap.set("n", "<leader>fs", fzf.lsp_workspace_symbols, { desc = "Find symbol (workspace)" })
vim.keymap.set("n", "<leader>ft", function()
	fzf.grep({ search = "TODO|FIXME|HACK|NOTE" })
end, { desc = "Project Todos" })

local explorer_group = vim.api.nvim_create_augroup("FzfDefaultExplorer", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = explorer_group,
	callback = function(data)
		if vim.api.nvim_get_current_buf() ~= data.buf then
			return
		end
		local path = vim.api.nvim_buf_get_name(data.buf)
		if path == "" or vim.fn.isdirectory(path) ~= 1 then
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(data.buf) then
				return
			end
			vim.api.nvim_buf_delete(data.buf, { force = true })
			fzf.files({ cwd = path })
		end)
	end,
})
