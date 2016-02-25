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
install bash ~/.bashrc
install colordiff ~/.colordiffrc
install emacs ~/.emacs.d
install htop ~/.config/htop/htoprc
install ipython ~/.ipython/profile_default/ipython_config.py
install misc/background.jpg ~/.background.jpg
install misc/git-prompt.sh ~/.git-prompt.sh
install misc/mouserate.py ~/.local/bin/mouserate
install misc/spotify-dbus.bash ~/.local/bin/spotify-dbus
install misc/tm ~/.local/bin/tm
install misc/user-dirs.dirs ~/.config/user-dirs.dirs
install qtile ~/.config/qtile
install roxterm ~/.config/roxterm.sourceforge.net
install terminator ~/.config/terminator/config
install urxvt ~/.Xresources
install uzbl ~/.config/uzbl/config
install xprofile ~/.xprofile
