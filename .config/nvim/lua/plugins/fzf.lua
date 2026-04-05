vim.pack.add({
  { src = 'https://github.com/ibhagwan/fzf-lua', name = 'fzf' },
})

local fzf = require("fzf-lua")
fzf.setup({})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find file" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep files" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Find buffer" })
vim.keymap.set("n", "<leader>fu", fzf.changes, { desc = "Undo history" })
vim.keymap.set("n", "<leader>fd", function()
  fzf.diagnostics_document()
end, { desc = "Diagnostics this buffer" })
vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Diagnostics all buffers" })
vim.keymap.set("n", "<leader>fr", fzf.lsp_references, { desc = "Reference under the cursor" })
vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Symbols this buffer" })
vim.keymap.set("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Symbols all buffers" })
vim.keymap.set("n", "<leader>ft", function()
  fzf.grep({ search = "TODO|FIXME|HACK|NOTE" })
end, { desc = "Project Todos" })
