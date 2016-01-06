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

cd $(dirname $0)/..
install bash ~/.bashrc
install colordiff ~/.colordiffrc
install emacs ~/.emacs.d
install htop ~/.config/htop/htoprc
install misc/background.jpg ~/.background.jpg
install misc/git-prompt.sh ~/.git-prompt.sh
install qtile ~/.config/qtile
install terminator ~/.config/terminator/config
install xprofile ~/.xprofile
