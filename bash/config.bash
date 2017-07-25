stty ixany
stty ixoff -ixon

user="\[\e[37;1m\]\u"
at="\[\e[38;5;153m\]@"
host="\[\e[37;1m\]\h"
bg="\[\e[38;5;117m\]:\j"
path="\[\e[38;5;153m\]\w"
git="\[\e[38;5;242m\]\$(__git_ps1 '⎇%s ')"

test -f ~/.git-prompt.sh && source ~/.git-prompt.sh || git=""

export EDITOR=emacs
export GIT_EDITOR=emacs
export HISTCONTROL=ignoredups:ignorespace
export HISTFILESIZE=1000000
export HISTSIZE=1000000
export PATH="~/.local/bin:/usr/local/heroku/bin:$PATH"
export PS1="$user$at$host $bg $path $git\[\e[0m\]"
export PYTHONDONTWRITEBYTECODE=1
export TERM="xterm-256color"

shopt -s histappend
shopt -s checkwinsize

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

function cd {
    builtin cd "$@" && ls
}

test -f ~/.bash_aliases && source ~/.bash_aliases
