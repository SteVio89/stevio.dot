vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
vim.keymap.set("n", "<leader>tl", "<cmd>set list!<cr>", { desc = "Toggle invisible characters" })
vim.keymap.set("n", "<leader>tu", "<cmd>Undotree<cr>", { desc = "Toggle undo tree" })
vim.keymap.set("n", "<leader>op", ":lua vim.pack.update()<cr>", { desc = "Update plugins" })
vim.keymap.set("n", "<leader>tc", function()
  local enabled = not vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(enabled)
  vim.notify("Inline completion: " .. (enabled and "on" or "off"))
end, { desc = "Toggle inline completion" })
vim.keymap.set("n", "<leader>bc", "<cmd>bd<cr>", { desc = "Close current buffer" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Type '@' without Option (Option+L is taken by Aerospace window focus).
-- 'öö' never occurs in German or in code, so it never clobbers real input.
vim.keymap.set("i", "öö", "@", { desc = "Insert @" })

vim.keymap.set({ "i", "c" }, "ö5", "[", { remap = true, desc = "Insert [" })
vim.keymap.set({ "i", "c" }, "ö6", "]", { remap = true, desc = "Insert ]" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.api.nvim_create_user_command("BufOnly", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
end, {})
vim.keymap.set("n", "<leader>bC", "<cmd>BufOnly<cr>", { desc = "Close all buffers but this" })
