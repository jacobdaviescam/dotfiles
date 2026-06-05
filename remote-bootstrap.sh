#!/usr/bin/env bash
# Provision a fresh headless Linux pod (RunPod / Ubuntu) with tmux + claude + git + gh.
# Idempotent. Run on the pod:
#   curl -fsSL https://raw.githubusercontent.com/jacobdaviescam/dotfiles/main/remote-bootstrap.sh | bash
#
# Secrets/identity are read from the environment (inject via RunPod template env vars / Secrets):
#   CLAUDE_CODE_OAUTH_TOKEN   long-lived Claude token from `claude setup-token` (subscription)  [or ANTHROPIC_API_KEY]
#   GH_TOKEN                  GitHub PAT (lets gh + git push work non-interactively)
#   GIT_USER_NAME             defaults to jacobdaviescam
#   GIT_USER_EMAIL            defaults to personal noreply
#   INSTALL_UV=0              set to 0 to skip installing uv (python tooling)
set -uo pipefail

RAW="https://raw.githubusercontent.com/jacobdaviescam/dotfiles/main"
SUDO="$(command -v sudo || true)"
GIT_USER_NAME="${GIT_USER_NAME:-jacobdaviescam}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-119947345+jacobdaviescam@users.noreply.github.com}"
INSTALL_UV="${INSTALL_UV:-1}"

log() { printf '\n==> %s\n' "$*"; }

# 1. System packages -----------------------------------------------------------
log "Installing system packages (tmux, git, curl, mosh)"
if command -v apt-get >/dev/null 2>&1; then
  $SUDO apt-get update -y -qq
  $SUDO apt-get install -y -qq tmux git curl ca-certificates mosh gnupg
elif command -v dnf >/dev/null 2>&1; then
  $SUDO dnf install -y -q tmux git curl mosh
elif command -v apk >/dev/null 2>&1; then
  $SUDO apk add --no-cache tmux git curl mosh
else
  echo "!! Unknown package manager; install tmux/git/curl/mosh manually" >&2
fi

# 2. GitHub CLI ----------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  log "Installing GitHub CLI"
  if command -v apt-get >/dev/null 2>&1; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    $SUDO apt-get update -y -qq && $SUDO apt-get install -y -qq gh
  else
    echo "   (install gh manually for this distro: https://github.com/cli/cli#installation)"
  fi
fi

# 3. Claude Code (native installer, no node needed) ----------------------------
if ! command -v claude >/dev/null 2>&1; then
  log "Installing Claude Code"
  curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"

# 4. uv (python) — optional ----------------------------------------------------
if [ "$INSTALL_UV" = "1" ] && ! command -v uv >/dev/null 2>&1; then
  log "Installing uv (python tooling)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 5. Git identity --------------------------------------------------------------
log "Configuring git identity: $GIT_USER_NAME <$GIT_USER_EMAIL>"
git config --global user.name  "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true

# 6. gh + git auth (non-interactive if GH_TOKEN provided) ----------------------
if [ -n "${GH_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
  log "Authenticating gh from GH_TOKEN + wiring git credential helper"
  printf '%s' "$GH_TOKEN" | gh auth login --with-token
  gh auth setup-git
else
  echo "   (no GH_TOKEN set — run 'gh auth login' on the pod, or inject GH_TOKEN as a RunPod env var)"
fi

# 7. Claude auth -> persist token so interactive shells pick it up -------------
RC="$HOME/.bashrc"
if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
  grep -q CLAUDE_CODE_OAUTH_TOKEN "$RC" 2>/dev/null || \
    echo "export CLAUDE_CODE_OAUTH_TOKEN='$CLAUDE_CODE_OAUTH_TOKEN'" >> "$RC"
elif [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  grep -q ANTHROPIC_API_KEY "$RC" 2>/dev/null || \
    echo "export ANTHROPIC_API_KEY='$ANTHROPIC_API_KEY'" >> "$RC"
else
  echo "   (no Claude token set — inject CLAUDE_CODE_OAUTH_TOKEN as a RunPod env var; see README)"
fi
grep -q '.local/bin' "$RC" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"

# 8. Lean tmux config ----------------------------------------------------------
log "Installing lean tmux config"
mkdir -p "$HOME/.config/tmux"
curl -fsSL "$RAW/remote/tmux.conf" -o "$HOME/.config/tmux/tmux.conf"

log "Done. Start work with:  tmux new -A -s main"
echo "   claude / gh / git are configured. mosh-server is installed for resilient reconnects."
