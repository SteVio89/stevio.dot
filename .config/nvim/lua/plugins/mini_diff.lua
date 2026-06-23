require("mini.diff").setup({ view = { style = "number" } })

vim.keymap.set("n", "<leader>go", function()
	local MiniDiff = require("mini.diff")
	if MiniDiff.get_buf_data(0) == nil then
		vim.notify("Git diff overlay: not enabled in this buffer", vim.log.levels.WARN)
		return
	end
	MiniDiff.toggle_overlay()
	local on = MiniDiff.get_buf_data(0).overlay
	vim.notify("Git diff overlay: " .. (on and "on" or "off"))
end, { desc = "Toggle git diff overlay" })

vim.keymap.set("n", "<leader>gx", function()
	require("mini.diff").do_hunks(0, "reset", {
		line_start = vim.fn.line("."),
		line_end = vim.fn.line("."),
	})
end, { desc = "Revert hunk under cursor" })

vim.keymap.set("x", "<leader>gx", function()
	require("mini.diff").do_hunks(0, "reset", {
		line_start = vim.fn.line("v"),
		line_end = vim.fn.line("."),
	})
end, { desc = "Revert hunk(s) in selection" })

vim.keymap.set("n", "<leader>gs", function()
	require("mini.diff").do_hunks(0, "apply", {
		line_start = vim.fn.line("."),
		line_end = vim.fn.line("."),
	})
end, { desc = "Stage hunk under cursor" })

vim.keymap.set("x", "<leader>gs", function()
	require("mini.diff").do_hunks(0, "apply", {
		line_start = vim.fn.line("v"),
		line_end = vim.fn.line("."),
	})
end, { desc = "Stage hunk(s) in selection" })

vim.keymap.set("n", "<leader>gS", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("Stage file: buffer has no file on disk", vim.log.levels.WARN)
		return
	end

	local out = vim.fn.system({ "git", "add", "--", path })
	if vim.v.shell_error ~= 0 then
		vim.notify("Stage file failed: " .. out, vim.log.levels.ERROR)
		return
	end
	vim.notify("Staged " .. vim.fn.fnamemodify(path, ":t"))
end, { desc = "Stage whole file" })

local review_active = false
local review_items = {} -- ordered qf items still under review
local review_files = {} -- set: normalized abs path -> true
local mapped_bufs = {} -- set: bufnr -> true (buffers given the modal keys)
local review_group = vim.api.nvim_create_augroup("GitReview", { clear = true })

local function norm(path)
	return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local hunk_undo, file_undo = {}, {}

local function snapshot_index(path)
	local root = vim.fs.root(path, ".git")
	if not root then
		return { path = path, absent = true } -- not inside a git work tree
	end
	local out = vim.fn.systemlist({ "git", "-C", root, "ls-files", "-s", "--full-name", "--", path })
	if vim.v.shell_error ~= 0 or #out == 0 then
		return { path = path, root = root, absent = true } -- not staged / untracked yet
	end

	local mode, sha, rel = out[1]:match("^(%d+)%s+(%x+)%s+%d+%s+(.*)$")
	return { path = path, root = root, mode = mode, sha = sha, rel = rel }
end

local function restore_index(snap)
	local root = snap.root or vim.fs.root(snap.path, ".git")
	if not root then
		return
	end
	if snap.absent then
		vim.fn.system({ "git", "-C", root, "rm", "--cached", "--quiet", "--", snap.path })
	else
		vim.fn.system({ "git", "-C", root, "update-index", "--cacheinfo", snap.mode, snap.sha, snap.rel })
	end
end

local REVIEW_WINBAR = table.concat({
	" %#ModeMsg#REVIEW%*  ",
	"%#Special#n/p%* hunk  ",
	"%#Special#N/P%* file  ",
	"%#Special#x%* revert  ",
	"%#Special#s/S%* stage hunk/file  ",
	"%#Special#u/U%* undo hunk/file  ",
	"%#Special#R%* end",
})
local review_wins = {} -- set: winid -> previous winbar value (restored on end)

