-- require("config.set")
-- require("config.remap")
-- require("lazy_init")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("mappings")

vim.g.coq_settings = {
	auto_start = "shut-up",
	display = {
		ghost_text = {
			enabled = true,
		},
	},
}

require("lazy").setup("plugins")

if vim.g.neovide then
	-- to be done
end
