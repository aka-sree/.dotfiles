#!/usr/bin/env bash
# Install Caskaydia Cove Nerd Font on Linux or WSL.
# - Native Linux: installs to ~/.local/share/fonts (or $XDG_DATA_HOME/fonts) and refreshes font cache.
# - WSL: installs to Linux font dir above AND tries to copy into Windows host fonts at /mnt/c/Windows/Fonts.
# Supports Fedora 43 and Debian-based distros. Exits on first error.
set -euo pipefail

URL="${URL:-https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip}"

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
# Helpers
# ---------------------------------------------------------------------------

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: '$1' is required." >&2
    exit 1
  }
}

is_wsl() {
  [[ -f /proc/sys/kernel/osrelease ]] && grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease
}

# ---------------------------------------------------------------------------
# Ensure dependencies: unzip + curl/wget + fc-cache (fontconfig)
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

# unzip — same package name on both distros
if ! command -v unzip >/dev/null 2>&1; then
  install_pkg unzip
fi

# curl — same package name on both distros
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  install_pkg curl
fi

# fontconfig (provides fc-cache) — package name differs
# Debian: fontconfig | Fedora: fontconfig (same, but may not be installed by default)
if ! command -v fc-cache >/dev/null 2>&1; then
  install_pkg fontconfig
fi

# ---------------------------------------------------------------------------
# Pick download command
# ---------------------------------------------------------------------------

DL_CMD=""
if command -v curl >/dev/null 2>&1; then
  DL_CMD=(curl -fL --retry 3 --connect-timeout 10 -o)
elif command -v wget >/dev/null 2>&1; then
  DL_CMD=(wget -O)
else
  echo "Error: need 'curl' or 'wget'." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Font directories
# ---------------------------------------------------------------------------

# Linux per-user font dir (XDG-compliant; identical on both distros)
if [[ -n "${XDG_DATA_HOME:-}" ]]; then
  LINUX_FONT_DIR="$XDG_DATA_HOME/fonts"
else
  LINUX_FONT_DIR="$HOME/.local/share/fonts"
fi

# Windows Fonts path when running under WSL
WIN_FONTS_DIR="/mnt/c/Windows/Fonts"

# ---------------------------------------------------------------------------
# Download and unpack
# ---------------------------------------------------------------------------

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT # always clean up on exit

zipfile="$tmpdir/CascadiaCode.zip"

echo "Installing Caskaydia Cove Nerd Font"
echo "Source: $URL"

mkdir -p "$LINUX_FONT_DIR"

echo "Downloading..."
"${DL_CMD[@]}" "$zipfile" "$URL"

echo "Unpacking..."
unzip -qq -o "$zipfile" -d "$tmpdir/unzipped"

mapfile -t font_files < <(find "$tmpdir/unzipped" -type f \( -iname '*.ttf' -o -iname '*.otf' \) | sort)

if ((${#font_files[@]} == 0)); then
  echo "Error: no .ttf/.otf files found in ZIP." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Install to Linux font directory
# ---------------------------------------------------------------------------

echo "Copying ${#font_files[@]} font files to: $LINUX_FONT_DIR"
for f in "${font_files[@]}"; do
  cp -f "$f" "$LINUX_FONT_DIR/"
done

echo "Refreshing font cache..."
fc-cache -f "$LINUX_FONT_DIR"

# ---------------------------------------------------------------------------
# WSL: also install to Windows host
# ---------------------------------------------------------------------------

if is_wsl; then
  echo "WSL detected."
  if [[ -d "$WIN_FONTS_DIR" && -w "$WIN_FONTS_DIR" ]]; then
    echo "Copying to Windows host fonts: $WIN_FONTS_DIR"
    for f in "${font_files[@]}"; do
      cp -f "$f" "$WIN_FONTS_DIR"/
    done
    echo "Fonts available to Windows apps after they refresh their font list."
  else
    echo "Note: Can't write to $WIN_FONTS_DIR (admin required). Skipping Windows host install."
  fi
fi

echo "Installed ${#font_files[@]} font files."
echo "Done."
