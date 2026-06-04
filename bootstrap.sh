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

# 5. Install the tmux plugins non-interactively (avoids needing `prefix + I`)
echo "==> Installing tmux plugins"
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || \
  echo "   (if this failed, start a fresh tmux and press  \` + I  manually)"

cat <<'EOF'

==> Done. Final steps:
    1. Start a FRESH tmux (run `tmux kill-server` first if one is already running)
       so the new config + plugins load.
    2. Launch Ghostty fresh so it picks up the new config.
    Starship/yazi work immediately in a new shell.
    To update plugins later:  ` + U   (backtick is the prefix).
EOF
