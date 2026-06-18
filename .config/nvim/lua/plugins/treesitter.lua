vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
})

require("nvim-treesitter").setup()

require("nvim-treesitter").install({
	"lua",
	"vim",
	"vimdoc",
	"query",
	"bash",
	"go",
	"rust",
	"zig",
	"c",
	"cpp",
	"kotlin",
	"yaml",
	"json",
	"toml",
	"nix",
	"markdown",
	"markdown_inline",
	"typescript",
	"tsx",
	"sql",
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
		local ok, added = pcall(vim.treesitter.language.add, lang)
		if not (ok and added) then
			return
		end
		vim.treesitter.start(ev.buf, lang)
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
