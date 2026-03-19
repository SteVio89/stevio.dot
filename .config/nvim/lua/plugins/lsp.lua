return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "gdtoolkit",
          "kotlin-lsp",
          "stylua",
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = {
        "gopls",
        "lua_ls",
        "bashls",
        "zls",
        "ols",
        "qmlls",
        "clangd",
        "cmake",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    config = function()
      vim.lsp.config("lua_ls", {})
      vim.lsp.config("gopls", {})
      vim.lsp.config("bashls", {})
      vim.lsp.config("zls", {})
      vim.lsp.config("ols", {})
      vim.lsp.config("qmlls", {})
      vim.lsp.config("gdscript", {})
      vim.lsp.config("clangd", {})
      vim.lsp.config("cmake", {})
      vim.lsp.config("kotlin-lsp", {})

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("bashls")
      vim.lsp.enable("zls")
      vim.lsp.enable("ols")
      vim.lsp.enable("qmlls")
      vim.lsp.enable("gdscript")
      vim.lsp.enable("clangd")
      vim.lsp.enable("cmake")
      vim.lsp.enable("kotlin-lsp")

      vim.lsp.inlay_hint.enable()

      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show lsp hover" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
      vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Goto definition" })
      vim.keymap.set("n", "<leader>ca", function()
        require("tiny-code-action").code_action()
      end, { desc = "Code action" })
      vim.keymap.set("n", "<leader>cf", function()
        require("conform").format({ async = true })
      end, { desc = "Code format" })
      vim.keymap.set("n", "<leader>cr", function()
        vim.lsp.buf.rename()
      end, { desc = "Rename" })
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = "never" },
                lifetimeElisionHints = { enable = "never", useParameterNames = false },
                maxLength = 25,
                parameterHints = { enable = true },
                reborrowHints = { enable = "never" },
                renderColons = true,
                typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
              },
            },
          },
        },
      }
    end,
  },
}
