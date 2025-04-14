return {
  "nvim-telescope/telescope.nvim",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "debugloop/telescope-undo.nvim",
  },
  config = function()
    require("telescope").setup({})
    require("telescope").load_extension("undo")
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Seach files" })
    vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Seach git files" })
    vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
  end
}
