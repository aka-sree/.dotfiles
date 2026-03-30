return {
  url = "https://codeberg.org/andyg/leap.nvim",
  dependencies = { "tpope/vim-repeat" },
  keys = {
    { "s", mode = { "n", "x", "o" }, desc = "Leap forward" },
    { "S", mode = { "n", "x", "o" }, desc = "Leap backward" },
  },
  config = function()
    require("leap").add_default_mappings()
  end,
}
