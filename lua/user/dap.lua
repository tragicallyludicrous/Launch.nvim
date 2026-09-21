local M = {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "igorlfs/nvim-dap-view",
    "jay-babu/mason-nvim-dap.nvim",
    "mfussenegger/nvim-dap-python",
  },
}

function M.config()
  local dap = require "dap"
  local dv = require "dap-view"
  local wk = require "which-key"
  local icons = require "user.icons"

  require("mason-nvim-dap").setup {
    ensure_installed = { "python" },
    automatic_installation = true,
  }

  dv.setup {
    winbar = {
      -- One window, tabbed. "console" is not in the default sections; including
      -- it keeps the debuggee's terminal inside this window instead of letting
      -- nvim-dap open a separate `belowright new` split beside it.
      sections = { "scopes", "watches", "breakpoints", "threads", "exceptions", "repl", "console" },
      default_section = "scopes",
      controls = { enabled = true },
    },
    -- Built-in, replaces nvim-dap-virtual-text. Needs a treesitter parser for
    -- the buffer's language; it no-ops where there isn't one.
    virtual_text = { enabled = true },
    -- Open on launch/attach, but never auto-close: the panes and the program's
    -- console output survive the debuggee exiting. Close it with <leader>du.
    auto_toggle = "open",
  }

  local mason_debugpy = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
  if vim.fn.executable(mason_debugpy) == 1 then
    require("dap-python").setup(mason_debugpy)
  else
    require("dap-python").setup "python3"
  end

  -- Extra Python launch configs, appended after dap-python registers its four.
  --
  -- The stock `file` config is program = "${file}", which re-expands against
  -- whichever buffer is focused -- including inside dap.run_last(), which
  -- stores the config *before* expansion. So once you step into a module and
  -- edit it, <leader>dl relaunches that module instead of your entry point.
  -- These two ask once and then stay put; :DapEntryPoint / :DapModule change
  -- the remembered answer.
  local entry_program, entry_module

  local function ask(prompt, default, completion)
    local input = vim.fn.input { prompt = prompt, default = default or "", completion = completion }
    return input ~= "" and input or nil
  end

  vim.list_extend(dap.configurations.python, {
    {
      type = "python",
      request = "launch",
      name = "entrypoint",
      program = function()
        entry_program = entry_program or ask("Entry point: ", vim.fn.expand "%:p", "file")
        return entry_program or dap.ABORT
      end,
      console = "integratedTerminal",
      cwd = "${workspaceFolder}",
    },
    {
      type = "python",
      request = "launch",
      name = "module",
      module = function()
        entry_module = entry_module or ask "Module: "
        return entry_module or dap.ABORT
      end,
      console = "integratedTerminal",
      cwd = "${workspaceFolder}",
    },
  })

  vim.api.nvim_create_user_command("DapEntryPoint", function()
    entry_program = ask("Entry point: ", entry_program or vim.fn.expand "%:p", "file")
    vim.notify("dap entrypoint: " .. (entry_program or "cleared"))
  end, { desc = "Set the file the `entrypoint` config launches" })

  vim.api.nvim_create_user_command("DapModule", function()
    entry_module = ask("Module: ", entry_module)
    vim.notify("dap module: " .. (entry_module or "cleared"))
  end, { desc = "Set the module the `module` config launches" })

  vim.fn.sign_define("DapBreakpoint", { text = icons.ui.Bug, texthl = "DiagnosticError", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = icons.ui.Bug, texthl = "DiagnosticWarn", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", numhl = "" })
  vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", numhl = "" })

  -- jump_to_view only works once the view window exists, so open it first.
  -- state.winnr is dap-view internals, but it's the only handle on that.
  local function show(section)
    return function()
      local state = require "dap-view.state"
      if not (state.winnr and vim.api.nvim_win_is_valid(state.winnr)) then
        dv.open()
      end
      dv.jump_to_view(section)
    end
  end

  -- Stepping submode. <leader>ds once, then tap single keys; anything else
  -- exits. Each step waits for the adapter to come back to a stop before
  -- accepting the next key, so fast tapping doesn't drop steps.
  local function step_mode()
    if not dap.session() then
      vim.notify("No debug session", vim.log.levels.WARN)
      return
    end
    local actions = {
      o = dap.step_over,
      i = dap.step_into,
      O = dap.step_out,
      c = dap.continue,
      C = dap.run_to_cursor,
      j = dap.down,
      k = dap.up,
      e = function()
        dv.hover()
      end,
    }
    local hint = "-- STEP --  o:over  i:into  O:out  c:continue  C:to-cursor  j/k:frame  e:eval  q:quit"
    while dap.session() do
      vim.cmd.redraw()
      vim.api.nvim_echo({ { hint, "ModeMsg" } }, false, {})
      local ok, ch = pcall(vim.fn.getcharstr)
      vim.api.nvim_echo({ { "" } }, false, {})
      local action = ok and actions[ch]
      if not action then
        break
      end
      action()
      -- Wait for the adapter to come back to a stop *and* for the frame to be
      -- fetched, so the redrawn position is the new one before the next key.
      vim.wait(2000, function()
        local sess = dap.session()
        return not sess or sess.current_frame ~= nil
      end, 20)
    end
  end

  -- F-keys mirror the leader maps for the stepping verbs, so an edit-step-edit
  -- loop is one keypress. On a Mac laptop these need Fn unless "Use F1, F2,
  -- etc. as standard function keys" is on in System Settings > Keyboard.
  local fkeys = {
    ["<F5>"] = { dap.continue, "Continue / Start" },
    ["<F9>"] = { dap.toggle_breakpoint, "Toggle Breakpoint" },
    ["<F10>"] = { dap.step_over, "Step Over" },
    ["<F11>"] = { dap.step_into, "Step Into" },
    ["<F12>"] = { dap.step_out, "Step Out" },
  }
  for lhs, spec in pairs(fkeys) do
    vim.keymap.set("n", lhs, spec[1], { desc = "DAP: " .. spec[2], silent = true })
  end

  wk.add {
    {
      "<leader>db",
      function()
        dap.toggle_breakpoint()
      end,
      desc = "Toggle Breakpoint",
    },
    {
      "<leader>dB",
      function()
        dap.set_breakpoint(vim.fn.input "Condition: ")
      end,
      desc = "Conditional Breakpoint",
    },
    {
      "<leader>dc",
      function()
        dap.continue()
      end,
      desc = "Continue / Start",
    },
    {
      "<leader>di",
      function()
        dap.step_into()
      end,
      desc = "Step Into",
    },
    {
      "<leader>do",
      function()
        dap.step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>dO",
      function()
        dap.step_out()
      end,
      desc = "Step Out",
    },
    -- Both of these read the visual selection when called from visual mode and
    -- the <cexpr> under the cursor otherwise, so one binding covers both.
    {
      "<leader>de",
      function()
        dv.hover()
      end,
      desc = "Eval Expression",
      mode = { "n", "v" },
    },
    {
      "<leader>dw",
      function()
        dv.add_expr()
      end,
      desc = "Watch Expression",
      mode = { "n", "v" },
    },
    { "<leader>ds", step_mode, desc = "Step Mode" },
    {
      "<leader>dC",
      function()
        dap.run_to_cursor()
      end,
      desc = "Run To Cursor",
    },
    { "<leader>dr", show "repl", desc = "Go To REPL" },
    {
      "<leader>du",
      function()
        dv.toggle()
      end,
      desc = "Toggle DAP View",
    },
    {
      "<leader>dt",
      function()
        dap.terminate()
      end,
      desc = "Terminate",
    },
    {
      "<leader>dl",
      function()
        dap.run_last()
      end,
      desc = "Run Last",
    },
  }
end

return M
