local LIST_WIDTH = 36

local function modified_buffers()
	local out = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and vim.bo[b].modified then
			out[#out + 1] = b
		end
	end
	return out
end

local function has_file(bufnr)
	return vim.api.nvim_buf_get_name(bufnr) ~= ""
end

local function on_disk(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	return name ~= "" and vim.fn.filereadable(name) == 1
end

local function display_name(bufnr)
	if not has_file(bufnr) then
		return "[No Name]"
	end
	return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")
end

local function disk_lines(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" or vim.fn.filereadable(name) == 0 then
		return {}
	end
	local ok, lines = pcall(vim.fn.readfile, name)
	return ok and lines or {}
end

local function as_text(lines)
	if #lines == 0 then
		return ""
	end
	return table.concat(lines, "\n") .. "\n"
end

local function open()
	if vim.tbl_isempty(modified_buffers()) then
		vim.notify("No unsaved buffers", vim.log.levels.INFO)
		return
	end

	vim.cmd.tabnew()
	local state = {
		list_win = vim.api.nvim_get_current_win(),
		list_buf = vim.api.nvim_get_current_buf(),
		entries = {},
		last = nil,
	}

	vim.bo[state.list_buf].buftype = "nofile"
	vim.bo[state.list_buf].bufhidden = "wipe"
	vim.bo[state.list_buf].swapfile = false
	pcall(vim.api.nvim_buf_set_name, state.list_buf, "unsaved://buffers")

	vim.cmd("rightbelow vsplit")
	state.patch_win = vim.api.nvim_get_current_win()
	state.patch_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.patch_buf].bufhidden = "wipe"
	vim.api.nvim_win_set_buf(state.patch_win, state.patch_buf)

	local function current_bufnr()
		local lnum = vim.api.nvim_win_get_cursor(state.list_win)[1]
		return state.entries[lnum]
	end

	local function render_list()
		local bufs = modified_buffers()
		if vim.tbl_isempty(bufs) then
			if vim.api.nvim_win_is_valid(state.list_win) then
				vim.cmd.tabclose()
			end
			vim.notify("No unsaved buffers", vim.log.levels.INFO)
			return false
		end
		state.entries = {}
		local lines = {}
		for i, b in ipairs(bufs) do
			state.entries[i] = b
			lines[i] = "* " .. display_name(b)
		end
		vim.bo[state.list_buf].modifiable = true
		vim.api.nvim_buf_set_lines(state.list_buf, 0, -1, false, lines)
		vim.bo[state.list_buf].modifiable = false
		return true
	end

	local function show_diff(force)
		local bufnr = current_bufnr()
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end
		if not force and state.last == bufnr then
			return
		end
		state.last = bufnr

		local disk = as_text(disk_lines(bufnr))
		local buf = as_text(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
		local patch = vim.diff(disk, buf, { result_type = "unified", ctxlen = 3 })

		local lines
		if patch == nil or patch == "" then
			lines = { "No differences with file on disk." }
		else
			local name = display_name(bufnr)
			lines = { "--- " .. name .. "  (on disk)", "+++ " .. name .. "  (buffer)" }
			vim.list_extend(lines, vim.split(patch, "\n", { trimempty = true }))
		end

		vim.bo[state.patch_buf].modifiable = true
		vim.api.nvim_buf_set_lines(state.patch_buf, 0, -1, false, lines)
		vim.bo[state.patch_buf].modifiable = false
		vim.bo[state.patch_buf].filetype = "diff"
	end

	local function refresh()
		if not render_list() then
			return
		end
		local n = vim.api.nvim_buf_line_count(state.list_buf)
		local cur = vim.api.nvim_win_get_cursor(state.list_win)[1]
		if cur > n then
			vim.api.nvim_win_set_cursor(state.list_win, { n, 0 })
		end
		state.last = nil
		show_diff(true)
	end

	local function save_cur()
		local b = current_bufnr()
		if not b then
			return
		end
		if not has_file(b) then
			vim.notify("Buffer has no file name", vim.log.levels.WARN)
			return
		end
		vim.api.nvim_buf_call(b, function()
			vim.cmd.write()
		end)
		refresh()
	end

	local function discard_cur()
		local b = current_bufnr()
		if not b then
			return
		end
		if on_disk(b) then
			vim.api.nvim_buf_call(b, function()
				vim.cmd("edit!")
			end)
		else
			vim.api.nvim_buf_delete(b, { force = true })
		end
		refresh()
	end

	local function save_all()
		for _, b in ipairs(modified_buffers()) do
			if has_file(b) then
				vim.api.nvim_buf_call(b, function()
					vim.cmd.write()
				end)
			end
		end
		refresh()
	end

	local function discard_all()
		if vim.fn.confirm("Discard ALL unsaved changes?", "&Yes\n&No", 2) ~= 1 then
			return
		end
		for _, b in ipairs(modified_buffers()) do
			if on_disk(b) then
				vim.api.nvim_buf_call(b, function()
					vim.cmd("edit!")
				end)
			else
				vim.api.nvim_buf_delete(b, { force = true })
			end
		end
		refresh()
	end

	local function map(lhs, fn)
		vim.keymap.set("n", lhs, fn, { buffer = state.list_buf, nowait = true, silent = true })
	end
	map("<CR>", function()
		show_diff(true)
	end)
	map("s", save_cur)
	map("d", discard_cur)
	map("S", save_all)
	map("D", discard_all)
	map("q", function()
		vim.cmd.tabclose()
	end)

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("unsaved_triage", { clear = true }),
		buffer = state.list_buf,
		callback = function()
			show_diff(false)
		end,
	})

	vim.api.nvim_set_current_win(state.list_win)
	vim.wo[state.list_win].number = false
	vim.wo[state.list_win].relativenumber = false
	vim.wo[state.list_win].cursorline = true
	vim.wo[state.list_win].winfixwidth = true
	vim.wo[state.list_win].winbar =
		" %#Special#s%* save  %#Special#d%* disc  %#Special#S/D%* all  %#Special#q%* quit"
	render_list()
	vim.api.nvim_win_set_cursor(state.list_win, { 1, 0 })
	vim.api.nvim_win_set_width(state.list_win, LIST_WIDTH)
	show_diff(true)
end

vim.api.nvim_create_user_command("UnsavedBuffers", open, { desc = "Review unsaved buffers" })
vim.keymap.set("n", "<leader>bu", open, { desc = "Review unsaved buffers" })
