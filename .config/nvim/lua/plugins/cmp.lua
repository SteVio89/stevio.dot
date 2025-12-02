return {
  "hrsh7th/nvim-cmp",
  version = false,
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "onsails/lspkind-nvim",
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    cmp.setup({
      performance = {
        debounce = 500,
      },
      completion = {
        completeopt = "menu,menuone,noinsert",
        autocomplete = {
          cmp.TriggerEvent.TextChanged,
        },
      },
      view = {
        docs = {
          auto_open = true,
        },
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<CR>"] = cmp.mapping({
          i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          s = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-c>"] = cmp.mapping.abort(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },
        { name = "buffer",   priority = 500, keyword_length = 3 },
        { name = "path",     priority = 250 },
      }),
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
