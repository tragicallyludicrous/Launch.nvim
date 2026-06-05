-- Project rooter + small custom mini.pick sources (replaces project.nvim).
local M = {}

local store = vim.fn.stdpath "data" .. "/projects"
local markers = { ".git", "Makefile", "package.json", "pyproject.toml", ".hg", ".svn", ".bzr" }

local function read()
  local list, f = {}, io.open(store, "r")
  if f then
    for line in f:lines() do
      if line ~= "" then
        list[#list + 1] = line
      end
    end
    f:close()
  end
  return list
end

-- Record a project root: most-recent-first, de-duplicated, capped at 50.
local function record(root)
  local out = { root }
  for _, p in ipairs(read()) do
    if p ~= root and #out < 50 then
      out[#out + 1] = p
    end
  end
  local f = io.open(store, "w")
  if f then
    f:write(table.concat(out, "\n"), "\n")
    f:close()
  end
end

-- Rooter: cd to the nearest project root of the current real file (global cwd).
function M.root()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  local root = vim.fs.root(buf, markers)
  if root and root ~= vim.fn.getcwd() then
    vim.fn.chdir(root)
    record(root)
  end
end

-- Recent-projects picker: chdir into the choice, then open the file finder.
function M.projects()
  local items = read()
  if #items == 0 then
    return vim.notify("No recent projects yet", vim.log.levels.INFO)
  end
  MiniPick.start {
    source = {
      name = "Projects",
      items = items,
      choose = function(item)
        if not item then
          return
        end
        vim.schedule(function()
          vim.fn.chdir(item)
          MiniPick.builtin.files()
        end)
      end,
    },
  }
end

-- Colorscheme picker (replaces Telescope colorscheme), with live preview.
function M.colorscheme()
  local current = vim.g.colors_name
  MiniPick.start {
    source = {
      name = "Colorschemes",
      items = vim.fn.getcompletion("", "color"),
      preview = function(_, item)
        pcall(vim.cmd.colorscheme, item)
      end,
      choose = function(item)
        if item then
          pcall(vim.cmd.colorscheme, item)
        end
      end,
    },
  }
  if current then
    pcall(vim.cmd.colorscheme, current)
  end
end

return M
