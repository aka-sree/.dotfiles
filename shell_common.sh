# shell_common.sh — shared config sourced by both .bashrc and .zshrc

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls='eza --icons'
alias cat='batcat'
alias tree='eza --icons --tree'
alias nv='nvim .'
alias lg='lazygit'
alias sm='git submodule update --init --recursive'
alias smf='git submodule update --init --recursive --force'
alias ssh-init='eval "$(ssh-agent -s)" && for key in ~/.ssh/*; do [[ -f "$key" && "$(head -c 5 "$key")" == "-----" ]] && ssh-add "$key"; done'
alias copypath='wslpath -w "$(pwd)" | clip.exe'

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
open_with() {
  local prog="$1"
  shift
  [[ -z "$prog" ]] && { echo "Usage: open_with <program_name>"; return 1; }

  local pattern=""
  case "$prog" in
    keil)   pattern="*.uvproj*" ;;
    utopia) pattern="*.iox*" ;;
    excel)  pattern="*.xlsx" ;;
    *)      echo "No mappings for '$prog'"; return 1 ;;
  esac

  find . -maxdepth 5 -iname "$pattern" -print | sort -n \
    | fzf --preview 'batcat --style=numbers --color=always {}' --height 70% --tmux 70% \
    | xargs -r cmd.exe /C start
}
alias ow='open_with'

cf() {
  local file
  file=$(find . -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h" \) | fzf)
  [[ -n "$file" ]] && { echo "Formatting $file..."; clang-format -i "$file"; echo "Done."; } || echo "No file selected."
}

timeshell() {
  local shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time "$shell" -i -c exit; done
}

# ---------------------------------------------------------------------------
# Lazy-load NVM (saves ~300ms on shell startup)
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"

if [ -n "$ZSH_VERSION" ]; then
  # zsh: use unfunction
  nvm()  { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; nvm "$@"; }
  node() { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
  npm()  { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"; }
  npx()  { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@"; }
else
  # bash: use unset -f
  nvm()  { unset -f nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; nvm "$@"; }
  node() { unset -f nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
  npm()  { unset -f nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"; }
  npx()  { unset -f nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@"; }
fi