local function set_winbar(win)
	-- Record the window's original winbar once, but (re)apply ours every call:
	-- staging replaces the qf list + `:cc`, which blanks the window's winbar, so
	-- the next BufEnter must be able to restore it rather than early-return.
	if review_wins[win] == nil then
		review_wins[win] = vim.api.nvim_get_option_value("winbar", { win = win })
	end
	vim.api.nvim_set_option_value("winbar", REVIEW_WINBAR, { win = win })
end

local function restore_winbar(win)
	if review_wins[win] == nil then
		return
	end
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_option_value("winbar", review_wins[win], { win = win })
	end
	review_wins[win] = nil
end

local function restore_all_winbars()
	for win in pairs(review_wins) do
		restore_winbar(win)
	end
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniDiffUpdated",
	group = review_group,
	callback = function(args)
		if not review_active then
			return
		end
		local MiniDiff = require("mini.diff")
		local data = MiniDiff.get_buf_data(args.buf)
		if data and not data.overlay then
			MiniDiff.toggle_overlay(args.buf)
		end
	end,
})

local function git_lines(cmd)
	local out = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return {}
	end
	return out
end

local function nav(forward)
	if forward then
		if not pcall(vim.cmd, "cnext") then
			pcall(vim.cmd, "cfirst")
		end
	else
		if not pcall(vim.cmd, "cprevious") then
			pcall(vim.cmd, "clast")
		end
	end
end

local function refresh_qf(idx)
	vim.fn.setqflist({}, "r", { title = "Git Review", items = review_items, idx = idx })
end

local end_review

