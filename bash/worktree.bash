#!/bin/bash
# Git worktree helpers, mirroring mise trust into worktrees.

# Previous worktree per repo, keyed by main worktree path.
[[ -v _WT_PREV ]] || declare -gA _WT_PREV

# Emit each mise-trusted path under a given root.
_wt_list_trusted() {
    local td="$HOME/.local/state/mise/trusted-configs" root="$1" link target
    [[ -d "$td" ]] || return
    for link in "$td"/*; do
        target=$(readlink "$link") || continue
        target="${target%/}"
        case "$target" in
            "$root"|"$root"/*) echo "$target";;
        esac
    done
}

# Mirror main-worktree trust into a destination worktree.
_wt_copy_trust() {
    local main="$1" dest="$2" target new
    local -A trusted
    while read -r target; do
        trusted[$target]=1
    done < <(_wt_list_trusted "$dest")
    while read -r target; do
        new="$dest${target#$main}"
        [[ -e "$new" && -z "${trusted[$new]:-}" ]] && mise trust "$new" > /dev/null
    done < <(_wt_list_trusted "$main")
}

# Untrust everything under a given worktree.
_wt_drop_trust() {
    local target
    while read -r target; do
        mise trust --untrust "$target" > /dev/null
    done < <(_wt_list_trusted "$1")
}
export -f _wt_list_trusted _wt_drop_trust

wt() {
    git rev-parse --is-inside-work-tree > /dev/null || return
    local main wt path
    main=$(git worktree list | head -1 | awk '{print $1}')

    if [[ "$1" == "-" ]]
    then
        wt="${_WT_PREV[$main]}"
        [[ -z "$wt" ]] && { echo "No previous worktree" >&2; return 1; }
    elif [[ "$1" == "main" ]]
    then
        wt="$main"
    elif [[ -n "$1" ]]
    then
        # Fuzzy match by worktree basename or branch name.
        local list="" branch
        while read -r path _ branch; do
            branch="${branch#[}"; branch="${branch%]}"
            list+="${path##*/} $branch $path"$'\n'
        done < <(git worktree list)
        wt=$(printf '%s' "$list" | fzf --filter "$1" --delimiter ' ' --nth 1,2 | head -1 | awk '{print $NF}')
        [[ -z "$wt" ]] && { echo "No worktree: $1" >&2; return 1; }
    else
        wt=$(git worktree list | fzf --height 40% --reverse \
            --header 'enter: cd  ctrl-d: remove' \
            --bind 'ctrl-d:execute(read -n1 -p "Remove {1}? [y/N] " a; echo; [[ "$a" == "y" ]] && _wt_drop_trust {1} && git worktree remove {1})+reload(git worktree list)' \
            | awk '{print $1}')
    fi

    [[ -z "$wt" ]] && return
    _WT_PREV[$main]=$(pwd)
    cd "$wt" || return
    [[ "$wt" != "$main" ]] && _wt_copy_trust "$main" "$wt"
    return 0
}
