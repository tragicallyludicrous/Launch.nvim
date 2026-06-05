vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    vim.cmd "set formatoptions-=cro"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "netrw",
    "qf",
    "git",
    "help",
    "man",
    "lspinfo",
    "checkhealth",
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

-- Rooter: cd to the nearest project root on entering a file (replaces project.nvim).
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = function()
    require("user.pick").root()
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
