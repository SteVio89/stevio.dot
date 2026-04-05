vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', name = 'treesitter' },
})

require("nvim-treesitter.config").setup({
  ensure_installed = {
    "lua", "vim", "vimdoc", "query",
    "bash", "go", "rust", "zig",
    "c", "cpp", "kotlin",
    "yaml", "json", "toml", "nix",
    "markdown", "markdown_inline",
  },
  highlight = { enable = true },
  indent = { enable = true },
})
