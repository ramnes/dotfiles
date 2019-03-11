cd $(dirname $0)/..
cp -i git/config ~/.gitconfig
mkdir -p ~/.ssh/connections
chmod 700 ~/.ssh
cp -i ssh ~/.ssh/config
bash bin/install.bash

source ~/.bashrc
pip install --user -I ipython
pip install --user -I flake8
go get github.com/nsf/gocode
emacs-re
emacs --load ~/.emacs.d/init.el --batch -f "jedi:install-server"
