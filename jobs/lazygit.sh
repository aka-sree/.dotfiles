#!/usr/bin/env bash
# Install LazyGit on Fedora 43 and Debian-based distros.
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

if command -v lazygit &>/dev/null; then
  echo "lazygit is already installed ($(lazygit --version))"
  exit 0
fi

# ---------------------------------------------------------------------------
# Ensure dependencies: curl, tar
# ---------------------------------------------------------------------------

install_pkg() {
  local pkg="$1"
  echo "Installing missing dependency: $pkg ..."
  if $is_fedora; then
    sudo dnf install -y "$pkg"
  else
    sudo apt-get update -y
    sudo apt-get install -y "$pkg"
  fi
}

for dep in curl tar; do
  if ! command -v "$dep" &>/dev/null; then
    install_pkg "$dep"
  fi
done

# ---------------------------------------------------------------------------
# Detect architecture
# ---------------------------------------------------------------------------
# lazygit release asset names use Go-style arch identifiers:
#   x86_64, arm64, armv6 — must match exactly what GitHub publishes.

raw_arch="$(uname -m)"
case "$raw_arch" in
x86_64) arch="x86_64" ;;
aarch64 | arm64) arch="arm64" ;;
armv6l) arch="armv6" ;;
*)
  echo "Error: Unsupported architecture '$raw_arch'." >&2
  exit 1
  ;;
esac

echo "Architecture: $arch"

# ---------------------------------------------------------------------------
# Resolve latest version from GitHub API
# ---------------------------------------------------------------------------

echo "Fetching latest lazygit version..."

LAZYGIT_VERSION=$(
  curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
    grep -Po '"tag_name":\s*"v\K[^"]*'
)

if [[ -z "$LAZYGIT_VERSION" ]]; then
  echo "Error: Could not determine latest lazygit version." >&2
  exit 1
fi

echo "Latest version: v${LAZYGIT_VERSION}"

# ---------------------------------------------------------------------------
# Download, verify, install
# ---------------------------------------------------------------------------

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

tarball="$tmpdir/lazygit.tar.gz"
asset_url="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${arch}.tar.gz"

echo "Downloading: $asset_url"
curl -fsSL --retry 3 --connect-timeout 10 -o "$tarball" "$asset_url"

echo "Unpacking..."
tar -xf "$tarball" -C "$tmpdir" lazygit

echo "Installing to /usr/local/bin/..."
sudo install -D -t /usr/local/bin/ "$tmpdir/lazygit"

# ---------------------------------------------------------------------------
# Verify
# ---------------------------------------------------------------------------

if command -v lazygit &>/dev/null; then
  echo "lazygit installed successfully ($(lazygit --version))"
else
  echo "Error: lazygit installation could not be verified." >&2
  exit 1
fi
