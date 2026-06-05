local M = {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason-org/mason.nvim",
  },
}

function M.config()
  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }

  require("mason-lspconfig").setup {
    -- Reuse the list defined in user.lspconfig (single source of truth). We
    -- enable servers ourselves via vim.lsp.enable, so don't double-enable here.
    ensure_installed = require("user.lspconfig").servers,
    automatic_enable = false,
  }
end

return M
