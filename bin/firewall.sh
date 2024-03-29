#!/bin/sh

# TODO check if root

echo -e '\033[35m
    ______________  _______       _____    __    __
   / ____/  _/ __ \/ ____/ |     / /   |  / /   / /
  / /_   / // /_/ / __/  | | /| / / /| | / /   / /
 / __/ _/ // _, _/ /___  | |/ |/ / ___ |/ /___/ /___
/_/   /___/_/ |_/_____/  |__/|__/_/  |_/_____/_____/
\033[0m'
echo -e "\033[35;1mInstalling ufw and setup firewall (allowing only ssh and http) \033[0m"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

sleep 2
apt-get --yes install ufw
ufw allow ssh
ufw allow http
ufw allow https

# TODO ask for allowing ssh for some ip

ufw enable
ufw status verbose
echo -e "\033[92;1mufw installed and firwall configured\033[Om"
