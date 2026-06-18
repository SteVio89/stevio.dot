vim.pack.add({
	{ src = "https://github.com/m4xshen/hardtime.nvim", name = "hardtime" },
})

require("hardtime").setup()

vim.keymap.set("n", "<leader>oh", "<cmd>HardtimeToggle<cr>", { desc = "Toggle hardtime" })
