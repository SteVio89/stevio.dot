vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.swapfile = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.cursorline = false
opt.termguicolors = true
opt.signcolumn = "yes"
opt.backspace = "indent,eol,start"
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.autoread = true
opt.smoothscroll = true
opt.inccommand = "split"
opt.breakindent = true
opt.updatetime = 250
opt.fillchars = { eob = " " }

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
    if vim.v.event.operator == "y" then
      vim.fn.setreg("+", vim.fn.getreg('"'))
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  command = "checktime",
})

-- Reset horizontal scroll (leftcol) when a new line is created in insert
-- mode, so a short new line after a sidescrolled long line is shown from
-- column 0 instead of inheriting the offset.
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.b._line_count_on_enter = vim.api.nvim_buf_line_count(0)
  end,
})
vim.api.nvim_create_autocmd("TextChangedI", {
  callback = function()
    local prev = vim.b._line_count_on_enter or 0
    local cur = vim.api.nvim_buf_line_count(0)
    if cur > prev then
      local view = vim.fn.winsaveview()
      if view.leftcol > 0 then
        view.leftcol = 0
        vim.fn.winrestview(view)
      end
    end
    vim.b._line_count_on_enter = cur
  end,
})
