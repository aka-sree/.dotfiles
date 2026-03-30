#!/usr/bin/env bash
# Install Zsh, Oh My Zsh, plugins, and Powerlevel10k on Fedora 43 and Debian-based distros.
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
# Install system dependencies: zsh, git, curl
# ---------------------------------------------------------------------------
# util-linux provides 'chsh' on both distros but may not be present in
# Fedora minimal installs — install it explicitly.

echo "Installing dependencies..."

if $is_debian; then
  sudo apt-get update -y
  sudo apt-get install -y zsh git curl
elif $is_fedora; then
  sudo dnf install -y zsh git curl util-linux-user
  # util-linux-user provides chsh on Fedora; on Debian it ships with passwd
fi

# ---------------------------------------------------------------------------
# Install Oh My Zsh (unattended)
# ---------------------------------------------------------------------------

ZSH="${ZSH:-$HOME/.oh-my-zsh}"

if [[ ! -d "$ZSH" ]]; then
  echo "Installing Oh My Zsh..."
  # RUNZSH=no  — don't launch zsh at the end of the installer
  # CHSH=no    — we handle chsh ourselves below so we can handle failures
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed at $ZSH — skipping."
fi

# ---------------------------------------------------------------------------
# Plugin / theme directory
# ---------------------------------------------------------------------------

# Oh My Zsh sets ZSH_CUSTOM to $ZSH/custom by default.
# Preserve that convention rather than pointing directly at $ZSH.
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
echo "ZSH_CUSTOM: $ZSH_CUSTOM"

# ---------------------------------------------------------------------------
# Helper: clone or update a git repo
# ---------------------------------------------------------------------------

ensure_repo() {
  local url="$1"
  local dest="$2"
  if [[ -d "$dest/.git" ]]; then
    echo "Updating: $dest"
    git -C "$dest" pull --ff-only
  else
    echo "Cloning: $url → $dest"
    git clone --depth=1 "$url" "$dest"
  fi
}

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------

echo "Installing plugins..."
ensure_repo https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

ensure_repo https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

ensure_repo https://github.com/zdharma-continuum/fast-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

# ---------------------------------------------------------------------------
# Theme: Powerlevel10k
# ---------------------------------------------------------------------------

echo "Installing Powerlevel10k theme..."
ensure_repo https://github.com/romkatv/powerlevel10k \
  "$ZSH_CUSTOM/themes/powerlevel10k"

# ---------------------------------------------------------------------------
# Set zsh as default shell
# ---------------------------------------------------------------------------

zsh_path="$(command -v zsh)"

if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
  echo "Setting default shell to $zsh_path..."

  # /etc/shells must list the zsh path for chsh to accept it.
  # On Fedora, dnf installs zsh to /usr/bin/zsh which is already listed.
  # On Debian it's /usr/bin/zsh too — but guard anyway for custom installs.
  if ! grep -qxF "$zsh_path" /etc/shells; then
    echo "Adding $zsh_path to /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$zsh_path" || echo "Warning: chsh failed — change your shell manually with: chsh -s $zsh_path"
else
  echo "Default shell is already zsh — skipping chsh."
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo "✅ Zsh + Oh My Zsh installed."
echo "✅ Plugins cloned: autosuggestions, syntax-highlighting, fast-syntax-highlighting."
echo "✅ Theme cloned: powerlevel10k."
echo "ℹ️  Start a new shell session or run: exec zsh"
