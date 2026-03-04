-- Must be first: enables bytecode caching for all subsequent requires
vim.loader.enable()

require("sree.core.options")
require("sree.core.keymaps")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Clang-format command using project-local EmbeddedTeam.clang-format
vim.api.nvim_create_user_command("FormatCurrentBufferWithClang", function()
  local filepath = vim.fn.shellescape(vim.fn.expand("%:p"))
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
    return vim.notify("Not inside a Git repo.", vim.log.levels.WARN)
  end

  local config = git_root .. "/EmbeddedTeam.clang-format"
  local style
  if vim.fn.filereadable(config) == 1 then
    style = "-style=file:" .. config
  else
    local found = vim.fn.systemlist("find " .. vim.fn.shellescape(git_root) .. " -name EmbeddedTeam.clang-format")[1]
    style = (found and found ~= "") and ("-style=file:" .. found) or "-style=file"
  end

  vim.fn.system("clang-format -i " .. style .. " " .. filepath)
  vim.cmd("edit!")
end, { desc = "Format current buffer using EmbeddedTeam.clang-format" })

vim.keymap.set("n", "<leader>cf", "<cmd>FormatCurrentBufferWithClang<CR>", { desc = "Clang Format Current File" })
