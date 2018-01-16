stty ixany
stty ixoff -ixon

export EDITOR=emacs
export GIT_EDITOR=emacs
export HISTCONTROL=ignoredups:ignorespace
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export PATH="~/.local/bin:/usr/local/heroku/bin:$PATH"
export PYTHONDONTWRITEBYTECODE=1
export TERM="xterm-256color"

color="$(context-color -p)"
user="\[\e[37;1m\]\u"
at="$color@"
host="\[\e[37;1m\]\h"
jobs="\[\e[0m\]$color:\j"
path="\[\e[37;1m\]$color\w"
git="\[\e[38;5;242m\]\$(__git_ps1 '⎇%s ')"

test -f ~/.git-prompt.sh && source ~/.git-prompt.sh || git=""
export PS1="$user$at$host $jobs $path $git\[\e[0m\]"

shopt -s autocd
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob
shopt -s globstar
shopt -s histappend

alias activate='. .venv/bin/activate 2>/dev/null || . .env/bin/activate 2>/dev/null'
alias clean='rm -vf `find | egrep "(*~|*\.pyc|*\.pyo|\#*\#|*\.class|*_flymake\.py)"` 2>/dev/null'
alias diff='colordiff -Nu'
alias dog='pygmentize -g'
alias emacs-clean='rm -vf `find ~/.emacs.d/ | grep \.elc`'
alias emacs-compile="~/.emacs.d/bin/compile"
alias emacs-re="emacs-clean && emacs-compile"
alias emacs='emacs -nw'
alias grep='grep --color=auto -I --line-buffered'
alias lines='cat `find . -type f` | wc -l'
alias loc='find . -not -path "*.git*" -not -path "*.venv*" -type f | xargs wc -l'
alias ls='ls --color=auto -F'
alias modprobe='modprobe --first-time'
alias nautilus='nautilus --no-desktop'
alias open='xdg-open'
alias plz='sudo $(history -p !-1)'
alias randpass='apg -MsNCL -m10'
alias reactivate='deactivate && activate'
alias reload='source ~/.bashrc'
alias sudo='sudo HOME=$HOME '

cd() {
    builtin cd "$@" && ls
}

source-if-exists() {
    test -f "$1" && source "$1"
}

source-if-exists ~/.bash_aliases
source-if-exists ~/.z.sh
