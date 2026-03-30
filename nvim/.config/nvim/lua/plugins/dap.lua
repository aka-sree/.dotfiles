-- Debug Adapter Protocol (loads only when debugging)
return {
  "mfussenegger/nvim-dap",
  dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()
    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function() return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  end,
}
