#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Package map: Debian name → Fedora name
# Format: [debian_name]="fedora_name"
# Use "SKIP" as the fedora name if the package is not needed (built-in, etc.)
# ---------------------------------------------------------------------------

declare -A PKG_MAP=(
  [build-essential]="gcc gcc-c++ make" # Fedora has no single meta-package
  [git]="git"
  [ripgrep]="ripgrep"
  [fzf]="fzf"
  [dos2unix]="dos2unix"
  [eza]="eza"
  [cmake]="cmake"
  [clang]="clang"
  [bat]="bat"
  [clang-tidy]="clang-tools-extra" # clang-tidy ships in clang-tools-extra on Fedora
)

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
fedora)
  is_fedora=true
  ;;
debian | ubuntu | linuxmint | pop)
  is_debian=true
  ;;
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
# Build the final package list for the current distro
# ---------------------------------------------------------------------------

debian_packages=()
fedora_packages=()

for deb_pkg in "${!PKG_MAP[@]}"; do
  fedora_pkg="${PKG_MAP[$deb_pkg]}"
  debian_packages+=("$deb_pkg")
  # A Fedora entry can be multiple space-separated packages (e.g. build-essential)
  read -ra tokens <<<"$fedora_pkg"
  fedora_packages+=("${tokens[@]}")
done

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

if $is_debian; then
  echo "Updating package index..."
  sudo apt-get update -y

  echo "Installing development tools..."
  sudo apt-get install -y "${debian_packages[@]}"

  echo "Cleaning up..."
  sudo apt-get autoremove -y
  sudo apt-get clean -y

elif $is_fedora; then
  echo "Refreshing DNF metadata..."
  sudo dnf check-update -y || true # check-update exits 100 when updates exist; suppress that

  echo "Installing development tools..."
  sudo dnf install -y "${fedora_packages[@]}"

  echo "Cleaning up..."
  sudo dnf autoremove -y
  sudo dnf clean all
fi

# ---------------------------------------------------------------------------
# Verify installs
# ---------------------------------------------------------------------------

echo "Verifying installs..."

verify_debian() {
  local pkg="$1"
  dpkg -s "$pkg" >/dev/null 2>&1
}

verify_fedora() {
  # rpm -q works for single packages; for multi-token entries check each token
  local pkg="$1"
  rpm -q "$pkg" >/dev/null 2>&1
}

all_ok=true

for deb_pkg in "${!PKG_MAP[@]}"; do
  fedora_pkg="${PKG_MAP[$deb_pkg]}"

  if $is_debian; then
    if verify_debian "$deb_pkg"; then
      echo "✔  $deb_pkg installed"
    else
      echo "✖  $deb_pkg failed to install" >&2
      all_ok=false
    fi

  elif $is_fedora; then
    read -ra tokens <<<"$fedora_pkg"
    pkg_ok=true
    for token in "${tokens[@]}"; do
      if ! verify_fedora "$token"; then
        pkg_ok=false
        break
      fi
    done
    if $pkg_ok; then
      echo "✔  $deb_pkg ($fedora_pkg) installed"
    else
      echo "✖  $deb_pkg ($fedora_pkg) failed to install" >&2
      all_ok=false
    fi
  fi
done

if ! $all_ok; then
  echo "One or more packages failed to install." >&2
  exit 1
fi

echo "All requested packages installed successfully."