local function setup_review_maps(buf)
	if mapped_bufs[buf] then
		return
	end
	mapped_bufs[buf] = true
	local opts = { buffer = buf }
	local function map(lhs, fn, desc)
		vim.keymap.set("n", lhs, fn, vim.tbl_extend("force", opts, { desc = desc }))
	end

	map("n", function()
		require("mini.diff").goto_hunk("next")
	end, "Review: next hunk")
	map("p", function()
		require("mini.diff").goto_hunk("prev")
	end, "Review: previous hunk")
	map("N", function()
		nav(true)
	end, "Review: next file")
	map("P", function()
		nav(false)
	end, "Review: previous file")
	map("x", function()
		require("mini.diff").do_hunks(0, "reset", { line_start = vim.fn.line("."), line_end = vim.fn.line(".") })
	end, "Review: revert hunk under cursor")
	map("s", function()
		local path = vim.fn.expand("%:p")
		if path == "" then
			return
		end
		table.insert(hunk_undo, snapshot_index(path)) -- capture pre-stage index for `u`
		require("mini.diff").do_hunks(0, "apply", { line_start = vim.fn.line("."), line_end = vim.fn.line(".") })
	end, "Review: stage hunk under cursor")
	map("u", function()
		if #hunk_undo == 0 then
			vim.notify("Review: no hunk stage to undo", vim.log.levels.INFO)
			return
		end
		local snap = table.remove(hunk_undo)
		restore_index(snap)
		vim.notify("Unstaged last hunk in " .. vim.fn.fnamemodify(snap.path, ":t"))
	end, "Review: undo last hunk stage")
	map("R", function()
		end_review()
	end, "Review: end")
	map("S", function()
		local path = vim.fn.expand("%:p")
		if path == "" then
			vim.notify("Review: buffer has no file on disk", vim.log.levels.WARN)
			return
		end
		local snap = snapshot_index(path) -- capture pre-stage index for `U`
		local out = vim.fn.system({ "git", "add", "--", path })
		if vim.v.shell_error ~= 0 then
			vim.notify("Stage file failed: " .. out, vim.log.levels.ERROR)
			return
		end

		local cur = norm(path)
		local old_idx = vim.fn.getqflist({ idx = 0 }).idx
		local kept, removed = {}, nil
		for _, item in ipairs(review_items) do
			if norm(item.filename) == cur then
				removed = item
			else
				table.insert(kept, item)
			end
		end
		review_items = kept
		review_files[cur] = nil
		table.insert(file_undo, { snap = snap, item = removed or { filename = path, lnum = 1, text = "changed" } })

		vim.notify("Staged " .. vim.fn.fnamemodify(path, ":t") .. " (" .. #review_items .. " left)")
		if #review_items == 0 then
			end_review()
			return
		end
		local new_idx = math.min(old_idx, #review_items)
		refresh_qf(new_idx)
		pcall(vim.cmd, "cc")
	end, "Review: stage whole file & advance")
	map("U", function()
		if #file_undo == 0 then
			vim.notify("Review: no file stage to undo", vim.log.levels.INFO)
			return
		end
		local e = table.remove(file_undo)
		restore_index(e.snap)
		local cur = norm(e.snap.path)
		if not review_files[cur] then -- put it back into the review list
			review_files[cur] = true
			table.insert(review_items, e.item)
			refresh_qf()
		end
		vim.notify("Unstaged file " .. vim.fn.fnamemodify(e.snap.path, ":t") .. " (back in review)")
	end, "Review: undo last file stage")
end

local function clear_review_maps()
	for buf in pairs(mapped_bufs) do
		if vim.api.nvim_buf_is_valid(buf) then
			for _, lhs in ipairs({ "n", "p", "N", "P", "x", "s", "S", "u", "U", "R" }) do
				pcall(vim.keymap.del, "n", lhs, { buffer = buf })
			end
		end
	end
	mapped_bufs = {}
end

-- Attach the modal keys to each review file as you land on it (`cnext` moves you
-- between buffers, so we can't map them all up front).
vim.api.nvim_create_autocmd("BufEnter", {
	group = review_group,
	callback = function(args)
		if not review_active then
			return
		end
		local win = vim.api.nvim_get_current_win()
		local name = vim.api.nvim_buf_get_name(args.buf)
		if name ~= "" and review_files[norm(name)] then
			setup_review_maps(args.buf)
			set_winbar(win) -- show the hint in whatever window now holds a review file
		else
			restore_winbar(win) -- left a review file in this window -> drop the hint
		end
	end,
})

end_review = function()
	review_active = false
	clear_review_maps()
	restore_all_winbars()
	local MiniDiff = require("mini.diff")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local data = MiniDiff.get_buf_data(buf)
		if data and data.overlay then
			MiniDiff.toggle_overlay(buf)
		end
	end
	review_items, review_files = {}, {}
	hunk_undo, file_undo = {}, {}
	vim.cmd("cclose")
	vim.notify("Git review: ended")
end

vim.keymap.set("n", "<leader>gr", function()
	local seen, items, files = {}, {}, {}
	local function add(file_list, label)
		for _, f in ipairs(file_list) do
			if f ~= "" and not seen[f] then
				seen[f] = true
				table.insert(items, { filename = f, lnum = 1, text = label })
				files[norm(f)] = true
			end
		end
	end

	add(git_lines("git diff --name-only --diff-filter=d"), "changed")
	add(git_lines("git ls-files --others --exclude-standard"), "new")

	if #items == 0 then
		vim.notify("Git review: no changes to review", vim.log.levels.INFO)
		return
	end

	review_active = true
	review_items, review_files = items, files
	hunk_undo, file_undo = {}, {}
	vim.fn.setqflist({}, " ", { title = "Git Review", items = items })
	vim.cmd("botright vertical copen " .. math.floor(vim.o.columns * 0.3))
	vim.cmd("cfirst") -- triggers BufEnter -> modal keys + winbar attach to first file
	vim.notify(string.format("Git review: %d file(s)", #items))
end, { desc = "Git review (walk changes)" })

vim.keymap.set("n", "<leader>gn", function()
	nav(true)
end, { desc = "Git review: next file" })

vim.keymap.set("n", "<leader>gp", function()
	nav(false)
end, { desc = "Git review: previous file" })

vim.keymap.set("n", "<leader>gR", function()
	end_review()
end, { desc = "Git review end" })
