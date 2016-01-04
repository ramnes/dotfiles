function clean {
    echo $@ | xargs -p rm -rf
}

function install {
    origin=$(pwd)/$1
    destination=$2

    test $origin == $destination && return
    test -e $destination || test -L $destination && clean $destination
    test -e $destination || ln -vs $origin $destination
}

cd $(dirname $0)
install bash/init.bash ~/.bashrc
install emacs ~/.emacs.d
install htop ~/.config/htop
install misc/colordiffrc ~/.colordiffrc
install misc/xprofile ~/.xprofile
install qtile ~/.config/qtile
install terminator ~/.config/terminator
