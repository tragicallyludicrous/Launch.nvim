-- Formatting via external tools (replaces none-ls.nvim).
local M = {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
}

function M.config()
  local prettier = { "prettier" }
  require("conform").setup {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      css = prettier,
      html = prettier,
      json = prettier,
      jsonc = prettier,
      yaml = prettier,
      markdown = prettier,
    },
    -- Honor the global/buffer toggle (FormatOnSaveToggle command, autocmds.lua).
    format_on_save = function(bufnr)
      if vim.b[bufnr].disable_format_on_save or vim.g.disable_format_on_save then
        return
      end
      return { timeout_ms = 3000, lsp_format = "fallback" }
    end,
  }
end

return M
