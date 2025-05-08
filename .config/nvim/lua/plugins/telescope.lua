return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x", --current version was 0.1.8
    dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
    },
    config = function()
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find file" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffer" })
        vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "Undo history" })
    end

}
