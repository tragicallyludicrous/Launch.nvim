-- Lua LSP types for Neovim/luv (replaces the archived neodev.nvim).
local M = {
  "folke/lazydev.nvim",
  ft = "lua",
}

function M.config()
  require("lazydev").setup {
    library = {
      -- Load luvit types only when `vim.uv` is referenced.
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  }
end

return M
