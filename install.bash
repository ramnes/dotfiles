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
install misc/background.jpg ~/.background.jpg
install misc/bash ~/.bashrc
install misc/colordiff ~/.colordiffrc
install misc/git-prompt.sh ~/.git-prompt.sh
install misc/htop ~/.config/htop/htoprc
install misc/terminator ~/.config/terminator/config
install misc/xprofile ~/.xprofile
install qtile ~/.config/qtile
