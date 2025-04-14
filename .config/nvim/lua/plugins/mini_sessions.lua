return {
  "echasnovski/mini.sessions",
  version = false,
  config = function ()
    require("mini.sessions").setup({
      autowrite = true
    })
    vim.keymap.set("n", "<leader>ws", function()
      vim.cmd('wa')
      require('mini.sessions').write()
      require('mini.sessions').select()
    end, { noremap = true, silent = true, desc = 'Safe and switch session' })
    vim.keymap.set("n", "<leader>ww", function()
      local cwd = vim.fn.getcwd()
      local last_folder = cwd:match("([^/]+)$")
      require('mini.sessions').write(last_folder)
    end, { noremap = true, silent = true, desc = 'Save session' })
    vim.keymap.set("n", "<leader>wf", function()
      require('mini.sessions').select()
    end, { noremap = true, silent = true, desc = 'Find session' })
  end
}
