-- ========================================================================== --
-- 1. BOOTSTRAP LAZY.NVIM
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 2. GLOBAL SETTINGS
-- ========================================================================== --
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.autowrite = true
vim.opt.undofile = true
vim.opt.title = false

-- ========================================================================== --
-- 3. PLUGIN STACK (all specs in lua/plugins/ and lua/plugins.lua)
-- ========================================================================== --
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- ========================================================================== --
-- 4. CORE MODULES
-- ========================================================================== --
require("sree.core.options")
require("sree.core.keymaps")

-- C++ Fast Compile (F9)
vim.keymap.set('n', '<F9>', function()
  vim.cmd('write')
  local out = vim.fn.expand('%:p:r')
  vim.cmd(string.format("!g++ -O3 %% -o %s && %s", out, out))
end)
