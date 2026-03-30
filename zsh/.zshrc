# Enable Powerlevel10k instant prompt (must stay near top).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Disable omz auto-update check on every shell start (run `omz update` manually)
zstyle ':omz:update' mode disabled
DISABLE_AUTO_UPDATE=true

plugins=(
    git
    zsh-autosuggestions
    fast-syntax-highlighting
)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

source $ZSH/oh-my-zsh.sh

# --- Key bindings ---
function tmux_sessionizer() { ~/.config/bin/tmux-sessionizer.sh "$@"; }
zle -N tmux_sessionizer
bindkey '^[[Z' autosuggest-execute
bindkey '^P' tmux_sessionizer

# --- Shared config (aliases, functions, NVM) ---
[[ -f "$HOME/.shell_common.sh" ]] && source "$HOME/.shell_common.sh"

# --- Prompt ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

