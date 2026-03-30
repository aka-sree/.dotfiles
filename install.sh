#!/bin/bash

# Define the source of truth — resolve to the directory this script lives in
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "--- 1. Installing Plugin Managers ---"

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "--- 2. Creating Symlinks ---"
# Ensure ~/.config exists
mkdir -p $HOME/.config

# Force-link Shell & Tmux
ln -sf $SETUP_DIR/bashrc $HOME/.bashrc
ln -sf $SETUP_DIR/zsh/.zshrc $HOME/.zshrc
ln -sf $SETUP_DIR/shell_common.sh $HOME/.shell_common.sh
ln -sf $SETUP_DIR/tmux/.tmux.conf $HOME/.tmux.conf

# Force-link entire Neovim config directory
# Remove any existing nvim config (file, symlink, or directory)
rm -rf $HOME/.config/nvim
ln -sfn $SETUP_DIR/nvim/.config/nvim $HOME/.config/nvim

echo "--- 3. Setup Complete ---"
echo "Restart terminal and run: tmux source-file ~/.tmux.conf"
