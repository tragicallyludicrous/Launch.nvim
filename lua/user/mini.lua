-- mini.nvim — the mini-centric core. One plugin, set up module-by-module.
-- Replaces: the nvim-cmp galaxy + LuaSnip, telescope, nvim-tree, nvim-surround,
-- nvim-autopairs, Comment.nvim, indent-blankline, nvim-web-devicons,
-- vim-illuminate, and the snacks dashboard.
local M = {
  "nvim-mini/mini.nvim",
  priority = 1000,
  lazy = false,
  dependencies = { "rafamadriz/friendly-snippets" },
}

function M.config()
  local icons = require "user.icons"

  -- Icons (replaces nvim-web-devicons) — mock must run before lualine asks for it.
  require("mini.icons").setup {}
  MiniIcons.mock_nvim_web_devicons()
  MiniIcons.tweak_lsp_kind()

  -- Editing -----------------------------------------------------------------
  require("mini.surround").setup {}
  require("mini.pairs").setup {}
  require("mini.comment").setup {}
  require("mini.ai").setup { n_lines = 500 }
  require("mini.bracketed").setup {}
  require("mini.move").setup {
    -- Visual-mode block moves only; normal-mode <M-hjkl> stays window navigation.
    mappings = {
      left = "<M-h>",
      right = "<M-l>",
      down = "<M-j>",
      up = "<M-k>",
      line_left = "",
      line_right = "",
      line_down = "",
      line_up = "",
    },
  }

  -- UI ----------------------------------------------------------------------
  require("mini.indentscope").setup {
    symbol = icons.ui.LineMiddle,
    draw = { animation = require("mini.indentscope").gen_animation.none() },
  }
  require("mini.cursorword").setup {}

  -- Completion + snippets (replaces nvim-cmp + LuaSnip) ---------------------
  local snippets = require "mini.snippets"
  snippets.setup {
    snippets = { snippets.gen_loader.from_lang() },
  }
  -- Surface the snippet library as an LSP source so snippets appear in the
  -- completion menu (with the body shown in the info/preview window).
  snippets.start_lsp_server()

  -- mini.snippets keeps a session alive until stopped, so an accidental/undone
  -- snippet can orphan its tabstop markers and keep swallowing <Tab>. Auto-stop
  -- the session on the next return to Normal mode (e.g. <Esc>), like LuaSnip did.
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniSnippetsSessionStart",
    callback = function()
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:n",
        once = true,
        callback = function()
          while MiniSnippets.session.get() do
            MiniSnippets.session.stop()
          end
        end,
      })
    end,
  })
  require("mini.completion").setup {
    window = {
      info = { border = "rounded" },
      signature = { border = "rounded" },
    },
    mappings = {
      force_twostep = "<C-Space>",
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },
  }
  vim.opt.completeopt:append "fuzzy"

  local mk = require "mini.keymap"
  mk.map_multistep("i", "<Tab>", { "minisnippets_next", "pmenu_next" })
  mk.map_multistep("i", "<S-Tab>", {
    "minisnippets_prev",
    "pmenu_prev",
    -- Otherwise de-indent the current line (backwards tab).
    {
      condition = function()
        return true
      end,
      action = function()
        return "<C-d>"
      end,
    },
  })
  mk.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
  mk.map_multistep("i", "<BS>", { "minipairs_bs" })

  -- Pickers + explorer (replaces telescope + nvim-tree) ---------------------
  require("mini.pick").setup { window = { config = { border = "rounded" } } }
  require("mini.extra").setup {}
  require("mini.files").setup {
    -- Match the old nvim-tree behavior (hijack_netrw = false): don't evict netrw.
    options = { use_as_default_explorer = false },
    windows = { preview = true, width_focus = 30, width_preview = 40 },
  }
  vim.ui.select = MiniPick.ui_select

  -- Dashboard (replaces snacks) ---------------------------------------------
  local starter = require "mini.starter"
  local header = table.concat({
    [[ ★　✯   🛸                    🪐   .°•    |    ]],
    [[    __     ° ★　•       🛰       __      / \   ]],
    [[   / /   ____ ___  ______  _____/ /_    | O |  ]],
    [[  / /   / __ `/ / / / __ \/ ___/ __ \   | O |  ]],
    [[ / /___/ /_/ / /_/ / / / / /__/ / / /  /| | |\ ]],
    [[/_____/\__,_/\__,_/_/ /_/\___/_/ /_/  /_(.|.)_\]],
  }, "\n")
  starter.setup {
    evaluate_single = true,
    header = header,
    items = {
      { name = "Find file", action = "Pick files", section = "" },
      { name = "New file", action = "ene | startinsert", section = "" },
      { name = "Recent files", action = "Pick oldfiles", section = "" },
      { name = "Find text", action = "Pick grep_live", section = "" },
      { name = "Find project", action = "lua require('user.pick').projects()", section = "" },
      { name = "Config", action = "edit $MYVIMRC", section = "" },
      { name = "Quit", action = "qa", section = "" },
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(icons.ui.ChevronShortRight .. " "),
      starter.gen_hook.aligning("center", "center"),
    },
    footer = function()
      local ok, lazy = pcall(require, "lazy")
      return ok and (icons.ui.Fire .. " loaded " .. lazy.stats().loaded .. " plugins") or ""
    end,
  }

  -- Preserve the old dashboard styling (header = Keyword, items = Include).
  local function dashboard_hl()
    local hl = vim.api.nvim_set_hl
    hl(0, "MiniStarterHeader", { link = "Keyword" })
    hl(0, "MiniStarterItem", { link = "Include" })
    hl(0, "MiniStarterItemBullet", { link = "Include" })
    hl(0, "MiniStarterFooter", { link = "Type" })
  end
  dashboard_hl()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = dashboard_hl })

  -- Keymaps for the pickers / explorer / comment ----------------------------
  vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Comment" })
  vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true, desc = "Comment" })

  local wk = require "which-key"
  wk.add {
    {
      "<leader>e",
      function()
        require("user.window").minifiles_toggle()
      end,
      desc = "Explorer",
    },
    {
      "<leader>bb",
      function()
        MiniPick.builtin.buffers()
      end,
      desc = "Find",
    },
    {
      "<leader>fb",
      function()
        MiniExtra.pickers.git_branches()
      end,
      desc = "Checkout branch",
    },
    {
      "<leader>fc",
      function()
        require("user.pick").colorscheme()
      end,
      desc = "Colorscheme",
    },
    {
      "<leader>ff",
      function()
        MiniPick.builtin.files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fp",
      function()
        require("user.pick").projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>ft",
      function()
        MiniPick.builtin.grep_live()
      end,
      desc = "Find Text",
    },
    {
      "<leader>fh",
      function()
        MiniPick.builtin.help()
      end,
      desc = "Help",
    },
    {
      "<leader>fl",
      function()
        MiniPick.builtin.resume()
      end,
      desc = "Last Search",
    },
    {
      "<leader>fr",
      function()
        MiniExtra.pickers.oldfiles()
      end,
      desc = "Recent File",
    },
  }

  -- Re-add the two custom nvim-tree maps inside mini.files: Y = copy relative
  -- path, gt = cd the active toggleterm to the entry's directory.
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf = args.data.buf_id
      vim.keymap.set("n", "Y", function()
        local entry = MiniFiles.get_fs_entry(buf, vim.fn.line ".")
        if not entry then
          return
        end
        local rel = vim.fn.fnamemodify(entry.path, ":.")
        vim.fn.setreg("+", rel)
        vim.notify("Copied: " .. rel)
      end, { buffer = buf, desc = "Copy relative path" })
      vim.keymap.set("n", "gt", function()
        local entry = MiniFiles.get_fs_entry(buf, vim.fn.line ".")
        if not entry then
          return
        end
        local dir = entry.fs_type == "directory" and entry.path or vim.fn.fnamemodify(entry.path, ":h")
        local term = require "toggleterm.terminal"
        local target = (term.get_all() or {})[1]
        if target then
          target:open()
          target:send("cd " .. vim.fn.shellescape(dir), false)
        else
          term.Terminal:new({ dir = dir, direction = "float" }):toggle()
        end
      end, { buffer = buf, desc = "cd toggleterm here" })
    end,
  })

  -- Per-buffer disables for the UI modules in noise-prone filetypes.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "minipick",
      "minifiles",
      "ministarter",
      "help",
      "qf",
      "lazy",
      "mason",
      "harpoon",
      "netrw",
      "NeogitStatus",
      "NeogitCommitMessage",
      "toggleterm",
    },
    callback = function()
      vim.b.minicursorword_disable = true
      vim.b.miniindentscope_disable = true
      vim.b.minipairs_disable = true
    end,
  })
end

return M
