return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        spec = {
            { "<leader>f", group = "file" },
            -- { "<leader>t", group = "trouble" },
            -- { "<leader>z", group = "zen" },
            -- { "<leader>w", group = "sessions" },
            -- { "<leader>o", group = "other" },
        }
    },
}
