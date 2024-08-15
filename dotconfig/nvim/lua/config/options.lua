-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.winbar = "%=%m %f"

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

vim.cmd([[
  hi illuminatedWord guibg=#424270 gui=none
  hi illuminatedCurWord guibg=#424270 gui=none
]])

vim.diagnostic.config({
  float = {
    border = "rounded",
    source = true,
    update_in_insert = "true",
  },
})
