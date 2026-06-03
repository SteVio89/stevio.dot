local MiniFiles = require("mini.files")

local function set_widths()
	local cols = vim.o.columns
	MiniFiles.config.windows.width_nofocus = math.floor(0.20 * cols) -- parent column
	MiniFiles.config.windows.width_focus = math.floor(0.38 * cols) -- current dir
	MiniFiles.config.windows.width_preview = math.floor(0.24 * cols) -- preview
end

MiniFiles.setup({
	windows = { preview = true, max_number = 3 },
	options = { use_as_default_explorer = false },
})
set_widths()

local group = vim.api.nvim_create_augroup("MiniFilesModal", { clear = true })

vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "MiniFilesWindowOpen",
	callback = function(args)
		local cfg = vim.api.nvim_win_get_config(args.data.win_id)
		cfg.border = "rounded"
		cfg.title_pos = "left"
		vim.api.nvim_win_set_config(args.data.win_id, cfg)
	end,
})

local HEIGHT_FRAC = 0.85
vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "MiniFilesWindowUpdate",
	callback = function(args)
		local cfg = vim.api.nvim_win_get_config(args.data.win_id)

		local height = math.min(math.floor(HEIGHT_FRAC * vim.o.lines), vim.o.lines - 4)
		cfg.height = height
		cfg.row = math.floor(0.5 * (vim.o.lines - height))

		local state = MiniFiles.get_explorer_state()
		if state and state.windows then
			local total = 0
			for _, w in ipairs(state.windows) do
				total = total + vim.api.nvim_win_get_config(w.win_id).width + 2
			end
			cfg.col = cfg.col + math.floor(0.5 * (vim.o.columns - total))
		end

		vim.api.nvim_win_set_config(args.data.win_id, cfg)
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	callback = set_widths,
})

vim.keymap.set("n", "<leader>fe", function()
	local buffer_name = vim.api.nvim_buf_get_name(0)
	if buffer_name == "" or vim.fn.filereadable(buffer_name) == 0 then
		MiniFiles.open(vim.uv.cwd())
	else
		MiniFiles.open(buffer_name)
	end
end, { desc = "Open file explorer" })
