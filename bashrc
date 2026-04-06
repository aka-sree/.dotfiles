# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# ---------------------------------------------------------------------------
# Shell options
# ---------------------------------------------------------------------------
shopt -s histappend checkwinsize globstar
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth

# ---------------------------------------------------------------------------
# Prompt (git branch aware)
# ---------------------------------------------------------------------------
__git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [[ -n "$branch" ]] && printf " (%s)" "$branch"
}
PS1='\[\e[1;34m\]\w\[\e[0;33m\]$(__git_branch)\[\e[0m\] \$ '

# ---------------------------------------------------------------------------
# Key bindings
# ---------------------------------------------------------------------------
tmux_sessionizer() { ~/.config/bin/tmux-sessionizer.sh "$@"; }
if [[ $- = *i* ]]
then
    bind -x '"\C-p": tmux_sessionizer'
fi

# ---------------------------------------------------------------------------
# Bash completion
# ---------------------------------------------------------------------------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# ---------------------------------------------------------------------------
# Shared config (aliases, functions, NVM)
# ---------------------------------------------------------------------------
if [ -f "$HOME/.shell_common.sh" ]; then
    . "$HOME/.shell_common.sh"
fi

# ---------------------------------------------------------------------------
# User specific aliases and functions (drop-in dir)
# ---------------------------------------------------------------------------
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
