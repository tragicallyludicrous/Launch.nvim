local M = {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "mfussenegger/nvim-dap-python",
  },
}

function M.config()
  local dap = require "dap"
  local dapui = require "dapui"
  local wk = require "which-key"
  local icons = require "user.icons"

  require("mason-nvim-dap").setup {
    ensure_installed = { "python" },
    automatic_installation = true,
    handlers = {},
  }

  require("nvim-dap-virtual-text").setup {}

  dapui.setup()

  local mason_debugpy = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
  if vim.fn.executable(mason_debugpy) == 1 then
    require("dap-python").setup(mason_debugpy)
  else
    require("dap-python").setup "python3"
  end

  dap.listeners.before.attach.dapui_config = function() dapui.open() end
  dap.listeners.before.launch.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

  vim.fn.sign_define("DapBreakpoint", { text = icons.ui.Bug, texthl = "DiagnosticError", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = icons.ui.Bug, texthl = "DiagnosticWarn", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", numhl = "" })
  vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", numhl = "" })

  wk.add {
    { "<leader>db", function() dap.toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dB", function() dap.set_breakpoint(vim.fn.input "Condition: ") end, desc = "Conditional Breakpoint" },
    { "<leader>dc", function() dap.continue() end, desc = "Continue / Start" },
    { "<leader>di", function() dap.step_into() end, desc = "Step Into" },
    { "<leader>do", function() dap.step_over() end, desc = "Step Over" },
    { "<leader>dO", function() dap.step_out() end, desc = "Step Out" },
    { "<leader>dr", function() dap.repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>du", function() dapui.toggle() end, desc = "Toggle DAP UI" },
    { "<leader>dt", function() dap.terminate() end, desc = "Terminate" },
    { "<leader>dl", function() dap.run_last() end, desc = "Run Last" },
  }
end

return M
