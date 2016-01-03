function install {
    origin=$1
    destination=$2
    test -e $destination && echo $destination | xargs -p rm -rf
    test -e $destination || ln -s $origin $destination
}

cd $(dirname $0)
install $(pwd)/bash/init.bash ~/.bashrc
