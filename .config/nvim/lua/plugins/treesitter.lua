return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects"
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua", "vim", "bash", "go", "rust"
            },
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            }
        })
    end
}
