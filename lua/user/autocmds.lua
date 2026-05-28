vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    vim.cmd "set formatoptions-=cro"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "netrw",
    "Jaq",
    "qf",
    "git",
    "help",
    "man",
    "lspinfo",
    "oil",
    "spectre_panel",
    "lir",
    "DressingSelect",
    "tsplayground",
    "",
  },
  callback = function()
    vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]]
  end,
})

vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
  callback = function()
    vim.cmd "quit"
  end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
  callback = function()
    vim.cmd "tabdo wincmd ="
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "!vim" },
  callback = function()
    vim.cmd "checktime"
  end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 40 }
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "gitcommit", "markdown", "NeogitCommitMessage" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd({ "CursorHold" }, {
  callback = function()
    local status_ok, luasnip = pcall(require, "luasnip")
    if not status_ok then
      return
    end
    if luasnip.expand_or_jumpable() then
      -- ask maintainer for option to make this silent
      -- luasnip.unlink_current()
      vim.cmd [[silent! lua require("luasnip").unlink_current()]]
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("UserFormatOnSave", { clear = true }),
  callback = function(args)
    if vim.b.disable_format_on_save or vim.g.disable_format_on_save then
      return
    end
    vim.lsp.buf.format {
      bufnr = args.buf,
      timeout_ms = 3000,
      filter = function(client) return client.name ~= "typescript-tools" end,
    }
  end,
})

vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
  vim.g.disable_format_on_save = not vim.g.disable_format_on_save
  vim.notify("Format on save: " .. (vim.g.disable_format_on_save and "OFF" or "ON"))
end, { desc = "Toggle format on save globally" })

vim.api.nvim_create_user_command("Cd", function(opts)
  local path = opts.args
  path = path:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
  path = path:gsub("\\ ", " ")
  path = vim.fn.expand(path)
  vim.cmd("cd " .. vim.fn.fnameescape(path))
end, { nargs = 1, complete = "dir", desc = "cd that accepts quoted/escaped paths" })
