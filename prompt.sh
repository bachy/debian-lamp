
# setup user environment
echo "\033[35;1mInstalling shell prompt \033[0m"
sleep 3
git clone git://github.com/bachy/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh
source ~/.bashrc
echo "done"
echo "* * *"

