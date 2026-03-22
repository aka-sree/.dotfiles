#!/usr/bin/env bash
# Install tmux and TPM (Tmux Plugin Manager) on Fedora 43 and Debian-based distros.
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
# Install tmux
# ---------------------------------------------------------------------------

echo "Installing tmux..."

if $is_debian; then
  sudo apt-get update -y
  sudo apt-get install -y tmux git

  if dpkg -s tmux >/dev/null 2>&1; then
    echo "✔  tmux installed"
  else
    echo "✖  tmux failed to install" >&2
    exit 1
  fi

elif $is_fedora; then
  sudo dnf install -y tmux git

  if rpm -q tmux >/dev/null 2>&1; then
    echo "✔  tmux installed"
  else
    echo "✖  tmux failed to install" >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Install TPM (Tmux Plugin Manager)
# ---------------------------------------------------------------------------

echo "Installing TPM (Tmux Plugin Manager)..."

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
  echo "TPM already installed, updating..."
  git -C "$TPM_DIR" pull
else
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ---------------------------------------------------------------------------
# Install tmux plugins
# ---------------------------------------------------------------------------

# TPM's install_plugins requires a running tmux server to send commands to.
# Start a detached background session if one is not already running, run the
# installer, then kill the throwaway session.

echo "Installing tmux plugins..."

throwaway_session="tpm-install-$$"
tmux_was_running=false

if tmux list-sessions &>/dev/null 2>&1; then
  tmux_was_running=true
fi

if ! $tmux_was_running; then
  tmux new-session -d -s "$throwaway_session"
fi

"$TPM_DIR/bin/install_plugins" || {
  echo "Warning: TPM plugin install exited non-zero — plugins may be partially installed." >&2
}

if ! $tmux_was_running; then
  tmux kill-session -t "$throwaway_session" 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo "tmux setup complete."
