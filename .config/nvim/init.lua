require("options")
require("mappings")

vim.cmd("packadd nvim.undotree")
vim.cmd("packadd nvim.difftool")


require("plugins.shared")
require("plugins.catppuccin")
require("plugins.transparent")
require("plugins.scrollEOF")
require("plugins.mini_nvim")
require("plugins.agentic")
require("plugins.conform")
require("plugins.neogit")
require("plugins.rachartier_plugs")
require("plugins.render_markdown")
require("plugins.fzf")
require("plugins.completion")
require("plugins.lsp")
require("plugins.treesitter")

if vim.g.neovide then
  -- to be done
end
