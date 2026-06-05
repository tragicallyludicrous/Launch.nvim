local M = {
  "barrett-ruth/live-server.nvim",
  build = "npm install -g live-server",
  event = "VeryLazy",
}

function M.init()
  vim.g.live_server = {}
end

-- mini.files names its buffers `minifiles://<id>/<path>`, which live-server's
-- resolve_dir() can't parse (its regex wants the path right after `://`), so it
-- bails with a bogus `minifiles://…` directory. When invoked from the explorer,
-- resolve the real directory ourselves and pass it in explicitly; otherwise
-- return nil and let live-server use the current file's directory.
local function explorer_dir()
  if vim.bo.filetype ~= "minifiles" then
    return nil
  end
  local ok, entry = pcall(MiniFiles.get_fs_entry)
  if not (ok and entry) then
    return nil
  end
  return entry.fs_type == "directory" and entry.path or vim.fn.fnamemodify(entry.path, ":h")
end

function M.config()
  local wk = require "which-key"
  wk.add {
    { "<leader>L", group = "Live Server" },
    {
      "<leader>Ls",
      function()
        require("live-server").start(explorer_dir())
      end,
      desc = "Start",
    },
    {
      "<leader>Lq",
      function()
        require("live-server").stop(explorer_dir())
      end,
      desc = "Stop",
    },
  }
end

return M
