function clean {
    echo $@ | xargs -p rm -rf
}

function install {
    origin=$(pwd)/$1
    destination=$2

    test $origin == $destination && return
    test -L $destination && test $origin == $(realpath $destination) && return
    test -e $(dirname $destination) || mkdir -vp $(dirname $destination)
    test -e $destination || test -L $destination && clean $destination
    test -e $destination || ln -vs $origin $destination
}

cd $(dirname $0)/..
install bash/config.bash ~/.bashrc
install bash/profile.bash ~/.bash_profile
install colordiff ~/.colordiffrc
install emacs ~/.emacs.d
install git/diff-highlight ~/.local/bin/diff-highlight
install git/ignore ~/.gitignore
install htop ~/.config/htop/htoprc
install ipython ~/.ipython/profile_default/ipython_config.py
install misc/background.jpg ~/.background.jpg
install misc/context-color/context-color ~/.local/bin/context-color
install misc/git-prompt.sh ~/.git-prompt.sh
install misc/mouserate.py ~/.local/bin/mouserate
install misc/spotify-dbus.bash ~/.local/bin/spotify-dbus
install misc/tm ~/.local/bin/tm
install misc/user-dirs.dirs ~/.config/user-dirs.dirs
install misc/z.sh ~/.z.sh
install qtile ~/.config/qtile
install readline ~/.inputrc
install roxterm ~/.config/roxterm.sourceforge.net
install terminator ~/.config/terminator/config
install urxvt ~/.Xresources
install uzbl ~/.config/uzbl/config
install xprofile ~/.xprofile
