vim.pack.add({
	{ src = "https://github.com/actionshrimp/direnv.nvim", name = "direnv" },
})

local direnv = require("direnv-nvim")

local function restart_lsp(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		client:stop()
	end
	vim.schedule(function()
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype ~= "" then
			vim.api.nvim_exec_autocmds("FileType", { buffer = buf, modeline = false })
		end
	end)
end

local function unload_stale_direnv(buf)
	if not vim.env.DIRENV_DIFF then
		return
	end
	vim.system({ "direnv", "export", "json" }, { text = true }, function(res)
		if res.code ~= 0 or not res.stdout or res.stdout == "" then
			return
		end
		local ok, env = pcall(vim.json.decode, res.stdout)
		if not ok or type(env) ~= "table" then
			return
		end
		vim.schedule(function()
			for k, v in pairs(env) do
				vim.env[k] = (v == vim.NIL) and nil or v
			end
			restart_lsp(buf)
		end)
	end)
end

direnv.setup({
	type = "dir",
	async = true,
	hook = { msg = "status" },
})

vim.api.nvim_create_autocmd("User", {
	group = "direnv-nvim",
	pattern = "DirenvReady",
	callback = function(args)
		restart_lsp(args.buf)
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = "direnv-nvim",
	pattern = "DirenvNotFound",
	callback = function(args)
		unload_stale_direnv(args.buf)
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("direnv-initial-load", { clear = true }),
	once = true,
	callback = function()
		direnv.hook()
	end,
})

return direnv
