local M = {}

function M.active_file_dir()
  local cur_buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(cur_buf)
  if name ~= "" and vim.bo[cur_buf].buftype == "" then
    return vim.fn.fnamemodify(name, ":p:h")
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local b = vim.api.nvim_win_get_buf(win)
      local n = vim.api.nvim_buf_get_name(b)
      if n ~= "" and vim.bo[b].buftype == "" then
        return vim.fn.fnamemodify(n, ":p:h")
      end
    end
  end
  return vim.fn.getcwd()
end

function M.smart_tree()
  local ok_api, api = pcall(require, "nvim-tree.api")
  local ok_view, view = pcall(require, "nvim-tree.view")
  if not (ok_api and ok_view) then return end

  if not view.is_visible() then
    api.tree.open()
  elseif vim.bo.filetype == "NvimTree" then
    api.tree.close()
  else
    api.tree.focus()
  end
end

function M.focus_editor()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      if ft ~= "NvimTree" and ft ~= "toggleterm" and bt ~= "terminal" and bt ~= "prompt" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
  vim.notify("No editor window found", vim.log.levels.WARN)
end

function M.smart_terminal()
  -- Count prefix (e.g. 5<C-\>) → defer to default per-terminal toggle
  local count = vim.v.count
  if count > 0 then
    vim.cmd(count .. "ToggleTerm")
    return
  end

  local ok, term_mod = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.cmd "ToggleTerm"
    return
  end

  local terms = term_mod.get_all() or {}

  local visible_term, visible_winid
  for _, t in ipairs(terms) do
    if t:is_open() then
      visible_term = t
      visible_winid = vim.fn.bufwinid(t.bufnr)
      break
    end
  end

  if not visible_term then
    if #terms > 0 then
      terms[1]:open()
    else
      term_mod.Terminal:new({
        count = 1,
        dir = M.active_file_dir(),
      }):toggle()
    end
    return
  end

  if vim.api.nvim_get_current_buf() == visible_term.bufnr then
    visible_term:close()
  elseif visible_winid ~= -1 then
    vim.api.nvim_set_current_win(visible_winid)
  end
end

return M
