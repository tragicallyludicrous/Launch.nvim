# Launch.nvim

A personal, [mini.nvim](https://github.com/nvim-mini/mini.nvim)-centric Neovim
config for **Neovim 0.12+**.

It started from LunarVim's Launch.nvim (the flat `spec()` + lazy.nvim layout in
`init.lua` / `lua/user/`) and was refactored around `mini.nvim`: a single plugin
supplies the picker, file explorer, completion, snippets, dashboard, surround,
comments, icons and more — keeping the install small and each file easy to read.

## What's inside

- **Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) — `:Lazy`
- **Find / explore:** `mini.pick` · `mini.files`
- **Completion:** `mini.completion` + `mini.snippets`
- **LSP:** native `vim.lsp` + [mason](https://github.com/mason-org/mason.nvim) + `lazydev`
- **Format:** [conform.nvim](https://github.com/stevearc/conform.nvim) on save (`:FormatOnSaveToggle`)
- **Git:** `gitsigns` + `neogit` · **Test:** `neotest` · **Debug:** `nvim-dap` · **REPL:** `iron.nvim`
- **Editing:** `mini.surround` / `mini.comment` / `mini.pairs` / `mini.ai` / `mini.move`
- **Tuned for:** Python (iron / neotest / dap), web (live-server), and CS50 / NAND2Tetris HDL

## Install

Needs Neovim 0.11+ (developed on 0.12), `git`, `ripgrep`, and a
[Nerd Font](https://www.nerdfonts.com/). Back up any existing config first.

```sh
git clone https://github.com/tragicallyludicrous/Launch.nvim.git ~/.config/nvim
nvim   # lazy.nvim installs everything on first launch
```

`install.sh` sets up the CS50 codespace toolchain (black, etc.) if you need it.

## Keys

Leader is `Space`. See **[CHEATSHEET.md](CHEATSHEET.md)** for the full reference,
or just press `<leader>` in normal mode to browse the bindings via which-key.
