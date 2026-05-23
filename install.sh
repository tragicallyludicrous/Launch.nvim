#!/usr/bin/env bash
# Runs in GitHub Codespaces during dotfiles install.
# Codespaces clones this repo to ~/dotfiles then executes this script.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# 1. Symlink this repo to ~/.config/nvim
mkdir -p "$HOME/.config"
if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
ln -sfn "$DOTFILES" "$HOME/.config/nvim"

# 2. Install Neovim 0.11+ to ~/.local (config requires it)
case "$(uname -m)" in
  x86_64)        NVIM_ARCH="linux-x86_64" ;;
  aarch64|arm64) NVIM_ARCH="linux-arm64"  ;;
  *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
esac

mkdir -p "$HOME/.local/bin"
curl -fsSL -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
tar -C "$HOME/.local" -xzf /tmp/nvim.tar.gz
ln -sfn "$HOME/.local/nvim-${NVIM_ARCH}/bin/nvim" "$HOME/.local/bin/nvim"

# Put ~/.local/bin on PATH for future shells
if ! grep -qs '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/.local/bin:$PATH"

# 3. Black (used by none-ls for Python formatting); style50/check50/submit50
#    are already present in the CS50 codespace image.
if ! command -v black >/dev/null 2>&1; then
  pipx install black 2>/dev/null || pip install --user black 2>/dev/null || true
fi

# 4. Headless plugin install so first interactive launch is snappy
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo "nvim dotfiles installed. Run 'nvim' to start."
