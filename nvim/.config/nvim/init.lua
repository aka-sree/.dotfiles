-- ========================================================================== --
-- 1. BOOTSTRAP LAZY.NVIM
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 2. GLOBAL SETTINGS (Robotics & HFT Optimized)
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
-- 3. PLUGIN STACK
-- ========================================================================== --
require("lazy").setup({
  spec = {
    -- IMPORT EXTERNAL FILES (This solves your "not found" issues)
    { import = "plugins" },

    -- UI & Theme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    
    -- ICON ENGINE
    { 
      "echasnovski/mini.icons", 
      opts = { style = 'glyph' },
      config = function(_, opts)
        local icons = require('mini.icons')
        icons.setup(opts)
        icons.mock_nvim_web_devicons()
      end
    },

    -- NAVIGATION & TERMINAL
    { "christoomey/vim-tmux-navigator", lazy = false },
    { "echasnovski/mini.pairs", config = true },
    { "echasnovski/mini.statusline", config = true },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "kdheepak/lazygit.nvim", cmd = { "LazyGit" } },

    {
      "akinsho/toggleterm.nvim",
      version = "*",
      opts = {
        open_mapping = [[<c-\>]],
        direction = 'float',
        float_opts = { border = 'curved' },
      }
    },

    -- FILE EXPLORER (The Modern Fixed Block)
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      live_filter = { 
        prefix = "[Search]: ", 
        always_show_folders = false 
      },
      renderer = {
        indent_markers = { enable = true },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            folder = {
              arrow_closed = "⏵",
              arrow_open = "⏷",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
          },
        },
      },
    }
  },

    -- TREESITTER (The Safe Block)
    { 
      "nvim-treesitter/nvim-treesitter", 
      build = ":TSUpdate", 
      config = function() 
        -- This checks if the module exists before trying to use it
        local ok, configs = pcall(require, "nvim-treesitter.configs")
        if not ok then return end 
        
        configs.setup({
          ensure_installed = { "cpp", "c", "lua", "cmake", "vim", "vimdoc", "markdown" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end 
    },
   
    -- LSP, COMPLETION & DEBUGGING
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },
    {
      "hrsh7th/nvim-cmp",
      dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
      config = function()
        local cmp = require('cmp')
        cmp.setup({
          snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping.select_next_item(),
          }),
          sources = { { name = 'nvim_lsp' } }
        })
      end
    },
    
    {
      "mfussenegger/nvim-dap",
      dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
      config = function()
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup()
        dap.configurations.cpp = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function() return vim.fn.input('Path: ', vim.fn.getcwd() .. '/', 'file') end,
            cwd = '${workspaceFolder}',
            stopOnEntry = false,
          },
        }
        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      end
    },
  }
})

-- ========================================================================== --
-- 4. NATIVE LSP SETUP (Neovim 0.11+)
-- ========================================================================== --
-- Clangd setup for Senior Embedded/HFT work
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
})
vim.lsp.enable("clangd")

-- ========================================================================== --
-- 5. KEYMAPS (The Toolbox)
-- ========================================================================== --
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<leader>gg', ':LazyGit<CR>')

-- FIXED TELESCOPE KEYMAPS (Using function wrappers to prevent "module not found")
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end)
vim.keymap.set('n', '<leader>fz', function() require('telescope.builtin').current_buffer_fuzzy_find() end)

-- LSP & Debugging
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<leader>a', '<cmd>ClangdSwitchSourceHeader<cr>')

-- C++ Fast Compile (F9)
vim.keymap.set('n', '<F9>', function()
  vim.cmd('write')
  local out = vim.fn.expand('%:p:r')
  vim.cmd(string.format("!g++ -O3 %% -o %s && %s", out, out))
end)

vim.cmd.colorscheme "catppuccin"
