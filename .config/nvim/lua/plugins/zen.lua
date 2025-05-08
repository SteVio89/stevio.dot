return {
    {
        "folke/zen-mode.nvim",
        config = function()
            vim.keymap.set("n", "<leader>zz", function()
                require("zen-mode").setup {
                    window = {
                        width = 90,
                        options = {}
                    },
                }
                require("zen-mode").toggle()
            end, { desc = "toggle zen" })
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    {
        "folke/twilight.nvim",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    }
}
