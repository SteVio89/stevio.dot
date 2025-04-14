return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "vim", "regex", "lua", "bash", "markdown", "markdown_inline", "go", "rust",
        }
      })
    end
  }
}
