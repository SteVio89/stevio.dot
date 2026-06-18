vim.pack.add({
	{ src = "https://github.com/Rtarun3606k/TakaTime", name = "taka-time" },
})

require("taka-time").setup()

vim.keymap.set("n", "<leader>td", "<cmd>TakaDash<cr>", { desc = "Open Taka-Time Dashboard" })
