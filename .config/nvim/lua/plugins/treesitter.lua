vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", name = "treesitter-textobjects" },
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

local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })

-- Queries ship with the plugin repo, but parsers are separately pinned .so builds
-- that install() skips once present, so they only track the repo if forced.
vim.api.nvim_create_autocmd("PackChanged", {
	group = group,
	callback = function(ev)
		if ev.data.spec.name ~= "treesitter" or ev.data.kind ~= "update" then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd("treesitter")
		end
		require("nvim-treesitter").update(nil, { summary = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
		local ok, added = pcall(vim.treesitter.language.add, lang)
		if not (ok and added) then
			return
		end
		vim.treesitter.start(ev.buf, lang)
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		if vim.api.nvim_get_current_buf() == ev.buf then
			vim.wo[0][0].foldmethod = "expr"
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
	end,
})
