cd $(dirname $0)/..
cp -i git/config ~/.gitconfig
mkdir -p ~/.ssh/connections
chmod 700 ~/.ssh
cp -i ssh ~/.ssh/config
bash bin/install.bash
source ~/.bashrc
