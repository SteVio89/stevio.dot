local MODES = { "docs", "opts" }
local WIDTH_RATIO = 0.95
local HEIGHT_RATIO = 0.95

local state = { buf = nil, win = nil, job = nil, mode = nil }

local function win_config()
	local width = math.min(math.floor(vim.o.columns * WIDTH_RATIO), vim.o.columns - 2)
	local height = math.min(math.floor(vim.o.lines * HEIGHT_RATIO), vim.o.lines - 4)
	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0),
		col = math.floor((vim.o.columns - width) / 2),
		border = "double",
		title = " " .. (state.mode or "goose") .. " ",
	}
end

local function is_visible()
	return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function reset()
	if is_visible() then
		vim.api.nvim_win_close(state.win, true)
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
	state = { buf = nil, win = nil, job = nil, mode = nil }
end

local function show()
	local config = win_config()
	config.style = "minimal"
	state.win = vim.api.nvim_open_win(state.buf, true, config)
end

local function hide()
	vim.api.nvim_win_hide(state.win)
	state.win = nil
end

local function start(mode, question)
	state.mode = mode
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "hide"
	show()

	vim.keymap.set("n", "q", hide, { buffer = state.buf, nowait = true, desc = "Hide goose" })

	-- 'zsh -i' sources .zshrc, where the docs/opts functions live. Without -i they do not exist.
	local cmd = { "zsh", "-ic", mode .. " " .. vim.fn.shellescape(question) }
	state.job = vim.fn.jobstart(cmd, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function()
			vim.schedule(reset)
		end,
	})
end

local function toggle()
	if is_visible() then
		hide()
		return
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		show()
		return
	end
	vim.ui.select(MODES, { prompt = "Mode:" }, function(mode)
		if not mode then
			return
		end
		vim.ui.input({ prompt = mode .. "> " }, function(question)
			if not question or question:match("^%s*$") then
				return
			end
			start(mode, question)
		end)
	end)
end

vim.api.nvim_create_autocmd("VimResized", {
	group = vim.api.nvim_create_augroup("goose_float", { clear = true }),
	callback = function()
		if is_visible() then
			vim.api.nvim_win_set_config(state.win, win_config())
		end
	end,
})

vim.api.nvim_create_user_command("GooseAsk", toggle, { desc = "Ask goose" })
vim.keymap.set("n", "<leader>ta", toggle, { desc = "Toggle ask (goose)" })
