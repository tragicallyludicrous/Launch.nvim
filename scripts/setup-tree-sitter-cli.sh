#!/usr/bin/env bash
# Installs the tree-sitter CLI that nvim-treesitter's `main` branch needs to
# build parsers (`tree-sitter build`). Environments without it — e.g. CS50
# codespaces — fail on file open with:
#   [nvim-treesitter] Error during "tree-sitter build": ENOENT ... (cmd): 'tree-sitter'
#
# Idempotent: skips if the CLI is already on PATH (so it's a no-op on machines
# that install it via Homebrew/cargo). Run once per fresh codespace:
#   bash scripts/setup-tree-sitter-cli.sh && source ~/.bashrc
set -euo pipefail

TS_CLI_VERSION="${TS_CLI_VERSION:-v0.26.9}"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/tree-sitter"

if command -v tree-sitter >/dev/null 2>&1; then
  echo "tree-sitter CLI already present: $(command -v tree-sitter) ($(tree-sitter --version 2>/dev/null || echo '?'))"
  exit 0
fi

# Map uname to the release asset name (single gzipped binary).
case "$(uname -s)" in
  Linux)  os_tag="linux" ;;
  Darwin) os_tag="macos" ;;
  *) echo "Unsupported OS '$(uname -s)' — install the tree-sitter CLI manually." >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64)  arch_tag="x64" ;;
  aarch64|arm64) arch_tag="arm64" ;;
  *) echo "Unsupported arch '$(uname -m)' — install the tree-sitter CLI manually." >&2; exit 1 ;;
esac

asset="tree-sitter-${os_tag}-${arch_tag}.gz"
url="https://github.com/tree-sitter/tree-sitter/releases/download/${TS_CLI_VERSION}/${asset}"

echo "Downloading ${asset} (${TS_CLI_VERSION}) ..."
mkdir -p "$BIN_DIR"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp"
gunzip -c "$tmp" >"$DEST"
chmod +x "$DEST"
echo "Installed: $DEST ($("$DEST" --version 2>/dev/null || echo 'version check failed'))"

# Ensure ~/.local/bin is on PATH for future interactive shells (and thus nvim,
# which inherits PATH from the shell that launches it).
if [ -f "$HOME/.bashrc" ] && ! grep -qsF '# local-bin-path' "$HOME/.bashrc"; then
  cat >>"$HOME/.bashrc" <<'EOF'

# local-bin-path
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
  echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

echo
echo "Done. Open a new shell (or 'source ~/.bashrc'), launch Neovim, and run :TSUpdate"
