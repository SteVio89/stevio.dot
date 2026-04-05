vim.pack.add({
  { src = 'https://github.com/rachartier/tiny-inline-diagnostic.nvim', name = 'inline-diagnostic' },
  { src = 'https://github.com/rachartier/tiny-code-action.nvim',       name = 'code-action' },
})

require("tiny-inline-diagnostic").setup()
vim.diagnostic.config({ virtual_text = false })

require("tiny-code-action").setup({})
