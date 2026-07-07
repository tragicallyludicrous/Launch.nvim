#!/usr/bin/env bash
# Installs ripgrep (`rg`) into ~/.local/bin. The picker (mini.pick) and any
# live-grep rely on it; without it Neovim's :checkhealth warns "ripgrep not
# available" and grep-based pickers fall back to a much slower path.
#
# Idempotent: skips if `rg` is already on PATH (so it's a no-op on machines that
# install it via Homebrew/apt/cargo — e.g. macOS). No sudo required, which is
# why we fetch the prebuilt binary instead of using the system package manager
# (locked-down codespaces can't sudo). Run once per fresh environment:
#   bash scripts/setup-ripgrep.sh && source ~/.bashrc
set -euo pipefail

RG_VERSION="${RG_VERSION:-14.1.1}"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/rg"

if command -v rg >/dev/null 2>&1; then
  echo "ripgrep already present: $(command -v rg) ($(rg --version 2>/dev/null | head -1 || echo '?'))"
  exit 0
fi

# Map uname to the release target triple (each tarball extracts to a directory
# containing the `rg` binary plus man/completions).
case "$(uname -s)/$(uname -m)" in
  Linux/x86_64|Linux/amd64)    target="x86_64-unknown-linux-musl" ;;
  Linux/aarch64|Linux/arm64)   target="aarch64-unknown-linux-gnu" ;;
  Darwin/x86_64|Darwin/amd64)  target="x86_64-apple-darwin" ;;
  Darwin/aarch64|Darwin/arm64) target="aarch64-apple-darwin" ;;
  *) echo "Unsupported platform '$(uname -s)/$(uname -m)' — install ripgrep manually." >&2; exit 1 ;;
esac

asset="ripgrep-${RG_VERSION}-${target}"
url="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${asset}.tar.gz"

echo "Downloading ${asset} (${RG_VERSION}) ..."
mkdir -p "$BIN_DIR"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" -o "$tmp/rg.tar.gz"
tar -C "$tmp" -xzf "$tmp/rg.tar.gz"
install -m755 "$tmp/${asset}/rg" "$DEST"
echo "Installed: $DEST ($("$DEST" --version 2>/dev/null | head -1 || echo 'version check failed'))"

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
echo "Done. Open a new shell (or 'source ~/.bashrc') and launch Neovim."
