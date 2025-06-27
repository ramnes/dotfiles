#!/bin/bash
stty ixany
stty ixoff -ixon
set -o ignoreeof

export AWS_PAGER=""
export AWS_PROFILE="$(cat ~/.aws/current-profile)"
export EDITOR="emacs -nw"
export GPG_TTY="$(tty)"
export GIT_EDITOR="emacs -nw"
export GOPATH="$HOME/.go"
export KREW_ROOT="$HOME/.krew"
export HISTCONTROL=ignoreboth:erasedups
export HISTFILESIZE=-1
export HISTSIZE=-1
export HOMEBREW_NO_AUTO_UPDATE=1
export LESS="-R -S -# 10"
export LS_COLORS="or=41;01:mi=41;01"
export NVM_DIR="$HOME/.nvm"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONBREAKPOINT="ipdb.set_trace"
export TERM="xterm-256color"
export VISUAL=emacs
export _ZO_ECHO=1

# shellcheck disable=SC2206
paths=(
    /opt/homebrew/bin
    /opt/homebrew/opt/coreutils/libexec/gnubin
    /opt/homebrew/opt/gnu-sed/libexec/gnubin
    /opt/homebrew/opt/ruby/bin
    /opt/homebrew/lib/ruby/gems/*/bin
    /opt/homebrew/Cellar/libpq/*/bin
    /usr/local/heroku/bin
    $GOPATH/bin
    $KREW_ROOT/bin
    $HOME/.cargo/bin
    $HOME/.emacs.d/bin
    $HOME/.local/bin
    $HOME/.krew/bin
    $HOME/Library/Python/*/bin
    $HOME/Library/pnpm/
)
for path in "${paths[@]}"; do
    PATH="$path:$PATH"
done

echo-and-run() {
    echo -e "$@"
    eval "$@"
}

source-if-exists() {
    if [[ -f "$1" ]]
    then
        # shellcheck source=/dev/null
        source "$1"
    fi
}

source-if-exists ~/.bash_aliases

CONTEXT_COLOR="$(context-color -p)"
FAIL_COLOR="\\[$(tput setaf 1)\\]"

set-venv() {
    if [[ -d ".venv" ]] && [ ! "$AUTO_SOURCED_VENV" ];
    then
        echo-and-run source .venv/bin/activate
        AUTO_SOURCED_VENV="$(pwd)"
        export AUTO_SOURCED_VENV
    elif [ "$AUTO_SOURCED_VENV" ] \
             && { [[ ! "$(pwd)" =~ $AUTO_SOURCED_VENV ]] \
                      || [[ ! -d "$AUTO_SOURCED_VENV/.venv" ]]; }
    then
        echo-and-run deactivate 2> /dev/null
        unset AUTO_SOURCED_VENV
    fi
}

set-nvm() {
    if [[ -f ".nvmrc" ]] && [ ! "$AUTO_USED_NVMRC" ];
    then
        fnm use
        AUTO_USED_NVMRC="$(pwd)"
        export AUTO_USED_NVMRC
    elif [ "$AUTO_USED_NVMRC" ] \
             && { [[ ! "$(pwd)" =~ $AUTO_USED_NVMRC ]] \
                      || [[ ! -f "$AUTO_USED_NVMRC/.nvmrc" ]]; }
    then
        fnm use default
        unset AUTO_USED_NVMRC
    fi
}

set-prompt() {
    # shellcheck disable=SC2181
    if [[ "$?" != 0 ]]
    then
        color="$FAIL_COLOR"
    else
        color="$CONTEXT_COLOR"
    fi

    user="\\[\\e[37;1m\\]\\u"
    at="$color@"
    host="\\[\\e[37;1m\\]\\h"
    jobs="\\[\\e[0m\\]$color:\\j"
    path="\\[\\e[37;1m\\]$color\\w"

    set-venv
    if [[ "$VIRTUAL_ENV" ]]
    then
        venv="\\[\\e[38;5;242m\\]◌$(basename "$VIRTUAL_ENV") "
    else
        venv=""
    fi

    set-nvm
    if [[ "$AUTO_USED_NVMRC" ]]
    then
        nvm="\\[\\e[38;5;242m\\]$(node --version ) "
    else
        nvm=""
    fi

    if [[ -n "$(type -t __git_ps1)" ]]
    then
        git="\\[\\e[38;5;242m\\]$(__git_ps1 '⎇ %s ')"
    else
        git=""
    fi

    PS1="$user$at$host $jobs $path $venv$nvm$git\\[\\e[0m\\]"
}

load-env() {
    set -o allexport
    source-if-exists .env
    set +o allexport
}

set-title() {
    echo -ne "\033]0;$(whoami)@$(hostname) :$(jobs | wc -l) $(dirs)\007"
}

reload-history() {
    history -a
    history -r
}

PROMPT_COMMAND="set-prompt; load-env; set-title; reload-history; stty sane"

shopt -s autocd
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s globstar
shopt -s histappend

alias activate='. .venv/bin/activate 2>/dev/null || . .env/bin/activate 2>/dev/null'
alias gr='cd $(git root)'
alias clean='rm -vf $(find . -name "*~" -or -name "*.pyc" -or -name "*.pyo" -or -name "#*#" \
             -or -name "*.class" -or -name "*_flymake.py" 2> /dev/null)'
alias compose="docker compose --ansi always"
alias dog='pygmentize -g'
alias emacs-clean='rm -vf `find ~/.emacs.d/ | grep \.elc`'
alias emacs-re="emacs-clean && emacs-compile"
alias grep='grep --color=auto -I --line-buffered'
alias k="kubectl"
alias killmosh='pgrep mosh-server | grep -v $(ps -o ppid --no-headers $$) | xargs kill &> /dev/null || true'
alias lines='cat `find . -type f` | wc -l'
alias loc='find . -not -path "*.git*" -not -path "*.venv*" -type f | xargs wc -l'
alias ls='ls --color=auto -F'
alias modprobe='modprobe --first-time'
alias mv='mv -i'
alias nautilus='nautilus --no-desktop'
alias pytest='pytest --pdbcls=IPython.terminal.debugger:TerminalPdb'
alias randpass='apg -MsNCL -m10'
alias reactivate='deactivate; activate'
alias reload='source ~/.bashrc'
alias sudo='sudo -E '
alias spacer="command spacer --after 30 -d' ' -p1"
alias tf="terraform"

awsp() {
    profile=$(aws configure list-profiles | sk --prompt "Choose active AWS profile:" -m --bind enter:deselect-all+accept --pre-select-items "$AWS_PROFILE")
    if [[ "$profile" ]]
    then
        export AWS_PROFILE="$profile"
        echo "$profile" > ~/.aws/current-profile
    fi
}

diff() {
    colordiff -Nu "$@" | diff-highlight
}

hl() {
    # shellcheck disable=SC2145
    sed "s/\($@\)/$(tput setab 1)\1$(tput sgr0)/"
}

kt() {
    command kt "$@" -z 2,8,10,16,17,18,19,20,21,22,23,24,25,26,27
}

q() {
    shell-genie ask "$*"
}

csv_pp() {
    if [[ "$2" ]]
    then
        DELIMITER="$2"
    else
        DELIMITER=","
    fi
    column -s"$DELIMITER" -t < "$1" | less -#2 -N -S
}

emacs() {
    if [[ "$*" == *"--daemon"* || "$*" == *"--help"* || "$*" == *"--version"* || "$*" == *"--batch"* ]]
    then
        command emacs -nw "$@"
    else
        emacsclient --tty -c -nw -a= --socket-name=$(whoami) "$@"
    fi
}

__start_compose() {
  COMP_WORDS=(docker compose "${COMP_WORDS[@]:1}")
  COMP_CWORD=$((COMP_CWORD + 1))
  COMP_LINE="docker compose ${COMP_LINE#compose }"
  COMP_POINT=$((COMP_POINT + 7)) # length of "docker " added

  __start_docker
}

files=(
    ~/.kctx.bash
    ~/.kns.bash
    ~/.kt.bash
    /usr/share/bash-completion/bash_completion
    /opt/homebrew/etc/profile.d/bash_completion.sh
    /opt/homebrew/share/google-cloud-sdk/path.bash.inc
)
for file in "${files[@]}"; do
    source-if-exists "$file"
done

bash-re() {
    rm -f ~/.bashrc-contrib
    commands=(
        "docker completion bash"
        "fnm env"
        "fzf --bash"
        "gh completion -s bash"
        "mcfly init bash"
        "mcfly-fzf init bash"
        "qovery completion bash"
        "pulumi gen-completion bash"
        "ngrok completion"
        "brew shellenv"
        "mise activate bash"
        "kaf completion bash"
        "zoxide init --cmd cd bash"
    )
    for command in "${commands[@]}"; do
        # shellcheck disable=SC1090
        echo-and-run "$command >> ~/.bashrc-contrib"
    done
}

if [[ ! -f ~/.bashrc-contrib ]]
then
    bash-re
fi
source ~/.bashrc-contrib

complete -F __start_kubectl k
complete -F __start_compose compose
complete -C 'terraform' terraform
complete -C 'terraform' tf
complete -C 'aws_completer' aws
complete -C 'gocomplete' go

if [[ "$OSTYPE" == "darwin"* ]]; then
    ulimit -S -n unlimited
fi

tac "$HISTFILE" | awk '!x[$0]++' > /tmp/histfile && tac /tmp/histfile > "$HISTFILE"

# keep this at the bottom, it needs to be evaluated after `complete` commands
export COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
