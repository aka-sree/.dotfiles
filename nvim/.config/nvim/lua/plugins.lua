return {
  { "numToStr/Comment.nvim", opts = {} },

  -- Icon engine (mock nvim-web-devicons so other plugins work)
  {
    "echasnovski/mini.icons",
    lazy = false,
    priority = 100,
    opts = { style = "glyph" },
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      icons.mock_nvim_web_devicons()
    end,
  },

  -- Auto-pairs on insert
  { "echasnovski/mini.pairs", event = "InsertEnter", config = true },

  -- Tmux pane navigation (must be eager for keybinds)
  { "christoomey/vim-tmux-navigator", lazy = false },

  -- Floating terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { [[<c-\>]], desc = "Toggle Terminal" } },
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = { border = "curved" },
    },
  },

  -- Lazygit (only loads on command)
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    keys = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" } },
  },
}

