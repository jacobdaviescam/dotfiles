# dotfiles

Cross-device configs, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level folder is a **package** whose internal tree mirrors `$HOME`, so
`stow tmux` symlinks `tmux/.config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`.

## Packages

| Package | What it is | Lands at |
|---------|-----------|----------|
| `tmux` | Terminal multiplexer config (+ reset file) | `~/.config/tmux/` |
| `ghostty` | Ghostty terminal config + Catppuccin Mocha theme | `~/.config/ghostty/` |
| `yazi` | Yazi file manager theme | `~/.config/yazi/` |
| `starship` | Shell prompt config (the prompt line: dir, git branch, etc.) | `~/.config/starship.toml` |

## New machine

```bash
git clone https://github.com/jacobdaviescam/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

Then: start tmux and press `` ` `` + `I` to install tmux plugins; relaunch Ghostty.

## Day-to-day

- Edit the file in `~/dotfiles/...` (or via its symlink — same inode), then
  `git -C ~/dotfiles commit -am "..." && git -C ~/dotfiles push`.
- On the other machine: `git -C ~/dotfiles pull` (symlinks already point here, so
  changes are live immediately).
- Add a new config: create `pkg/.config/.../file`, then `stow pkg`.

## Remote GPU pods (RunPod)

Provision a fresh headless Linux pod with tmux + Claude Code + git + gh in one command.

**One-time, on your laptop:** generate a subscription-backed Claude token (needs a browser):
```bash
claude setup-token        # prints CLAUDE_CODE_OAUTH_TOKEN
```
Put that token and a GitHub PAT into your **RunPod template's env vars / Secrets** as
`CLAUDE_CODE_OAUTH_TOKEN` and `GH_TOKEN`. Then every pod is pre-authenticated.

**On a fresh pod:**
```bash
curl -fsSL https://raw.githubusercontent.com/jacobdaviescam/dotfiles/main/remote-bootstrap.sh | bash
tmux new -A -s main
```
Installs tmux (lean `remote/tmux.conf`), Claude Code (native installer), gh, git
identity, uv, and mosh-server. Reads secrets/identity from env vars (see top of
`remote-bootstrap.sh`). Defaults git identity to personal; override with
`GIT_USER_NAME`/`GIT_USER_EMAIL`.

**Local helpers** (`bin/` — add to PATH: `export PATH="$HOME/dotfiles/bin:$PATH"`):
- `pod <ssh args>` — SSH in and attach/create a persistent `main` tmux session.
  `mosh`-friendly: install `brew install mosh` locally for drop-proof reconnects.
- `pods-setup "root@h1 -p p1" "root@h2 -p p2"` — run the bootstrap on many pods in
  parallel, forwarding `CLAUDE_CODE_OAUTH_TOKEN`/`GH_TOKEN` from your local env.

**Fan-out tip:** open one tmux pane per pod, press `` ` `` + `*` to toggle
`synchronize-panes`, then type/paste a command once to run it on every pod at once.

## Conventions

- **Never commit secrets.** No SSH private keys, tokens, or `~/.config/gh/hosts.yml`.
- **Per-device differences** go in `*.local` files (git-ignored), sourced by the
  shared config — e.g. a shared `.zshrc` ending in `source ~/.zshrc.local`.
- tmux plugins are installed by TPM, not tracked here.
