return {
  "saxon1964/neovim-tips",
  version = "*",
  lazy = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "MeanderingProgrammer/render-markdown.nvim",
  },
  opts = {
    daily_tip = 0,
    bookmark_symbol = "🌟 ",
  },
  keys = {
    { "<leader>no", ":NeovimTips<CR>", desc = "Neovim tips" },
    { "<leader>nr", ":NeovimTipsRandom<CR>", desc = "Show random tip" },
    { "<leader>ne", ":NeovimTipsEdit<CR>", desc = "Edit your tips" },
    { "<leader>na", ":NeovimTipsAdd<CR>", desc = "Add your tip" },
    { "<leader>np", ":NeovimTipsPdf<CR>", desc = "Open tips PDF" },
  },
}
