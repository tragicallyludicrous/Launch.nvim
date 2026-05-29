local M = {
  "barrett-ruth/live-server.nvim",
  build = "npm install -g live-server",
  event = "VeryLazy",
}

function M.config()
  require("live-server").setup {}

  local wk = require "which-key"
  wk.add {
    { "<leader>L", group = "Live Server" },
    { "<leader>Ls", "<cmd>LiveServerStart<cr>", desc = "Start" },
    { "<leader>Lq", "<cmd>LiveServerStop<cr>", desc = "Stop" },
  }
end

return M
