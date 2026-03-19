return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    ensure_installed = {
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
      "odin",
      "kotlin",
      "gdscript",
      "cmake",
      "yaml",
      "json",
      "toml",
      "markdown",
      "markdown_inline",
    },
    highlight = {
      enable = true,
    },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
