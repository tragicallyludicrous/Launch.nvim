local M = {
  "nvim-tree/nvim-tree.lua",
  event = "VeryLazy",
}

function M.config()
  local wk = require "which-key"
  wk.add {
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" },
  }

  local icons = require "user.icons"

  require("nvim-tree").setup {
    hijack_netrw = false,
    sync_root_with_cwd = true,
    on_attach = function(bufnr)
      local api = require "nvim-tree.api"
      api.config.mappings.default_on_attach(bufnr)

      vim.keymap.set("n", "Y", function()
        local node = api.tree.get_node_under_cursor()
        if not node then return end
        local ok, core = pcall(require, "nvim-tree.core")
        local explorer = ok and core.get_explorer() or nil
        local root = explorer and explorer.absolute_path or vim.fn.getcwd()
        local rel = node.absolute_path
        if rel:sub(1, #root) == root then
          rel = rel:sub(#root + 1):gsub("^/", "")
        end
        vim.fn.setreg("+", rel)
        vim.fn.setreg('"', rel)
        vim.notify("Copied: " .. rel)
      end, { buffer = bufnr, desc = "Copy path relative to tree root" })

      vim.keymap.set("n", "gt", function()
        local node = api.tree.get_node_under_cursor()
        if not node then return end
        local path = node.type == "directory" and node.absolute_path
          or vim.fn.fnamemodify(node.absolute_path, ":h")

        local term_mod = require "toggleterm.terminal"
        local cmd = "cd " .. vim.fn.shellescape(path)

        local terms = term_mod.get_all() or {}
        local target
        for _, t in ipairs(terms) do
          if t:is_open() then
            target = t
            break
          end
        end
        if not target then target = terms[1] end

        if target then
          if not target:is_open() then target:open() end
          target:send(cmd, false)
        else
          term_mod.Terminal:new({
            dir = path,
            direction = "float",
            close_on_exit = true,
          }):toggle()
        end
      end, { buffer = bufnr, desc = "cd active toggleterm here" })
    end,
    view = {
      relativenumber = true,
    },
    renderer = {
      add_trailing = false,
      group_empty = false,
      highlight_git = false,
      full_name = false,
      highlight_opened_files = "none",
      root_folder_label = ":t",
      indent_width = 2,
      indent_markers = {
        enable = false,
        inline_arrows = true,
        icons = {
          corner = "└",
          edge = "│",
          item = "│",
          none = " ",
        },
      },
      icons = {
        git_placement = "before",
        padding = " ",
        symlink_arrow = " ➛ ",
        glyphs = {
          default = icons.ui.Text,
          symlink = icons.ui.FileSymlink,
          bookmark = icons.ui.BookMark,
          folder = {
            arrow_closed = icons.ui.ChevronRight,
            arrow_open = icons.ui.ChevronShortDown,
            default = icons.ui.Folder,
            open = icons.ui.FolderOpen,
            empty = icons.ui.EmptyFolder,
            empty_open = icons.ui.EmptyFolderOpen,
            symlink = icons.ui.FolderSymlink,
            symlink_open = icons.ui.FolderOpen,
          },
          git = {
            unstaged = icons.git.FileUnstaged,
            staged = icons.git.FileStaged,
            unmerged = icons.git.FileUnmerged,
            renamed = icons.git.FileRenamed,
            untracked = icons.git.FileUntracked,
            deleted = icons.git.FileDeleted,
            ignored = icons.git.FileIgnored,
          },
        },
      },
      special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
      symlink_destination = true,
    },
    update_focused_file = {
      enable = true,
      debounce_delay = 15,
      update_root = true,
      ignore_list = {},
    },

    diagnostics = {
      enable = true,
      show_on_dirs = false,
      show_on_open_dirs = true,
      debounce_delay = 50,
      severity = {
        min = vim.diagnostic.severity.HINT,
        max = vim.diagnostic.severity.ERROR,
      },
      icons = {
        hint = icons.diagnostics.BoldHint,
        info = icons.diagnostics.BoldInformation,
        warning = icons.diagnostics.BoldWarning,
        error = icons.diagnostics.BoldError,
      },
    },
  }
end

return M
