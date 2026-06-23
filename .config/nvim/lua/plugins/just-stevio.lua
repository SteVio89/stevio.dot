vim.pack.add({
	{ src = "https://github.com/SteVio89/just-stevio.nvim", name = "just-stevio" },
})

require("just-stevio").setup({
	keymaps = { open = "<leader>j" },
})

vim.keymap.set("n", "<leader>j", function()
	require("just-stevio").pick()
end, { desc = "Just: pick and run a recipe" })
