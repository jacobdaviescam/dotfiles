# Tmux Cheatsheet

Prefix key: `` ` `` (backtick)

## Sessions

| Keys | Action |
|------|--------|
| `` ` `` + `o` | Open sessionx (session picker) |
| `` ` `` + `S` | Choose session |
| `` ` `` + `^A` | Last window |
| `` ` `` + `^D` | Detach |
| `` ` `` + `:kill-session` | Kill current session |

## Windows

| Keys | Action |
|------|--------|
| `` ` `` + `^C` | New window |
| `` ` `` + `H` | Previous window |
| `` ` `` + `L` | Next window |
| `` ` `` + `r` | Rename window |
| `` ` `` + `w` | List windows |
| `` ` `` + `"` | Choose window |

## Panes

| Keys | Action |
|------|--------|
| `` ` `` + `v` | Split horizontal |
| `` ` `` + `s` | Split vertical |
| `` ` `` + `h` | Navigate left |
| `` ` `` + `j` | Navigate down |
| `` ` `` + `k` | Navigate up |
| `` ` `` + `l` | Navigate right |
| `` ` `` + `,` | Resize left |
| `` ` `` + `.` | Resize right |
| `` ` `` + `-` | Resize down |
| `` ` `` + `=` | Resize up |
| `` ` `` + `z` | Zoom/unzoom pane |
| `` ` `` + `c` | Kill pane |
| `` ` `` + `x` | Swap pane down |
| `` ` `` + `*` | Sync panes (type in all) |
| `` ` `` + `P` | Toggle pane border status |

## Plugins

| Keys | Action |
|------|--------|
| `` ` `` + `p` | Floax (floating terminal) |
| `` ` `` + `I` | Install plugins (TPM) |
| `` ` `` + `U` | Update plugins (TPM) |

## Other

| Keys | Action |
|------|--------|
| `` ` `` + `R` | Reload config |
| `` ` `` + `K` | Clear screen |
| `` ` `` + `^L` | Refresh client |
| `` ` `` + `^X` | Lock server |
| `` ` `` + `:` | Command prompt |

## Copy Mode (vi keys)

| Keys | Action |
|------|--------|
| `` ` `` + `[` | Enter copy mode |
| `v` | Begin selection |
| `y` | Yank (copy) |

## Setup on New Instance

```bash
# Clone dotfiles
git clone https://github.com/jacobdaviescam/dotfiles.git ~/dotfiles

# Create config directory and symlinks
mkdir -p ~/.config/tmux
ln -sf ~/dotfiles/tmux.conf ~/.config/tmux/tmux.conf
ln -sf ~/dotfiles/tmux.reset.conf ~/.config/tmux/tmux.reset.conf

# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux and install plugins
tmux
# Press ` + I to install plugins
# Press ` + R to reload config
```
