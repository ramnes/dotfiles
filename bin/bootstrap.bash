cd $(dirname "$0")/..

function title() {
    echo
    echo "$(context-color 2> /dev/null) * $(tput bold; tput setaf 7)$1$(tput sgr0)"
}

title "Installing dotfiles"
./bin/install.bash && source ~/.bashrc 2> /dev/null

title "Bootstrapping Git"
cp -i git/config ~/.gitconfig

title "Bootstrapping SSH"
mkdir -p ~/.ssh/connections
chmod 700 ~/.ssh
cp -i ssh ~/.ssh/config

title "Boostrapping Nix"
if command -v nix > /dev/null
then
    echo "Skipping (already installed)"
else
    curl -L https://nixos.org/nix/install | sh
    source ~/.bashrc 2> /dev/null
    sudo nix-channel --update
fi

if [ "$(uname)" == "Darwin" ]
then
    title "Bootstrapping nix-darwin"
    if command -v darwin-rebuild > /dev/null
    then
        echo "Skipping (already installed)"
    else
        nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
        ./result/bin/darwin-installer && rm result
        source ~/.bashrc 2> /dev/null
    fi
fi

title "Bootstrapping Home Manager"
if command -v home-manager > /dev/null
then
    echo "Skipping (already installed)"
else
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install
    source ~/.bashrc 2> /dev/null
fi

bash_path=$(which bash)
title "Setting bash (${bash_path}) as the default shell"
if finger $(whoami) | grep -q "${bash_path}"
then
    echo "Skipping (already installed)"
else
    grep -q "${bash_path}" /etc/shells || sudo sh -c "echo ${bash_path} >> /etc/shells"
    chsh -s "${bash_path}"
fi

title "Bootstrapping Emacs"
shopt -s expand_aliases
source ~/.bashrc
pip install --user -I ipython
pip install --user -I flake8
pip install --user -I black black-macchiato
pip install --user -I ipdb
go get github.com/nsf/gocode
go get golang.org/x/tools/cmd/goimports
emacs-re
emacs --load ~/.emacs.d/init.el --batch -f "jedi:install-server"
