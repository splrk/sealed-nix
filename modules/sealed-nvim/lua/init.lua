vim.opt.number = true
vim.opt.expandtab = false
vim.opt.shiftwidth = 0
vim.opt.tabstop = 2
vim.opt.softtabstop = -1
vim.opt.list = true
vim.opt.listchars = { eol = '.', tab = "│ ", trail = '~' }

require('onedark').setup {
    style = 'deep'
}
require('onedark').load()

