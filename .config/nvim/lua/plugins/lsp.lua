return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
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
                "rust_analyzer",
                "bashls",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            -- configure lsp server here
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup({})
            --TODO: init missing lsp
            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Goto definition" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Goto reference" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
            vim.keymap.set('n', '<leader>cr', function() vim.lsp.buf.rename() end, { desc = "Rename" })
        end
    },
}
