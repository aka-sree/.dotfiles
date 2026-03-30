return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- Pin to last release that compiles with cc/gcc (no tree-sitter CLI needed).
    -- Your system has GLIBC 2.35; the new tree-sitter CLI requires GLIBC 2.39.
    tag = 'v0.9.3',
    build = ':TSUpdate',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'c', 'cpp', 'cmake',
          'lua', 'vim', 'vimdoc',
          'bash', 'markdown', 'json',
        },
        auto_install = false,
        highlight = { enable = true },
        indent = {
          enable = true,
          disable = { 'c', 'cpp' },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true, lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true, set_jumps = true,
            goto_next_start     = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
            goto_next_end       = { [']M'] = '@function.outer', [']['] = '@class.outer' },
            goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
            goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
          },
          swap = {
            enable = true,
            swap_next     = { ['<leader>a'] = '@parameter.inner' },
            swap_previous = { ['<leader>A'] = '@parameter.inner' },
          },
        },
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}

