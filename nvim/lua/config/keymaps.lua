-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Increment/decrement integer under cursor
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete word backwards
keymap.set("n", "dw", "vb_d")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Jumplist
keymap.set("n", "<C-m>", "C-i>", opts)

-- Next tab
keymap.set("n", "te", ":tabedit", opts)
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move current/selected line up
keymap.set("n", "<C-Up>", ":m .-2<CR>==", opts)
keymap.set("x", "<C-Up>", ":move '<-2<CR>gv=gv", opts)

-- Move current/selected line down
keymap.set("n", "<C-Down>", ":m .+1<CR>==", opts)
keymap.set("x", "<C-Down>", ":move '>+1<CR>gv=gv", opts)

-- Exit insert mode with ';;'
keymap.set("i", ";;", "<Esc>", opts)

-- Exit auto-closed something with ',,'
keymap.set("i", ",,", "<Right>", opts)

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next()
end, opts)
