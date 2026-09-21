# Debugging Cheat Sheet — nvim-dap

Everything about the `<leader>d` group. `<leader>` = **Space**.
For the rest of the config see **[CHEATSHEET.md](CHEATSHEET.md)**.

## The pieces

| Plugin | Job |
|---|---|
| `mfussenegger/nvim-dap` | The DAP **client**. Breakpoints, stepping, sessions, the REPL. |
| `igorlfs/nvim-dap-view` | The **UI** — one window, tabbed: scopes / watches / breakpoints / threads / exceptions / repl / console. Also supplies the hover float and the inline virtual text. |
| `mfussenegger/nvim-dap-python` | Registers the **debugpy adapter** + four ready-made Python configs. |
| `jay-babu/mason-nvim-dap` | Installs adapter **binaries** (`ensure_installed = { "python" }`). |

Config lives in [`lua/user/dap.lua`](lua/user/dap.lua).

> **Language support today: Python only.** debugpy is the only adapter installed
> and the only one registered. In any other filetype `<leader>dc` prints
> `No configuration found for `<ft>``. See [Adding a language](#adding-a-language).

---

## 60-second start

1. Open a `.py` file.
2. Put the cursor on a line that will actually execute → `<leader>db`. A `` appears in the gutter.
3. `<leader>dc` → a picker appears → choose **`file`**.
4. The program runs, the dap-view window opens along the bottom, and execution halts at your
   breakpoint — the line is marked `▶`.
5. Inspect: values are already inline as virtual text; the **Scopes** tab has the rest, and
   `<leader>de` pops a hover float for whatever's under the cursor.
6. Move: `<leader>do` (over) · `<leader>di` (into) · `<leader>dO` (out) · `<leader>dc` (run on).
7. `<leader>dt` terminates. **The window stays open** so you can still read the Console — close
   it with `<leader>du`.

---

## Keymaps — the `<leader>d` group

| Key | Action | Notes |
|---|---|---|
| `<leader>db` | Toggle breakpoint | On the current line. Press again to remove. |
| `<leader>dB` | Conditional breakpoint | Prompts `Condition:` — a Python expression, e.g. `i == 42` or `user.id is None`. Only stops when it's truthy. |
| `<leader>dc` | **Continue / Start** | No session → pick a config and launch. Stopped → resume. Running → a menu (terminate / pause / restart / disconnect / new session). |
| `<leader>di` | Step **into** | Descends into the call on the current line. |
| `<leader>do` | Step **over** | Runs the current line, including any calls, and stops on the next one. |
| `<leader>dO` | Step **out** | Runs to the end of the current function and stops at the caller. |
| `<leader>de` | **Eval expression** | Hover float with the value of the `<cexpr>` under the cursor. **In visual mode it evaluates the selection instead** — same key. Press it again to jump into the float; `q` closes it. |
| `<leader>dw` | **Watch expression** | Adds the thing under the cursor (or the visual selection) to the Watches tab. |
| `<leader>dC` | **Run to cursor** | Temporary breakpoint on the current line, then continue. Often faster than stepping. |
| `<leader>ds` | **Step mode** | Tap single keys instead of re-typing the prefix — see below. |
| `<leader>dr` | Go to REPL | Opens the view if it's closed, then switches to the REPL tab. |
| `<leader>du` | Toggle DAP View | Hide the window to read code; press again to bring it back. |
| `<leader>dt` | Terminate | Kills the debuggee and ends the session. The window stays open. |
| `<leader>dl` | Run last | Re-runs the previous configuration without the picker. **The one to hammer** on an edit→run→edit loop. |

Mnemonic for the case pairs: lowercase is the *lighter* action (`b` toggle vs `B` conditional,
`o` step over vs `O` step out).

### Stepping faster

Three ways to stop hammering the same key:

**1. Counts.** nvim-dap honours `v:count`, on stepping *and* on continue. This is the big one:

| | |
|---|---|
| `10<F10>` | Step over ten lines |
| `5<F5>` | Continue five times — i.e. skip the next five breakpoint hits |

Verified against a ten-iteration loop with a breakpoint in the body: at the first stop `i = 0`;
after `5<F5>`, `i = 5`; after a further `3<F10>`, `i = 6`. `5<F5>` is the one to reach for when
you're stopped inside a loop and want the sixth pass.

**2. F-keys** — one keypress, no leader:

| Key | Action |
|---|---|
| `<F5>` | Continue / start |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |

On a Mac laptop these need `Fn` unless *Use F1, F2, etc. as standard function keys* is enabled
in System Settings → Keyboard.

You don't have to memorise them — **the statusline reminds you** (`lua/user/lualine.lua`). It
stays empty until there's something to debug, then:

| Statusline shows | When |
|---|---|
| *(nothing)* | No breakpoints, no session |
| ` 2  F5 debug` | Breakpoints set, nothing running — the count is how many |
| ` F5 cont  F10 over  F11 in  F12 out` | Session live |
| ` F5 F10 F11 F12` | Session live, window under 120 columns |

**3. Step mode** — `<leader>ds` once, then tap bare keys:

```
o over · i into · O out · c continue · C run-to-cursor · j/k frame down/up · e eval · q quit
```

Any unmapped key exits. Each step waits for the adapter to come back to a stop before reading
the next key, so tapping quickly doesn't drop steps.

**Or don't step at all.** `<leader>dC` (run to cursor) and a conditional breakpoint
(`<leader>dB`, e.g. `i == 47`) usually beat any amount of tapping.

Debugging a **test** is a `<leader>t` binding, not `<leader>d`:

| Key | Action |
|---|---|
| `<leader>td` | Debug the nearest test under the cursor (neotest → dap, `justMyCode = false`) |
| `<leader>ts` | Stop the running test |

---

## Reading the screen

### Gutter signs

| Sign | Highlight | Meaning |
|---|---|---|
| `` (bug) | red (`DiagnosticError`) | Breakpoint |
| `` (bug) | yellow (`DiagnosticWarn`) | Conditional breakpoint — *same glyph*, only the colour differs |
| *(nothing)* | — | Log point. **The sign text is an empty string in `dap.lua:99`, so log points are invisible.** See fix #3 below. |
| `▶` | green (`DiagnosticOk`) | **Execution is stopped here** |

Live values appear inline as virtual text — that's dap-view's own, enabled with
`virtual_text = { enabled = true }`. It renders through treesitter, so it only shows in buffers
whose language has a parser installed; elsewhere it silently does nothing.
`:DapViewVirtualTextToggle` turns it off for the session.

### The layout

One window along the bottom (25% of the screen), tabbed via its winbar:

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   your code                                                      │
│   ▶ line 42                                                      │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│ Scopes  Watches  Breakpoints  Threads  Exceptions  REPL  Console │
│                                          ▶ ⏬ ⏭ ⏫ ↻ ⏹  ← controls │
│ ─────────────────────────────────────────────────────────────────│
│ locals:                                                          │
│   grid = [[5, 3, 0, 0, 7, …                                      │
│   row  = 2                                                       │
└──────────────────────────────────────────────────────────────────┘
```

`Scopes` is the tab you land on. `Console` is the debuggee's own terminal — because it's listed
as a section, it lives inside this window instead of nvim-dap opening a separate
`belowright new` split beside it.

The controls on the right of the winbar are **clickable with the mouse**: play, step into,
step over, step out, step back, run last, terminate, disconnect.

---

## Keys *inside* the dap-view window

Press `g?` in the window for the built-in help. These are the defaults:

### Everywhere in the window

| Key | Action |
|---|---|
| `S` `W` `B` `T` `E` `R` `C` | Jump straight to Scopes / Watches / Breakpoints / Threads / Exceptions / REPL / Console |
| `]v` / `[v` | Next / previous tab |
| `]V` / `[V` | First / last tab |
| `g?` | Help |

### Scopes, Watches, and the hover float

| Key | Action |
|---|---|
| `<CR>` | Expand / collapse the variable under the cursor |
| `[[` | Jump to the parent variable |
| `s` | **Set value** — change the variable live in the running program |
| `q` | Close (hover float only) |

Watches has more:

| Key | Action |
|---|---|
| `a` / `i` | **Append** / **insert** a new watch expression |
| `e` | Edit the expression under the cursor |
| `d` | Delete it |
| `c` | Copy its value |

### Breakpoints

| Key | Action |
|---|---|
| `<CR>` | Jump to that breakpoint's source line |
| `<C-w><CR>` | Jump, forcing a new window |
| `d` | Delete it |

### Threads

| Key | Action |
|---|---|
| `<CR>` | Jump to that stack frame |
| `<C-w><CR>` | Jump, forcing a new window |
| `t` | Toggle "subtle" frames (library/internal frames) |
| `f` / `o` | Filter frames / invert the filter |

### Exceptions & Console

| Key | Action |
|---|---|
| `<CR>` | Toggle an exception filter on/off (Exceptions tab) |
| `]s` / `[s` | Next / previous session (Console tab) |

---

## The REPL

`<leader>dr`, or `R` from inside the window. It's still nvim-dap's REPL — dap-view just hosts it
as a tab. It evaluates in the **currently selected stack frame**, so step or move frames first if
you want a different scope. Omni-completion (`<C-x><C-o>`) is wired to the adapter, so it
completes real attribute names off live objects.

Type any expression to evaluate it. Lines starting with `.` are commands:

| Command | Action |
|---|---|
| `.help` / `.h` | List every command |
| `.c` / `.continue` | Continue |
| `.n` / `.next` | Step over |
| `.into` | Step into |
| `.out` | Step out |
| `.up` / `.down` | Move up / down the call stack (changes which frame you evaluate in) |
| `.frames` | Print the stack; `<CR>` on a line jumps to that frame |
| `.scopes` | Print the variables in scope |
| `.threads` | List threads |
| `.goto <line>` | Jump execution to a line (adapter must support it) |
| `.pause` / `.p` | Pause a running program |
| `.capabilities` | What this adapter can actually do — useful when a feature silently no-ops |
| `.clear` | Clear the REPL buffer |
| `.b` / `.back`, `.rc` | Step back / reverse-continue (debugpy: unsupported) |
| `exit` / `.exit` | Close the session |

---

## Python specifics

### The configurations

`<leader>dc` in a Python buffer offers six. The first four come from dap-python; the last two
are added in `dap.lua`.

| Name | What it does |
|---|---|
| `file` | Run the current file as a script. Fine for a self-contained script; see the caveat below. |
| `file:args` | Same, but prompts for command-line arguments first (space-separated, shell-quoting respected). |
| `attach` | Attach to an already-running debugpy process. Prompts for host/port (default `127.0.0.1:5678`). |
| `file:doctest` | Runs the current file under `python -m doctest`. Note: this config sets `noDebug = true`, so it **runs without stopping at breakpoints** — it's a doctest runner, not a debug session. |
| **`entrypoint`** | Prompts once for a file (defaults to the current one) and **remembers it**. Launches that file no matter which buffer is focused. Change it with `:DapEntryPoint`. |
| **`module`** | Prompts once for a module name and remembers it — the equivalent of `python -m <name>`, run from the project root. Change it with `:DapModule`. |

> **The `file` caveat.** `file` is `program = "${file}"`, which expands to *whatever buffer is
> focused at launch* — and `dap.run_last()` stores the config **before** expansion, so
> `<leader>dl` re-resolves it too. Step into a module, edit it, press `<leader>dl`, and you
> relaunch that module instead of your program. That's what `entrypoint` exists to avoid.

### Which interpreter

Two different interpreters are in play.

*The adapter's* is set in `dap.lua`: Mason's own venv
(`~/.local/share/nvim/mason/packages/debugpy/venv/bin/python`), falling back to `python3`.
It only runs `-m debugpy.adapter` — it never runs your code.

*Your program's* is resolved fresh at launch, in this order:
`$VIRTUAL_ENV` → `$CONDA_PREFIX` → a `venv/`, `.venv/`, `env/` or `.env/` directory found under
the cwd, the window-local cwd, or an attached LSP client's root — and if none match, debugpy's
own default. **So activate your project venv before launching**, or the imports won't resolve.

dap-python also reads a `.env` file from the cwd (if present) and merges it into the program's
environment.

### stdin / stdout

Configs use `console = 'integratedTerminal'`, so your program gets a real terminal — that's the
**Console** tab. It's where `input()` reads from and where `print()` lands: press `C` inside the
window (or click the tab) and type there.

### Stepping into library code

Test debugging via neotest is configured with `justMyCode = false`, so `<leader>di` will
happily descend into site-packages. The plain `file` config uses debugpy's default
(`justMyCode = true`), which skips them.

---

## Debugging a module that something else calls

Breakpoints are **global** — they aren't tied to the file you launch. So you never need to run
the module itself; you break in it and launch whatever calls it.

1. Open the module, put the breakpoint where you care (`<leader>db`).
2. `<leader>dc` → **`entrypoint`** → accept or type the path to your real entry point.
3. It stops inside the module. The **Threads** tab shows how you got there:

```
1. normalize    helpers.py:3     ← stopped here
2. run          main.py:5
3. <module>     main.py:8
```

From then on `<leader>dl` re-runs that same entry point from any buffer, and `:DapEntryPoint`
changes it.

**If the entry point is a package** (`python -m pkg`), use the **`module`** config instead —
`${file}` has nothing to launch. It runs from `${workspaceFolder}`, i.e. Neovim's cwd, so
`:cd` to the project root first or `-m` resolution and relative paths will be off.

**Other routes to the same place:**

- **Through a test** — `<leader>td` on a test that exercises the module. Often the cleanest
  option for a library module, and neotest is set to `justMyCode = false` so you can step anywhere.
- **`attach`** — for a module running inside a long-lived process (a server, a worker). Needs
  `debugpy.listen(5678)` in that process.
- **`debug_selection()`** — `:lua require("dap-python").debug_selection()` runs just the
  highlighted lines under the debugger.

`justMyCode` only skips *library* code, so your own sibling modules are always steppable.

---

## Commands

### nvim-dap

| Command | Action |
|---|---|
| `:DapContinue` | Same as `<leader>dc` |
| `:DapToggleBreakpoint` | Same as `<leader>db` |
| `:DapClearBreakpoints` | **Remove every breakpoint** in every buffer |
| `:DapStepOver` / `:DapStepInto` / `:DapStepOut` | Stepping |
| `:DapPause` | Interrupt a running program |
| `:DapTerminate` | Same as `<leader>dt` |
| `:DapDisconnect` | Detach but **leave the debuggee running** (the one you want after `attach`) |
| `:DapRestartFrame` | Re-run the current function from its first line |
| `:DapEval` | Open a scratch buffer; `<CR>` evaluates the line in the current frame |
| `:DapNew` | Start an *additional*, concurrent session |
| `:DapSetLogLevel TRACE` | Crank up logging |
| `:DapShowLog` | Open the log |
| `:checkhealth dap` | Adapter/dependency sanity check |

### Added in `dap.lua`

| Command | Action |
|---|---|
| `:DapEntryPoint` | Set the file the `entrypoint` config launches (prefilled with the current value, else the current file) |
| `:DapModule` | Set the module the `module` config launches |

### nvim-dap-view

| Command | Action |
|---|---|
| `:DapViewToggle` | Same as `<leader>du`. `!` also hides the terminal. |
| `:DapViewOpen` / `:DapViewClose` | Explicit open / close |
| `:DapViewHover [expr]` | Hover float. With no argument, uses the `<cexpr>` under the cursor. `!` focuses the float immediately. |
| `:DapViewWatch [expr]` | Add a watch. Accepts a range, so `:'<,'>DapViewWatch` works on a selection. |
| `:DapViewJump <section>` | Focus a specific tab (tab-completes) |
| `:DapViewShow <section>` | Switch to a tab without moving the cursor into the window |
| `:DapViewNavigate <n>` | Move `n` tabs along; `!` wraps around |
| `:DapViewVirtualTextToggle` | Turn the inline values off/on (also `…Enable` / `…Disable`) |

---

## Not bound to a key (yet)

Genuinely useful things that currently need `:lua`. See
[Suggested improvements](#suggested-improvements) for what to bind them to.

```lua
:lua require("dap").run_to_cursor()              -- temporary breakpoint here, continue
:lua require("dap").set_breakpoint(nil, nil, "x={x}")  -- LOG POINT: prints, never stops
:lua require("dap").list_breakpoints(true)       -- all breakpoints → quickfix
:lua require("dap").clear_breakpoints()
:lua require("dap").up() / .down()               -- move a stack frame
:lua require("dap").focus_frame()                -- jump back to where you're stopped
:lua require("dap").pause() / .restart() / .restart_frame()
:lua require("dap").set_exception_breakpoints()  -- pick: break on raised / uncaught
                                                 -- (or just use the Exceptions tab)
:lua require("dap.ext.vscode").load_launchjs()   -- pull in a project's .vscode/launch.json
```

nvim-dap also ships its own floating widgets, independent of dap-view:

```lua
:lua require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes)
:lua require("dap.ui.widgets").preview()         -- value in a preview window
```

`dap-python` extras, also unbound:

```lua
:lua require("dap-python").test_method()     -- debug just the test function under the cursor
:lua require("dap-python").test_class()      -- ...the whole class
:lua require("dap-python").debug_selection() -- visual mode: debug the highlighted lines
```

---

## Adding a language

Two steps: install the adapter binary, then register configurations.

**C / C++ (CS50)** — `:MasonInstall codelldb`, then in `M.config()`:

```lua
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}
dap.configurations.c = {
  {
    name = "Launch (prompt for binary)",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
dap.configurations.cpp = dap.configurations.c
```

Compile with `-g` (`clang -g -o hello hello.c`) or there are no symbols to break on.

**JavaScript / TypeScript** — `:MasonInstall js-debug-adapter`, then register the `pwa-node`
adapter as a server pointed at
`~/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js` and add
`dap.configurations.javascript` / `.typescript`. Do **not** reach for
`mxsdev/nvim-dap-vscode-js` — it's been untouched since 2023; the manual adapter is the
current path.

Once registered, add the adapter to `mason-nvim-dap`'s `ensure_installed` so a fresh machine
gets it automatically.

---

## Troubleshooting

**`No configuration found for `c`` (or `lua`, `zig`, `javascript`…)**
Expected — only Python is registered. See [Adding a language](#adding-a-language).

**`<leader>dc` opens the menu instead of starting**
A session is already alive. Pick *Terminate session*, or use `<leader>dt` then `<leader>dl`.

**Breakpoint never hits**
Is that line reachable? Did you break in a module that isn't imported yet? Is the file the
adapter loaded the same file on disk (`.pyc` staleness, an editable install pointing elsewhere)?
Check the **Breakpoints** tab — a breakpoint the adapter rejected won't show as verified.

**Breakpoints vanish when you restart Neovim**
Correct — they're in-memory only. Nothing persists them yet.

**No inline values**
dap-view's virtual text needs a treesitter parser for the buffer's language. `:TSInstall <lang>`,
or check `lua/user/treesitter.lua`'s `ensure_installed`. `:DapViewVirtualTextToggle` confirms
it's on.

**`Can't jump to view: couldn't find the window`**
`:DapViewJump` / `:DapViewShow` need the window open first. `<leader>dr` handles this for you;
otherwise `<leader>du` then jump.

**The window stays open after the program finishes**
Intentional — `auto_toggle = "open"` opens the view on launch and never auto-closes it, so the
Console output survives the exit. `<leader>du` closes it.

**Nothing happens at all**
`:checkhealth dap`, then `:DapSetLogLevel TRACE`, reproduce, `:DapShowLog`.

---

## Suggested improvements

Not implemented — candidates for `lua/user/dap.lua`.

1. **Bind the remaining verbs:** `<leader>dL` log point, `<leader>dp` pause,
   `<leader>dR` restart, `<leader>dq` breakpoints→quickfix, `<leader>dx` clear all.
   (F-keys, run-to-cursor and frame up/down are done.)
2. **Persist breakpoints** across restarts — a small `dap.breakpoints.get()/set()` autocmd
   keyed on the project root, or `Weissle/persistent-breakpoints.nvim`.
3. **Fix the invisible log point.** `dap.lua:99` defines `DapLogPoint` with `text = ""`, so a
   log point leaves no mark in the gutter. Give it a real glyph (`icons.ui.Bug`, `""`, `"◆"`).
4. **Highlight the stopped line.** `sign_define("DapStopped", { linehl = "Visual", numhl = ... })`
   makes the halt position obvious at a glance. Also define `DapBreakpointRejected` so an
   unverified breakpoint is visibly different from a working one, and give
   `DapBreakpointCondition` its own glyph — right now it's the same bug icon as a plain
   breakpoint, distinguished only by colour.
5. **Guard the conditional-breakpoint prompt.** `<leader>dB` passes `vim.fn.input(...)` straight
   through, so pressing `<Esc>` sets a breakpoint with an empty-string condition rather than no
   condition. Bail out when the input is empty.
6. **Add codelldb** for CS50 C work, and `js-debug-adapter` for the JS/TS side.
7. **`load_launchjs()` on `DirChanged`** so a project's `.vscode/launch.json` configs just appear
   in the `<leader>dc` picker. (Neovim 0.12's `vim.json.decode` handles the comments; no json5
   plugin needed.)
8. **Lazy-load on `keys`** instead of `event = "VeryLazy"` — DAP currently loads on every start.
9. **`handlers = {}` on `mason-nvim-dap`** would let it auto-register adapters for anything
    installed via `:Mason`, instead of only installing binaries. **Check the interaction first:**
    its default Python handler registers its own `dap.adapters.python` and appends a "Launch file"
    config, which would collide with `dap-python`'s — you'd likely need
    `handlers = { python = function() end }` to opt that one out.
