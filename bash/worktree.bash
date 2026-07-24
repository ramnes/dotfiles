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

# Colored dot: red if dirty, orange if unpushed, green if clean and pushed.
_wt_status() {
    local wt="$1" out ab
    out=$(git -C "$wt" status --branch --porcelain=v2 --untracked-files=no 2>/dev/null)
    if grep -q '^[^#]' <<< "$out"
    then
        printf '\033[31m●\033[0m'
        return
    fi
    ab=$(awk '/^# branch\.ab / {print $3; exit}' <<< "$out")
    if [[ "$ab" == "+0" ]]
    then
        printf '\033[32m●\033[0m'
    elif [[ -n "$ab" ]]
    then
        printf '\033[33m●\033[0m'
    elif git -C "$wt" branch -r --contains HEAD 2>/dev/null | grep -q .
    then
        printf '\033[32m●\033[0m'
    else
        printf '\033[33m●\033[0m'
    fi
}

# git worktree list, each row prefixed with a colored status dot. Runs the
# per-worktree status checks in parallel, then reassembles in order.
_wt_colored_list() {
    local p rest i=0 tmpdir
    tmpdir=$(mktemp -d)
    while read -r p rest; do
        (
            s=$(_wt_status "$p")
            printf '%s %s %s\n' "$s" "$p" "$rest" > "$tmpdir/$i"
        ) &
        ((i++))
    done < <(git worktree list)
    wait
    for ((j=0; j<i; j++)); do
        cat "$tmpdir/$j" 2>/dev/null
    done
    rm -rf "$tmpdir"
}
export -f _wt_status _wt_colored_list

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
    local main wt subpath
    main=$(git worktree list | head -1 | awk '{print $1}')
    subpath="${PWD#$(git rev-parse --show-toplevel)}"

    if [[ "$1" == "-D" ]]
    then
        [[ -z "$2" ]] && { echo "Usage: wt -D <name>" >&2; return 1; }
        wt=$(_wt_fuzzy "$2")
        [[ -z "$wt" ]] && { echo "No worktree: $2" >&2; return 1; }
        _wt_remove "$wt" || return
        wt=""
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
        wt=$(_wt_colored_list | fzf --ansi --height 40% --reverse \
            --header 'enter: cd  ctrl-d: remove' \
            --bind 'ctrl-d:execute(_wt_remove {2})+reload(_wt_colored_list)' \
            | awk '{print $2}')
    fi

    if [[ ! -d "$(pwd)" ]]
    then
        local fallback="${_WT_PREV[$main]}"
        [[ -n "$fallback" && -d "$fallback" ]] && cd "$fallback" || cd "$main"
    fi

    [[ -z "$wt" ]] && return 0
    _WT_PREV[$main]=$(pwd)
    # Preserve current subpath when jumping to another worktree root.
    local target="$wt" p
    if [[ -n "$subpath" ]]
    then
        while read -r p _; do
            [[ "$wt" == "$p" && -d "$wt$subpath" ]] && { target="$wt$subpath"; break; }
        done < <(git worktree list)
    fi
    cd "$target" || return
    [[ "$wt" != "$main" ]] && _wt_copy_trust "$main" "$wt"
    return 0
}
