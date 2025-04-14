return {
    "echasnovski/mini.files",
    version = '*',
    dependencies = {
        { "echasnovski/mini.icons", version = "*" },
    },
    config = function()
        require("mini.files").setup({
            windows = {
                preview = true
            },
            options = {
                use_as_default_explorer = true,
            }
        })
        vim.keymap.set("n", "<leader>fe", function()
            local buffer_name = vim.api.nvim_buf_get_name(0)
            if buffer_name == "" or string.match(buffer_name, "Starter") then
                require("mini.files").open(vim.loop.cwd())
            else
                require("mini.files").open(vim.api.nvim_buf_get_name(0))
            end
        end, { desc = "Open file explorer" })
    end,
    init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
}
