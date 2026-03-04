return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slant",
      show_buffer_close_icons = true,
      show_close_icon = false,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          separator = true,
        },
      },
    },
  },
  keys = {
    { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev Buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next Buffer" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin Buffer" },
    { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close Non-Pinned Buffers" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close Other Buffers" },
    { "<leader>bd", "<cmd>bdelete<CR>", desc = "Close Buffer" },
  },
}
