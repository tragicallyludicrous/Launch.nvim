# Neovim Cheat Sheet

`<leader>` = **Space**. This config is mini.nvim-centric. Press `<leader>` and wait to see
the which-key popup for any group. Inside mini.files press `g?` for its help.

## Core motions & windows

| Key | Action |
|---|---|
| `<M-h/j/k/l>` | Move to window left/down/up/right |
| `<M-Tab>` | Alternate (last) buffer |
| `H` / `L` | Jump to first / last non-blank char of line (Shift+h / Shift+l) |
| `j` / `k` | Move by *display* line (wrap-aware) |
| `n` `N` `*` `#` | Search, centered on screen |
| `<` / `>` (visual) | Indent and stay in visual mode |
| `<RightMouse>` | Context menu (Goto Definition / References) |
| `<leader>v` | Vertical split |
| `<leader>w` | Focus the editor window (jump out of explorer/term) |
| `<leader>h` | Clear search highlight |
| `<leader>q` / `<leader>Q` | Quit / Quit all |

## Find & files — mini.pick (`<leader>f`)

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>ft` | Find text (live grep) |
| `<leader>fr` | Recent files |
| `<leader>fb` | Checkout git branch |
| `<leader>fc` | Colorscheme (live preview) |
| `<leader>fh` | Help tags |
| `<leader>fl` | Resume last picker |
| `<leader>fp` | Recent projects (fills in as you visit repos) |
| `<leader>bb` | Buffers |

**Inside a picker:** type to fuzzy-filter · `<C-n>`/`<C-p>` move · `<CR>` open ·
`<C-s>`/`<C-v>`/`<C-t>` split/vsplit/tab · `<Tab>` toggle preview · `<S-Tab>` toggle info ·
`<C-x>` mark, `<C-a>` mark all · `<C-Space>` refine · `<Esc>` cancel.

## File explorer — mini.files

| Key | Action |
|---|---|
| `<leader>e` | Toggle explorer (opens at current file) |

**Inside the explorer:** `l` enter / open · `L` open file & close · `h` go to parent ·
`H` go out further · `q` close · `=` **apply** pending file edits (create/rename/move/delete
by editing the buffer like text) · `@` reveal cwd · `m` set bookmark, `'` go to bookmark ·
`g?` help. Custom: `Y` copy relative path · `gt` cd the active toggleterm here.

## Completion & snippets — mini.completion / mini.snippets

Popup appears as you type. LSP-driven, fuzzy.

| Key | Action |
|---|---|
| `<C-Space>` | Force LSP completion |
| `<Tab>` | Next completion item / jump to next snippet tabstop |
| `<S-Tab>` | Previous item / previous tabstop / de-indent line |
| `<CR>` | Accept selected item (else newline, pair-aware) |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-f>` / `<C-b>` | Scroll docs |
| `<C-j>` | Expand snippet at cursor |
| `<C-l>` / `<C-h>` | Jump to next / previous snippet tabstop |
| `<Esc>` / `<C-c>` | End the snippet (clears the `•` tabstop markers) |

## LSP (`<leader>l`)

Buffer-local, active when a server is attached:

| Key | Action |
|---|---|
| `gd` / `gD` | Go to definition / declaration |
| `gr` | References |
| `gI` | Implementation |
| `K` | Hover docs |
| `gl` | Line diagnostics (float) |
| `<leader>la` | Code action (works in visual too) |
| `<leader>lr` | Rename |
| `<leader>lf` | Format (conform) |
| `<leader>lj` / `<leader>lk` | Next / previous diagnostic |
| `<leader>lh` | Toggle inlay hints |
| `<leader>ll` | Run code lens |
| `<leader>lq` | Diagnostics → location list |
| `<leader>li` | LSP info (`:checkhealth vim.lsp`) |

Format-on-save is on by default; toggle with `:FormatOnSaveToggle`.

## Git — gitsigns (`<leader>g`) & neogit

| Key | Action |
|---|---|
| `<leader>gg` | Open Neogit |
| `<leader>gj` / `<leader>gk` | Next / previous hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gR` | Reset buffer |
| `<leader>gl` | Blame line |
| `<leader>gd` | Diff against HEAD |

