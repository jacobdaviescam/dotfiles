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

## Conventions

- **Never commit secrets.** No SSH private keys, tokens, or `~/.config/gh/hosts.yml`.
- **Per-device differences** go in `*.local` files (git-ignored), sourced by the
  shared config — e.g. a shared `.zshrc` ending in `source ~/.zshrc.local`.
- tmux plugins are installed by TPM, not tracked here.
