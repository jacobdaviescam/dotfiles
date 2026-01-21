#!/bin/bash
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf
