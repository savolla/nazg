-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Better escape
vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("n", "<ESC>", "<ESC>:noh<CR>")
