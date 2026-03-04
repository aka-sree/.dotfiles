#!/usr/bin/env bash
set -euo pipefail

if command -v nvim &>/dev/null; then
    echo "neovim is already installed: $(nvim --version | head -1)"
    exit 0
fi

NVIM_SRC="$HOME/personal/neovim"

if [ ! -d "$NVIM_SRC" ]; then
    git clone -b release-0.11 --depth=1 https://github.com/neovim/neovim.git "$NVIM_SRC"
fi

sudo apt-get install -y cmake gettext lua5.1 liblua5.1-0-dev

cd "$NVIM_SRC"
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

echo "neovim installed: $(nvim --version | head -1)"
