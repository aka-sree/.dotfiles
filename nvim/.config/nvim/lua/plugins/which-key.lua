return {
  'folke/which-key.nvim',
  event = "VeryLazy",
  opts = {},
  config = function()
    local wk = require('which-key')
    wk.add({
      { '<leader>b', group = 'Buffer' },
      { '<leader>f', group = 'Find' },
      { '<leader>c', group = 'Code' },
      { '<leader>d', group = 'Document' },
      { '<leader>g', group = 'Git' },
      { '<leader>r', group = 'Rename' },
      { '<leader>s', group = 'Search' },
      { '<leader>w', group = 'Workspace' },
      { '<leader>x', group = 'Trouble' },
    })
  end,
}
