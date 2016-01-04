function clean {
    echo $@ | xargs -p rm -rf
}

function install {
    origin=$(pwd)/$1
    destination=$2

    test $origin == $destination && return
    test -e $(dirname $destination) || mkdir -vp $(dirname $destination)
    test -e $destination || test -L $destination && clean $destination
    test -e $destination || ln -vs $origin $destination
}

cd $(dirname $0)
install emacs ~/.emacs.d
install htop ~/.config/htop
install misc/bashrc ~/.bashrc
install misc/colordiffrc ~/.colordiffrc
install misc/git-prompt.sh ~/.git-prompt.sh
install misc/xprofile ~/.xprofile
install qtile ~/.config/qtile
install terminator ~/.config/terminator
