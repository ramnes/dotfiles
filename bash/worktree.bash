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

# Prompt, untrust, then force-remove a worktree. Refuses the main worktree.
# Second arg, when set, pauses on the refusal so fzf's reload doesn't wipe the message.
_wt_remove() {
    local wt="$1" pause="$2" a
    if [[ "$wt" == "$(git worktree list | head -1 | awk '{print $1}')" ]]
    then
        echo "Cannot remove main worktree" >&2
        [[ -n "$pause" ]] && sleep 2
        return 1
    fi
    read -n1 -p "Remove $wt? [y/N] " a; echo
    [[ "$a" != "y" ]] && return 1
    _wt_drop_trust "$wt"
    git worktree remove --force "$wt"
}
export -f _wt_list_trusted _wt_drop_trust _wt_remove

# Fuzzy match a worktree by basename or branch name, print best-match path.
_wt_fuzzy() {
    local list="" path _ branch
    while read -r path _ branch; do
        branch="${branch#[}"; branch="${branch%]}"
        list+="${path##*/} $branch $path"$'\n'
    done < <(git worktree list)
    printf '%s' "$list" | fzf --filter "$1" --delimiter ' ' --nth 1,2 | head -1 | awk '{print $NF}'
}

wt() {
    git rev-parse --is-inside-work-tree > /dev/null || return
    local main wt
    main=$(git worktree list | head -1 | awk '{print $1}')

    if [[ "$1" == "-D" ]]
    then
        [[ -z "$2" ]] && { echo "Usage: wt -D <name>" >&2; return 1; }
        wt=$(_wt_fuzzy "$2")
        [[ -z "$wt" ]] && { echo "No worktree: $2" >&2; return 1; }
        _wt_remove "$wt" || return
        [[ -d "$(pwd)" ]] || cd "$main"
        return
    elif [[ "$1" == "-" ]]
    then
        wt="${_WT_PREV[$main]}"
        [[ -z "$wt" ]] && { echo "No previous worktree" >&2; return 1; }
    elif [[ "$1" == "main" ]]
    then
        wt="$main"
    elif [[ -n "$1" ]]
    then
        wt=$(_wt_fuzzy "$1")
        [[ -z "$wt" ]] && { echo "No worktree: $1" >&2; return 1; }
    else
        wt=$(git worktree list | fzf --height 40% --reverse \
            --header 'enter: cd  ctrl-d: remove' \
            --bind 'ctrl-d:execute(_wt_remove {1} 1)+reload(git worktree list)' \
            | awk '{print $1}')
    fi

    [[ -z "$wt" ]] && return
    _WT_PREV[$main]=$(pwd)
    cd "$wt" || return
    [[ "$wt" != "$main" ]] && _wt_copy_trust "$main" "$wt"
    return 0
}
