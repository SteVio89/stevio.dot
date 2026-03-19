return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    spec = {
      { "<leader>a", group = "AI" },
      { "<leader>f", group = "file" },
      { "<leader>b", group = "buffer" },
      { "<leader>g", group = "git" },
      { "<leader>c", group = "code" },
      { "<leader>o", group = "other" },
      { "<leader>z", group = "zen" },
      { "<leader>s", group = "sessions" },
      { "<leader>n", group = "Neovim Tips" },
    },
  },
}
