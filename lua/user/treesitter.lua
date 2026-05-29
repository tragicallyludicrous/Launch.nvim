local ensure_installed = { "lua", "markdown", "markdown_inline", "bash", "python" }

-- Filetypes (not parser names) on which to start treesitter highlighting/indent.
-- Note: shell scripts are filetype "sh", and markdown_inline is injection-only.
local filetypes = { "lua", "markdown", "sh", "bash", "python" }

local M = {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
}

function M.config()
  require("nvim-treesitter").install(ensure_installed)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
      pcall(vim.treesitter.start)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
