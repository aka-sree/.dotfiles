-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Write all
vim.keymap.set('n', 'wa', ':wa<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<C-p>", "<cmd>silent !~/.config/bin/tmux-sessionizer.sh<CR>")

vim.keymap.set('n', '<CR>', 'o<ESC>', { noremap = true})

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste text without emptying yank buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Reload Config
vim.keymap.set('n', "<space><space>x", "<cmd>source ~/.config/nvim/init.lua<CR>")
vim.keymap.set('v', "<space>x", ":lua<CR>")

