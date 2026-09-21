local M = {
  "nvim-lualine/lualine.nvim",
}

-- Debug key hints, shown only when there's something to debug: once a
-- breakpoint exists it says how to start, and during a session it lists the
-- stepping keys. Never forces nvim-dap to load -- if dap isn't loaded yet
-- there are no breakpoints and no session, so there's nothing to show.
local function debug_hint()
  if not package.loaded["dap"] then
    return ""
  end
  local dap = require "dap"
  local bug = require("user.icons").ui.Bug

  if dap.session() then
    if vim.o.columns < 120 then
      return bug .. "F5 F10 F11 F12"
    end
    return bug .. "F5 cont  F10 over  F11 in  F12 out"
  end

  local count = 0
  for _, bps in pairs(require("dap.breakpoints").get()) do
    count = count + #bps
  end
  if count > 0 then
    return ("%s%d  F5 debug"):format(bug, count)
  end
  return ""
end

function M.config()
  require("lualine").setup {
    options = {
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      ignore_focus = { "minifiles" },
    },
    sections = {
      lualine_a = {},
      lualine_b = { "branch" },
      lualine_c = { "diagnostics" },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { debug_hint },
    },
    extensions = { "quickfix", "man", "fugitive" },
  }
end

return M
