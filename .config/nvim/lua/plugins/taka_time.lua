vim.pack.add({
	{ src = "https://github.com/Rtarun3606k/TakaTime", name = "taka-time" },
})

require("taka-time").setup()

-- Upstream removed `-language` before shipping a binary that detects it, so entries
-- log as "unknown". Patch after setup(): ensure_binary() shares this function.
local utils = require("taka-time.utils")
local get_binary_path = utils.get_binary_path

vim.env.TAKA_UPLOAD_BIN = get_binary_path(utils.BinaryEnum.UPLOAD)

utils.get_binary_path = function(binary)
	if binary ~= utils.BinaryEnum.UPLOAD then
		return get_binary_path(binary)
	end

	local filetype = vim.bo.filetype
	vim.env.TAKA_LANGUAGE = filetype ~= "" and filetype or "unknown"

	return vim.fn.stdpath("config") .. "/bin/taka-upload-lang"
end

vim.keymap.set("n", "<leader>ot", "<cmd>TakaDash<cr>", { desc = "Open Taka-Time Dashboard" })
