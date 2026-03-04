# 1. Powerlevel10k Instant Prompt (Must stay at the very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. THE MUZZLE (Kill terminal titles before themes load)
export DISABLE_AUTO_TITLE="true"
unset PROMPT_COMMAND
typeset -g POWERLEVEL9K_TERM_SHELL_TITLE=false

# Redefine functions to do nothing (stops "sree" snap-back)
function title() { return }
function precmd_functions() { return }

# 3. Path & Oh My Zsh Setup
export ZSH="$HOME/.oh-my-zsh"
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Select P10k as the primary theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# 4. Plugins
# Added zsh-async for your background robotics tasks
plugins=(git zsh-async zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# 5. Productivity Aliases
alias v='nvim'
alias lg='lazygit'
alias tkill='tmux kill-server'
alias clean='rm -rf build/ bin/ *.o'
alias gcp='g++ -O3 -Wall'

# Smart Build Function for HFT/Robotics
b() {
  if [ -f "CMakeLists.txt" ]; then
    mkdir -p build && cd build && cmake .. && make -j$(nproc) && cd ..
  elif [ -f "Makefile" ] || [ -f "makefile" ]; then
    make -j$(nproc)
  else
    echo "No build system (CMake/Make) detected."
  fi
}

# 6. Auto-start/Attach Tmux
if [ -z "$TMUX" ]; then
    tmux attach-session -t default || tmux new-session -s default
fi

# 7. Theme & Prompt Finalization
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 8. Async Worker Fix (Ensures prompt features don't lag)
autoload -U async && async 2>/dev/null

# Final shell cleanup to ensure Fedora doesn't force a title
case "$TERM" in
    screen*|tmux*)
        function title() { }
        ;;
esac

# Physically disable the Oh My Zsh termsupport plugin
# This prevents Zsh from sending rename sequences to Tmux
unalias -m 'omz_termsupport*' 2>/dev/null
function title { }
function omz_termsupport_cwd { }
function omz_termsupport_setup { }

