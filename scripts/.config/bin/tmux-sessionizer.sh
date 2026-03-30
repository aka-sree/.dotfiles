#!/usr/bin/env bash
set -euo pipefail

directories=(
    "$HOME/repos/"
)

create_session() {
    local dir="$1"
    local name
    name=$(basename "$dir" | tr . _)

    if tmux has-session -t="$name" 2>/dev/null; then
        return
    fi

    tmux new-session -s "$name" -n "nvim" -c "$dir" -d
    tmux send-keys  -t "$name"    "nvim ." C-m    # window 1: nvim
    tmux new-window -t "$name" -n "shell" -c "$dir"          # window 2: shell
    tmux new-window -t "$name" -n "lazygit" -c "$dir"          # window 3: lazygit
    tmux send-keys  -t "$name"    "lazygit" C-m
    tmux new-window -t "$name" -n "copilot" -c "$dir"          # window 4: copilot
    tmux send-keys  -t "$name"    "copilot" C-m
    tmux select-window -t "$name":1
}

# Collect targets: args if provided, otherwise fzf single-select
if [[ $# -ge 1 ]]; then
    targets=("$@")
else
    selected=$(
        find "${directories[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
            | fzf-tmux -p --prompt="Select repo: "
    ) || true
    [[ -z "${selected:-}" ]] && exit 0
    targets=("$selected")
fi

[[ ${#targets[@]} -eq 0 ]] && exit 0

# Create a session for each target
first_name=""
for dir in "${targets[@]}"; do
    create_session "$dir"
    [[ -z $first_name ]] && first_name=$(basename "$dir" | tr . _)
done

# Attach or switch to the first session
if [[ -n ${TMUX:-} ]]; then
    tmux switch-client -t "$first_name"
else
    tmux attach-session -t "$first_name"
fi
