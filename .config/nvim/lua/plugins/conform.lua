vim.pack.add({
  { src = 'https://github.com/stevearc/conform.nvim', name = 'conform' },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "goimports", "gofmt" },
    rust = { "rustfmt" },
    kotlin = { "ktfmt" },
    zig = { "zigfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
  },
  format_on_save = function(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match("/node_modules/") then
      return
    end
    return {
      timeout_ms = 2000,
      lsp_format = "fallback",
      quiet = true,
    }
  end,
  notify_on_error = true,
  notify_no_formatters = false,
})
