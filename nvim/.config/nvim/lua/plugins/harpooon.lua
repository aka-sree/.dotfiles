return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-e>", desc = "Harpoon menu" },
    { "<leader>ha", desc = "Harpoon add" },
    { "<leader>n", desc = "Harpoon remove" },
    { "<leader>nn", desc = "Harpoon clear" },
    { "<C-j>", desc = "Harpoon 1" },
    { "<C-k>", desc = "Harpoon 2" },
    { "<C-l>", desc = "Harpoon 3" },
    { "<C-;>", desc = "Harpoon 4" },
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
    vim.keymap.set("n", "<leader>n", function() harpoon:list():remove() end)
    vim.keymap.set("n", "<leader>nn", function() harpoon:list():clear() end, { desc = "Clear Harpoon List" })
    vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end)
  end,
}
