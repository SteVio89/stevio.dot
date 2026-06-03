require("options")
require("mappings")

vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")

require("plugins.shared")
require("plugins.catppuccin")
require("plugins.transparent")
require("plugins.scrollEOF")
require("plugins.mini_nvim")
require("plugins.mini_files")
require("plugins.conform")
require("plugins.neogit")
require("plugins.rachartier_plugs")
require("plugins.fzf")
require("plugins.completion")
require("plugins.lsp")
require("plugins.treesitter")

if vim.g.neovide then
	require("plugins.direnv")
	require("neovide")
end
