vim.pack.add({
	{ src = "https://github.com/m4xshen/hardtime.nvim", name = "hardtime" },
})

require("hardtime").setup({
	disable_mouse = false,
	enabled = false,
})

vim.keymap.set("n", "<leader>th", "<cmd>HardtimeToggle<cr>", { desc = "Toggle hardtime" })
