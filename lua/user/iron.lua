local M = {
  "Vigemus/iron.nvim",
  event = "VeryLazy",
}

function M.config()
  local iron = require "iron.core"
  local view = require "iron.view"
  local common = require "iron.fts.common"
  local wk = require "which-key"

  iron.setup {
    config = {
      scratch_repl = true,
      repl_definition = {
        python = {
          command = function()
            if vim.fn.executable "ipython" == 1 then
              return { "ipython", "--no-autoindent" }
            end
            return { "python3" }
          end,
          format = common.bracketed_paste_python,
        },
      },
      repl_open_cmd = view.split.horizontal.botright "30%",
    },
    keymaps = {
      toggle_repl = "<leader>rr",
      restart_repl = "<leader>rR",
      send_motion = "<leader>rc",
      visual_send = "<leader>rc",
      send_file = "<leader>rf",
      send_line = "<leader>rl",
      send_paragraph = "<leader>rp",
      send_until_cursor = "<leader>ru",
      send_mark = "<leader>rm",
      mark_motion = "<leader>rMc",
      mark_visual = "<leader>rMc",
      remove_mark = "<leader>rMd",
      cr = "<leader>r<cr>",
      interrupt = "<leader>r<space>",
      exit = "<leader>rq",
      clear = "<leader>rx",
    },
    highlight = { italic = true },
    ignore_blank_lines = true,
  }

  wk.add {
    { "<leader>r", group = "REPL" },
    { "<leader>rr", desc = "Toggle REPL" },
    { "<leader>rR", desc = "Restart REPL" },
    { "<leader>rc", desc = "Send Motion/Visual" },
    { "<leader>rf", desc = "Send File" },
    { "<leader>rl", desc = "Send Line" },
    { "<leader>rp", desc = "Send Paragraph" },
    { "<leader>ru", desc = "Send Until Cursor" },
    { "<leader>rm", desc = "Send Mark" },
    { "<leader>rM", group = "Mark" },
    { "<leader>rq", desc = "Exit REPL" },
    { "<leader>rx", desc = "Clear REPL" },
    { "<leader>rF", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
    { "<leader>rh", "<cmd>IronHide<cr>", desc = "Hide REPL" },
  }
end

return M
