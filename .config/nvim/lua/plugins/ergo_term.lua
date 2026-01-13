return {
  "waiting-for-dev/ergoterm.nvim",
  version = false,
  config = function()
    require("ergoterm").setup({
      terminal_defaults = {
        cleanup_on_success = false,
        layout = "below",
      },
      picker = {
        picker = "telescope",
        extra_select_actions = {
          ["<C-d>"] = {
            fn = function(term)
              term:cleanup()
            end,
            desc = "Delete terminal",
          },
        },
      },
    })
  end,
}
