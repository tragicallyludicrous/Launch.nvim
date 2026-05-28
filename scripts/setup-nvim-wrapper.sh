#!/usr/bin/env bash
# Installs the nvim-remote-wrapper function into ~/.bashrc.
# Safe to run multiple times — checks for an existing install first.
set -euo pipefail

if grep -qsF '# nvim-remote-wrapper' "$HOME/.bashrc" 2>/dev/null; then
  echo "nvim-remote-wrapper already installed in ~/.bashrc"
  exit 0
fi

# Remove older alias form if present
sed -i "/alias nvim='nvim --server/d" "$HOME/.bashrc" 2>/dev/null || true

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
      [ -e "$arg" ] || continue
      abs=$(realpath "$arg")
      command nvim --server "$NVIM" --remote-send \
        '<C-\><C-n>:lua require("user.window").open_in_editor([['"$abs"']])<CR>' \
        >/dev/null 2>&1
    done
  }
fi
BASHRC_EOF

echo "Installed nvim-remote-wrapper in ~/.bashrc"
echo "Run: source ~/.bashrc"
