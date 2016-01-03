source .config/bash/git-prompt.bash

user="\[\e[37;1m\]\u"
at="\[\e[38;5;153m\]@"
host="\[\e[37;1m\]\h"
bg="\[\e[38;5;117m\]:\j"
path="\[\e[38;5;153m\]\w"
git="\[\e[38;5;242m\]\$(__git_ps1 '⎇%s ')\[\e[0m\]"

export PS1="$user$at$host $bg $path $git"
