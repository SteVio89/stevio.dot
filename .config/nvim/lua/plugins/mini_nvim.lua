return {
    {
       "echasnovski/mini.icons",
       version = false
    },
    {
      "echasnovski/mini.files",
      version = false,
      opts = {
        windows = {
          preview = true,
        },
        options = {
          use_as_default_explorer = true,
        },
      },
      keys = {
        {
          "<leader>fe",
          function()
            local buffer_name = vim.api.nvim_buf_get_name(0)
            if buffer_name == "" or string.match(buffer_name, "Starter") then
              require("mini.files").open(vim.loop.cwd())
            else
              require("mini.files").open(vim.api.nvim_buf_get_name(0))
            end
          end,
          desc = "Open file explorer",
          mode = "n"
        }
      },
      config = function(_, opts)
          require("mini.files").setup(opts)
      end,
      init = function()
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
      end,
    },
    {
      "echasnovski/mini.starter",
      version = false,
      config = function()
        require("mini.starter").setup()
      end
    },
    {
      "echasnovski/mini.pairs",
      version = false,
      opts = {
        modes = { insert = true, command = true, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true,
      },
      config = function(_, opts)
        require("mini.pairs").setup(opts)
      end
    },
    {
      "echasnovski/mini.statusline",
      version = false,
      config = function()
        require("mini.statusline").setup()
      end
    },
    {
      "echasnovski/mini.misc",
      version = false,
      config = function()
        require("mini.misc").setup_auto_root()
      end
    },
    {
      "echasnovski/mini.trailspace",
      version = false,
      config = function ()
        require("mini.trailspace").setup()
      end
    },
    {
      "echasnovski/mini.cursorword",
      version = false,
      config = function()
        require("mini.cursorword").setup()
      end
    },
}
