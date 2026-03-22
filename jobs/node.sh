#!/usr/bin/env bash
# Install the latest LTS version of Node.js using the official NodeSource setup.
# Works on Fedora 43 and Debian/Ubuntu/WSL. Exits immediately on any failure.
set -euo pipefail

# ---------------------------------------------------------------------------
# Detect package manager and distro
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
fedora)
  is_fedora=true
  ;;
debian | ubuntu | linuxmint | pop)
  is_debian=true
  ;;
*)
  # Fallback: check ID_LIKE for derivative distros (e.g. ID=rhel ID_LIKE=fedora)
  if [[ "$os_like" =~ fedora|rhel ]]; then
    is_fedora=true
  elif [[ "$os_like" =~ debian|ubuntu ]]; then
    is_debian=true
  else
    echo "Error: Unsupported distro '$os_id'. This script supports Fedora and Debian-based systems." >&2
    exit 1
  fi
  ;;
esac

echo "Installing Node.js (LTS) on $PRETTY_NAME ..."

# ---------------------------------------------------------------------------
# Ensure curl is available
# ---------------------------------------------------------------------------

if ! command -v curl >/dev/null 2>&1; then
  echo "Installing curl (required for setup)..."
  if $is_fedora; then
    sudo dnf install -y curl
  else
    sudo apt-get update -y
    sudo apt-get install -y curl
  fi
fi

# ---------------------------------------------------------------------------
# Install Node.js LTS via the appropriate NodeSource setup
# ---------------------------------------------------------------------------

if $is_fedora; then
  # NodeSource RPM setup for Fedora
  curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo -E bash -
  sudo dnf install -y nodejs
else
  # NodeSource DEB setup for Debian/Ubuntu
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

# ---------------------------------------------------------------------------
# Verify install
# ---------------------------------------------------------------------------

echo "Node version: $(node -v)"
echo "NPM version:  $(npm -v)"
echo "Node.js installation complete."
