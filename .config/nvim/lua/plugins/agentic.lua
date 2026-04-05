vim.pack.add({
  { src = 'https://github.com/carlos-algms/agentic.nvim', name = 'agentic' },
})

require("agentic").setup({
  provider = "claude-agent-acp",
  diff_preview = "split",
})

vim.keymap.set({ "n", "v" }, "<leader>ao", function()
  require("agentic").open({ auto_add_to_context = false })
end, { desc = "Open Agentic chat" })

vim.keymap.set({ "n", "v" }, "<leader>aO", function()
  require("agentic").open()
end, { desc = "Open Agentic chat with context" })

vim.keymap.set({ "n", "v" }, "<leader>an", function()
  require("agentic").new_session_with_provider({ auto_add_to_context = false })
end, { desc = "New Agentic session" })

vim.keymap.set({ "n", "v" }, "<leader>aN", function()
  require("agentic").new_session_with_provider()
end, { desc = "New Agentic session with context" })
