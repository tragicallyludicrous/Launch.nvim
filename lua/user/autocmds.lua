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

-- Winbar: label each window with its buffer's path (relative to cwd, which the
-- Rooter above pins to the project root). Set per-window rather than a global
-- winbar so short/special/floating windows can be skipped -- the old
-- breadcrumbs.nvim winbar threw `E36: Not enough room` because it set a winbar
-- on the mini.files float and on panes with no spare row for the bar.
local winbar_skip_ft = {
  minifiles = true,
  ministarter = true,
  minipick = true,
  help = true,
  qf = true,
  lazy = true,
  mason = true,
  harpoon = true,
  toggleterm = true,
  NeogitStatus = true,
  NeogitCommitMessage = true,
}

local function winbar_eligible(win)
  -- Floating windows never get a winbar (this is what crashed breadcrumbs on
  -- the mini.files float).
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  -- A winbar consumes one row; a 1-row window has none to spare -> E36 at redraw.
  if vim.api.nvim_win_get_height(win) <= 1 then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  -- Real, listed, named file buffers only.
  if vim.bo[buf].buftype ~= "" or not vim.bo[buf].buflisted then
    return false
  end
  if winbar_skip_ft[vim.bo[buf].filetype] then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

local function set_winbar(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  -- `%<` truncates from the left (keeps the filename), `%m` = modified flag.
  -- expand('%:~:.') is evaluated in the drawn window's context, so each split
  -- shows its own path.
  local value = winbar_eligible(win) and " %<%{expand('%:~:.')} %m" or ""
  pcall(function()
    vim.wo[win].winbar = value
  end)
end

local winbar_group = vim.api.nvim_create_augroup("UserWinbar", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufEnter", "FileType" }, {
  group = winbar_group,
  callback = function()
    set_winbar(vim.api.nvim_get_current_win())
  end,
})
-- Resizes can drop a window to 1 row (or grow it back), so re-evaluate every
-- window in the tabpage rather than just the current one.
vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
  group = winbar_group,
  callback = function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      set_winbar(win)
    end
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
