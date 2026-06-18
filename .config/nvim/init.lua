require("options")
require("mappings")
require("unsaved")

vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")

require("plugins.shared")
require("plugins.catppuccin")
require("plugins.transparent")
require("plugins.scrollEOF")
require("plugins.mini_nvim")
require("plugins.mini_files")
require("plugins.mini_diff")
require("plugins.conform")
require("plugins.neogit")
require("plugins.rachartier_plugs")
require("plugins.fzf")
require("plugins.completion")
require("plugins.lsp")
require("plugins.lint")
require("plugins.treesitter")
require("plugins.taka_time")
require("plugins.hardtime")

if vim.g.neovide then
	require("plugins.direnv")
	require("neovide")
	local function paste()
		vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
	end
	vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste, { silent = true, desc = "Paste" })
end
