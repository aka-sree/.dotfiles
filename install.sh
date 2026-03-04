#!/bin/bash

# Define the source of truth
SETUP_DIR=$HOME/linux-setup

echo "--- 1. Installing Plugin Managers ---"
# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "--- 2. Creating Symlinks ---"
# Ensure Neovim config directory exists
mkdir -p $HOME/.config/nvim

# Force-link Shell & Tmux
ln -sf $SETUP_DIR/zshrc $HOME/.zshrc
ln -sf $SETUP_DIR/bashrc $HOME/.bashrc
ln -sf $SETUP_DIR/tmux.conf $HOME/.tmux.conf

# Force-link Neovim
ln -sf $SETUP_DIR/nvim/init.lua $HOME/.config/nvim/init.lua

# Use -n to prevent nesting the lua folder inside itself
if [ -d "$SETUP_DIR/nvim/lua" ]; then
    ln -sfn $SETUP_DIR/nvim/lua $HOME/.config/nvim/lua
fi

echo "--- 3. Setup Complete ---"
echo "Restart terminal and run: tmux source-file ~/.tmux.conf"
