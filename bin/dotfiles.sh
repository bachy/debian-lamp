#!/bin/sh

echo '\033[35m
    ____        __     _______ __
   / __ \____  / /_   / ____(_) /__  _____
  / / / / __ \/ __/  / /_  / / / _ \/ ___/
 / /_/ / /_/ / /_   / __/ / / /  __(__  )
/_____/\____/\__/  /_/   /_/_/\___/____/
\033[0m'
#installing better prompt and some goodies
echo "\033[35;1mInstalling shell prompt for current user $USER \033[0m"
sleep 2
# get the current position
_cwd="$(pwd)"
# go to user home
cd
echo "cloning https://figureslibres.io/gogs/bachir/dotfiles-server.git"
git clone https://figureslibres.io/gogs/bachir/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh && cd ~
source ~/.bashrc
# return to working directory
cd "$_cwd"
echo "\033[92;1mDot files installed for $USER\033[0m"
