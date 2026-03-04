# Enable Powerlevel10k instant prompt (must stay near top).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable omz auto-update check on every shell start (run `omz update` manually)
zstyle ':omz:update' mode disabled

plugins=(
    git
    zsh-autosuggestions
    fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1

source $ZSH/oh-my-zsh.sh

# --- Key bindings ---
function tmux_sessionizer() { ~/.config/bin/tmux-sessionizer.sh "$@"; }
zle -N tmux_sessionizer
bindkey '^[[Z' autosuggest-execute
bindkey '^P' tmux_sessionizer

# --- Aliases ---
alias ls='eza --icons'
alias cat='batcat'
alias tree='eza --icons --tree'
alias nv='nvim .'
alias lg='lazygit'
alias sm='git submodule update --init --recursive'
alias smf='git submodule update --init --recursive --force'
alias ssh-init='eval "$(ssh-agent -s)" && for key in ~/.ssh/*; do [[ -f "$key" && "$(head -c 5 "$key")" == "-----" ]] && ssh-add "$key"; done'
alias copypath='wslpath -w "$(pwd)" | clip.exe'

# --- Functions ---
typeset -A program_extensions
program_extensions=(
  keil "*.uvproj*"
  utopia "*.iox*"
  excel "*.xlsx"
)

open_with() {
  local prog="$1"
  shift
  [[ -z "$prog" ]] && { echo "Usage: open_with <program_name>"; return 1; }
  [[ -z "${program_extensions[$prog]}" ]] && { echo "No mappings for '$prog'"; return 1; }

  local find_expr=() first=1
  for pattern in ${program_extensions[$prog]}; do
    (( first )) && { find_expr+=(-iname "$pattern"); first=0; } || find_expr+=(-o -iname "$pattern")
  done
  find . -maxdepth 5 \( "${find_expr[@]}" \) -print | sort -n | fzf --preview 'batcat --style=numbers --color=always {}' --height 70% --tmux 70% | xargs -r cmd.exe /C start
}
alias ow='open_with'

cf() {
  local file
  file=$(find . -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.c" -o -name "*.h" \) | fzf)
  [[ -n "$file" ]] && { echo "Formatting $file..."; clang-format -i "$file"; echo "Done."; } || echo "No file selected."
}

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

# --- Prompt ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Lazy-load NVM (saves ~300ms on shell startup) ---
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm node npm npx 2>/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node "$@"; }
npm()  { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npm "$@"; }
npx()  { unfunction nvm node npm npx 2>/dev/null; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; npx "$@"; }

