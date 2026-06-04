#!/usr/bin/env bash
# Bootstrap a machine from these dotfiles. Idempotent — safe to re-run.
# Usage:  git clone https://github.com/jacobdaviescam/dotfiles.git ~/dotfiles
#         ~/dotfiles/bootstrap.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(tmux ghostty yazi starship)

echo "==> dotfiles: $DOTFILES_DIR"

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Tools these configs need
echo "==> Installing tools (stow, tmux, yazi, starship, ghostty)"
brew install stow tmux yazi starship >/dev/null
brew install --cask ghostty >/dev/null 2>&1 || echo "   (ghostty cask already present or installed manually)"

# 3. Symlink the configs into place
echo "==> Stowing packages: ${PACKAGES[*]}"
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  stow --restow --target="$HOME" "$pkg"
  echo "   linked $pkg"
done

# 4. tmux plugin manager (tmux.conf expects it at ~/.tmux/plugins/tpm)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "==> Installing TPM (tmux plugin manager)"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

cat <<'EOF'

==> Done. Final manual steps:
    1. Start tmux, then press  ` + I   (backtick is the prefix) to install tmux plugins.
    2. Launch Ghostty fresh so it picks up the new config.
    Starship/yazi work immediately in a new shell.
EOF
