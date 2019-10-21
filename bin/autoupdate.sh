#!/bin/sh

echo -e '\033[35m
    ___         __           __  __          __      __
   /   | __  __/ /_____     / / / /___  ____/ /___ _/ /____
  / /| |/ / / / __/ __ \   / / / / __ \/ __  / __ `/ __/ _ \
 / ___ / /_/ / /_/ /_/ /  / /_/ / /_/ / /_/ / /_/ / /_/  __/
/_/  |_\__,_/\__/\____/   \____/ .___/\__,_/\__,_/\__/\___/
                              /_/
\033[0m'
# https://www.howtoforge.com/how-to-configure-automatic-updates-on-debian-wheezy
# https://www.bisolweb.com/tutoriels/serveur-vps-ovh-partie-5-installation-apticron/

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "\033[35;1mInstalling apticron \033[0m"
apt-get --yesinstall apticron

sleep 3
echo -n "Enter an email: "
read email

sed -i -r "s/EMAIL=\"root\"/EMAIL=\"$email\"/g" /etc/apticron/apticron.conf
# sed -i -r "s/# DIFF_ONLY=\"1\"/DIFF_ONLY=\"1\"/g" /etc/apticron/apticron.conf
sed -i -r "s/# NOTIFY_NEW=\"0\"/NOTIFY_NEW=\"0\"/g" /etc/apticron/apticron.conf

echo "\033[92;1mApticron installed and configured\033[0m"
