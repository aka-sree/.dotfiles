#!/usr/bin/env bash
# Install bash-completion and set bash as the default shell on Fedora and Debian-based distros.
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
# Install bash and bash-completion
# ---------------------------------------------------------------------------

echo "Installing bash-completion..."

if $is_debian; then
  sudo apt-get update -y
  sudo apt-get install -y bash bash-completion git curl
elif $is_fedora; then
  sudo dnf install -y bash bash-completion git curl util-linux-user
fi

# ---------------------------------------------------------------------------
# Set bash as default shell
# ---------------------------------------------------------------------------

bash_path="$(command -v bash)"

if [[ "$(basename "${SHELL:-}")" != "bash" ]]; then
  echo "Setting default shell to $bash_path..."

  if ! grep -qxF "$bash_path" /etc/shells; then
    echo "Adding $bash_path to /etc/shells..."
    echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$bash_path" || echo "Warning: chsh failed — change your shell manually with: chsh -s $bash_path"
else
  echo "Default shell is already bash — skipping chsh."
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo "✅ Bash + bash-completion installed."
echo "ℹ️  Start a new shell session or run: exec bash"
