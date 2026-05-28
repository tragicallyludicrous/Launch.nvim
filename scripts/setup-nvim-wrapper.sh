#!/usr/bin/env bash
# Installs the nvim-remote-wrapper function into ~/.bashrc.
# Safe to run multiple times — checks for an existing install first.
set -euo pipefail

if grep -qsF '# nvim-remote-wrapper' "$HOME/.bashrc" 2>/dev/null; then
  echo "nvim-remote-wrapper already installed in ~/.bashrc"
  exit 0
fi

# Remove older alias-based block (whole if/alias/fi unit) and any orphan
# empty if/fi left by earlier buggy versions of this script.
if [ -f "$HOME/.bashrc" ]; then
  python3 - <<'PY'
import re, pathlib
p = pathlib.Path.home() / ".bashrc"
text = p.read_text()
# Strip full legacy block: optional comment + if/alias/fi
text = re.sub(
    r"(?:#[^\n]*\n)?if \[ -n \"\$NVIM\" \]; then\s*\n\s*alias nvim=\047nvim --server[^\n]*\n\s*fi\s*\n",
    "",
    text,
)
# Strip orphan empty if/fi
text = re.sub(r"(?:#[^\n]*\n)?if \[ -n \"\$NVIM\" \]; then\s*\nfi\s*\n", "", text)
p.write_text(text)
PY
fi

cat >> "$HOME/.bashrc" <<'BASHRC_EOF'

# nvim-remote-wrapper
if [ -n "$NVIM" ]; then
  nvim() {
    if [ -z "$NVIM" ]; then
      command nvim "$@"
      return
    fi
    if [ $# -eq 0 ]; then
      command nvim --server "$NVIM" --remote-send \
        '<C-\><C-n>:lua require("user.window").focus_editor()<CR>' >/dev/null 2>&1
      return
    fi
    local arg abs
    for arg in "$@"; do
      if [ -e "$arg" ]; then
        abs=$(realpath "$arg")
      else
        case "$arg" in
          /*) abs="$arg" ;;
          *)  abs="$PWD/$arg" ;;
        esac
      fi
      command nvim --server "$NVIM" --remote-send \
        '<C-\><C-n>:lua require("user.window").open_in_editor([['"$abs"']])<CR>' \
        >/dev/null 2>&1
    done
  }
fi
BASHRC_EOF

echo "Installed nvim-remote-wrapper in ~/.bashrc"
echo "Run: source ~/.bashrc"
