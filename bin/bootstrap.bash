cd $(dirname "$0")/..
cp -i git/config ~/.gitconfig
mkdir -p ~/.ssh/connections
chmod 700 ~/.ssh
cp -i ssh ~/.ssh/config

if ! bash bin/install.bash
then
    bash_path=$(which bash)
    grep -q "${bash_path}" /etc/shells || sudo sh -c "echo ${bash_path} >> /etc/shells"
    finger $(whoami) | grep -q "${bash_path}" || chsh -s "${bash_path}"
fi

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
