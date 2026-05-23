local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "folke/neodev.nvim",
    },
  },
}

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
end

M.toggle_inlay_hints = function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
end

function M.config()
  local wk = require "which-key"
  wk.add {
    { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action" },
    {
      "<leader>lf",
      function()
        vim.lsp.buf.format {
          async = true,
          filter = function(client) return client.name ~= "typescript-tools" end,
        }
      end,
      desc = "Format",
    },
    { "<leader>lh", function() require("user.lspconfig").toggle_inlay_hints() end, desc = "Hints" },
    { "<leader>li", "<cmd>checkhealth vim.lsp<cr>", desc = "Info" },
    { "<leader>lj", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
    { "<leader>lk", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
    { "<leader>ll", vim.lsp.codelens.run, desc = "CodeLens Action" },
    { "<leader>lq", vim.diagnostic.setloclist, desc = "Quickfix" },
    { "<leader>lr", vim.lsp.buf.rename, desc = "Rename" },
  }

  wk.add {
    { "<leader>la", group = "LSP" },
    { "<leader>laa", vim.lsp.buf.code_action, desc = "Code Action", mode = "v" },
  }

  local icons = require "user.icons"

  -- Diagnostic configuration with custom signs
  vim.diagnostic.config {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN]  = icons.diagnostics.Warning,
        [vim.diagnostic.severity.HINT]  = icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO]  = icons.diagnostics.Information,
      },
    },
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  -- LspAttach autocmd replaces per-server on_attach
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      lsp_keymaps(bufnr)

      if client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end,
  })

  -- Rounded borders for floating windows (hover, signature help)
  -- Modern replacement for vim.lsp.with(vim.lsp.handlers.hover, ...)
  vim.o.winborder = "rounded"

  -- Capabilities: enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- Servers to enable
  local servers = {
    "lua_ls",
    "cssls",
    "html",
    "ts_ls",
    "eslint",
    "pyright",
    "bashls",
    "jsonls",
    "yamlls",
  }

  -- Initialize neodev before lua_ls config is loaded
  require("neodev").setup {}

  -- Configure each server (settings only; on_attach handled by autocmd above)
  for _, server in ipairs(servers) do
    local opts = { capabilities = capabilities }

    local require_ok, settings = pcall(require, "user.lspsettings." .. server)
    if require_ok then
      opts = vim.tbl_deep_extend("force", opts, settings)
    end

    vim.lsp.config(server, opts)
  end

  -- Enable all configured servers
  vim.lsp.enable(servers)
end

return M
