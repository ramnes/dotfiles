cd $(dirname "$0")/..

function title() {
    echo
    echo "$(context-color 2> /dev/null) * $(tput bold; tput setaf 7)$1$(tput sgr0)"
}

title "Installing dotfiles"
./bin/install.bash && source ~/.bashrc 2> /dev/null

title "Bootstrapping SSH"
mkdir -p ~/.ssh/connections
chmod 700 ~/.ssh
cp -i ssh ~/.ssh/config

title "Bootstrapping GPG"
mkdir ~/.gnupg
chmod 700 ~/.gnupg

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
pip3 install --user -I ipython
pip3 install --user -I flake8
pip3 install --user -I black black-macchiato
pip3 install --user -I ipdb
go get github.com/nsf/gocode
go get golang.org/x/tools/cmd/goimports
emacs-re
emacs --load ~/.emacs.d/init.el --batch -f "jedi:install-server"
