require("mini.diff").setup({ view = { style = "sign" } })

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

local review_active = false
local review_group = vim.api.nvim_create_augroup("GitReview", { clear = true })

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

vim.keymap.set("n", "<leader>gr", function()
	local seen, items = {}, {}
	local function add(file_list, label)
		for _, f in ipairs(file_list) do
			if f ~= "" and not seen[f] then
				seen[f] = true
				table.insert(items, { filename = f, lnum = 1, text = label })
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
	vim.fn.setqflist({}, " ", { title = "Git Review", items = items })
	vim.cmd("botright vertical copen " .. math.floor(vim.o.columns * 0.3))
	vim.cmd("cfirst")
	vim.notify(string.format("Git review: %d file(s) — <leader>gn/<leader>gp to step, <leader>gR to end", #items))
end, { desc = "Git review (walk changes)" })

vim.keymap.set("n", "<leader>gn", function()
	if not pcall(vim.cmd, "cnext") then
		pcall(vim.cmd, "cfirst")
	end
end, { desc = "Git review: next file" })

vim.keymap.set("n", "<leader>gp", function()
	if not pcall(vim.cmd, "cprevious") then
		pcall(vim.cmd, "clast")
	end
end, { desc = "Git review: previous file" })

vim.keymap.set("n", "<leader>gR", function()
	review_active = false
	local MiniDiff = require("mini.diff")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local data = MiniDiff.get_buf_data(buf)
		if data and data.overlay then
			MiniDiff.toggle_overlay(buf)
		end
	end
	vim.cmd("cclose")
	vim.notify("Git review: ended")
end, { desc = "Git review end" })
