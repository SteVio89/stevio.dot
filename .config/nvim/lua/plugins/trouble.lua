return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>td",
      "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<cr>",
      desc = "Open diagnostics file",
      mode = "n"
    },
    {
      "<leader>tD",
      "<cmd>Trouble diagnostics toggle focus=false<cr>",
      desc = "Open diagnostics",
      mode = "n"
    }
  }
}
