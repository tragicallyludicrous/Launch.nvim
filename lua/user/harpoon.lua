local M = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
}

function M.config()
  local harpoon = require "harpoon"
  harpoon:setup {}

  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<s-m>", function()
    harpoon:list():add()
    vim.notify "󱡅  marked file"
  end, opts)
  vim.keymap.set("n", "<TAB>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end, opts)
end

return M
