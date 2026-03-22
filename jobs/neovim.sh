#!/usr/bin/env bash
# Install Neovim from source on Fedora 43 and Debian-based distros.
set -euo pipefail

# ---------------------------------------------------------------------------
# Detect distro
# ---------------------------------------------------------------------------

if [[ ! -f /etc/os-release ]]; then
  echo "Error: Cannot detect OS — /etc/os-release not found." >&2
  exit 1
fi

. /etc/os-release
os_id="${ID:-unknown}"
os_like="${ID_LIKE:-}"

is_fedora=false
is_debian=false

case "$os_id" in
fedora) is_fedora=true ;;
debian | ubuntu | linuxmint | pop) is_debian=true ;;
*)
  if [[ "$os_like" =~ fedora|rhel ]]; then
    is_fedora=true
  elif [[ "$os_like" =~ debian|ubuntu ]]; then
    is_debian=true
  else
    echo "Error: Unsupported distro '$os_id'." >&2
    exit 1
  fi
  ;;
esac

echo "Detected OS: ${PRETTY_NAME}"

# ---------------------------------------------------------------------------
# Already installed?
# ---------------------------------------------------------------------------

if command -v nvim &>/dev/null; then
  echo "Neovim is already installed: $(nvim --version | head -1)"
  exit 0
fi

# ---------------------------------------------------------------------------
# Install build dependencies
# ---------------------------------------------------------------------------
# Debian:  cmake gettext lua5.1 liblua5.1-0-dev + core build tools
# Fedora:  cmake gettext lua lua-devel + core build tools
# ninja-build is the same name on both distros and dramatically speeds up builds.

echo "Installing build dependencies..."

if $is_debian; then
  sudo apt-get update -y
  sudo apt-get install -y \
    git \
    cmake \
    gettext \
    ninja-build \
    lua5.1 \
    liblua5.1-0-dev \
    build-essential \
    unzip \
    curl
elif $is_fedora; then
  sudo dnf install -y \
    git \
    cmake \
    gettext \
    ninja-build \
    lua \
    lua-devel \
    gcc \
    gcc-c++ \
    make \
    unzip \
    curl
fi

# ---------------------------------------------------------------------------
# Clone source
# ---------------------------------------------------------------------------

NVIM_SRC="$HOME/personal/neovim"

if [[ ! -d "$NVIM_SRC" ]]; then
  echo "Cloning Neovim (release-0.11)..."
  git clone -b release-0.11 --depth=1 https://github.com/neovim/neovim.git "$NVIM_SRC"
else
  echo "Source directory already exists: $NVIM_SRC — skipping clone."
fi

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

echo "Building Neovim (this may take a few minutes)..."
cd "$NVIM_SRC"

# Use ninja when available — it is installed above on both distros.
# CMAKE_INSTALL_PREFIX defaults to /usr/local on both distros.
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-G Ninja"

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

echo "Installing Neovim..."
sudo make install

# ---------------------------------------------------------------------------
# Verify
# ---------------------------------------------------------------------------

if command -v nvim &>/dev/null; then
  echo "Neovim installed successfully: $(nvim --version | head -1)"
else
  echo "Error: Neovim installation could not be verified." >&2
  exit 1
fi