## Debug — nvim-dap (`<leader>d`)

| Key | Action |
|---|---|
| `<leader>db` / `<leader>dB` | Toggle / conditional breakpoint |
| `<leader>dc` | Continue / start |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate |
| `<leader>dl` | Run last |

## Test — neotest (`<leader>t`)

| Key | Action |
|---|---|
| `<leader>tt` | Test nearest |
| `<leader>tf` | Test file |
| `<leader>td` | Debug nearest test |
| `<leader>ts` | Stop |
| `<leader>ta` | Attach |

## Python REPL — iron.nvim (`<leader>r`)

| Key | Action |
|---|---|
| `<leader>rr` / `<leader>rR` | Toggle / restart REPL |
| `<leader>rc` | Send motion / visual selection |
| `<leader>rl` / `<leader>rp` / `<leader>rf` | Send line / paragraph / file |
| `<leader>ru` | Send until cursor |
| `<leader>rF` / `<leader>rh` | Focus / hide REPL |
| `<leader>rx` / `<leader>rq` | Clear / exit REPL |

## Harpoon

| Key | Action |
|---|---|
| `M` | Mark current file (Shift+m) |
| `<Tab>` | Toggle quick menu (jump between marked files) |

## Terminal — toggleterm

| Key | Action |
|---|---|
| `<C-\>` | Smart toggle (open → focus → close) |
| `<M-1>` / `<M-2>` / `<M-3>` | Horizontal / vertical / float terminal |
| `<leader>;` | Pick terminal |
| `<M-h/j/k/l>` (in term) | Move to window |
| `<C-;>` (in term) | Leave terminal mode |

## Tabs — (`<leader>a`)

| Key | Action |
|---|---|
| `<leader>aN` / `<leader>an` | New tab (current file / empty) |
| `<leader>ah` / `<leader>al` | Move tab left / right |
| `<leader>ao` | Close other tabs |

## Editing — mini modules

**Surround** (`s` prefix): `sa{motion}{char}` add · `sd{char}` delete · `sr{old}{new}`
replace · `sf`/`sF` find · `sh` highlight. e.g. `saiw)` wrap word in `()`, `sd"` drop quotes,
`sr)]` turn `()` into `[]`. In visual: select then `sa{char}`.

**Comment**: `gcc` line · `gc{motion}` (e.g. `gcip`) · `gc` (visual) · `<leader>/` toggle.

**Text objects** (mini.ai): richer `a`/`i` — works on `( [ { b q t f a` (brackets, quotes,
tag, function call, argument) plus `n`/`l` for next/last. e.g. `ci(`, `daf`, `vana`.

**Move** (visual): `<M-h/j/k/l>` move the selected block left/down/up/right.

**Bracketed jumps**: `[`/`]` + `b`uffer `c`omment `d`iagnostic `q`uickfix `i`ndent
`t`reesitter `j`ump — e.g. `]d` next diagnostic, `[c` previous comment block.

## Dashboard

Shown on startup. Type a few letters of an entry (e.g. `qu`→Quit) and it runs; or `j`/`k` + `<CR>`.
Entries: Find file · New file · Recent files · Find text · Find project · Config · Quit.

## Handy commands

| Command | Action |
|---|---|
| `:Lazy` | Plugin manager (install/update/clean) |
| `:Mason` | LSP/tool installer |
| `:checkhealth` | Diagnose the setup |
| `:ConformInfo` | Formatter status for the buffer |
| `:FormatOnSaveToggle` | Toggle format-on-save |
| `:Cd <path>` | `cd` that accepts quoted/escaped paths |

## HTML live preview — live-server (`<leader>L`)

| Key | Action |
|---|---|
| `<leader>Ls` | Start live server |
| `<leader>Lq` | Stop live server |
