return {
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = {
          width = 150,
          options = {},
        },
      })
      vim.keymap.set("n", "<leader>zz", function()
        require("zen-mode").toggle()
      end, { desc = "toggle zen" })
    end,
  },
  {
    "folke/twilight.nvim",
    opts = {},
  },
}
