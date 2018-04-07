#!/bin/sh

# TODO check if root

echo '\033[35m
    ______      _ _____   __
   / ____/___ _(_) /__ \ / /_  ____ _____
  / /_  / __ `/ / /__/ // __ \/ __ `/ __ \
 / __/ / /_/ / / // __// /_/ / /_/ / / / /
/_/    \__,_/_/_//____/_.___/\__,_/_/ /_/
\033[0m'
echo "\033[35;1mInstalling fall2ban \033[0m"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sleep 2
apt-get --yes --force-yes install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# ToDo ask for email and configure jail.local with it
systemctl enable fail2ban
systemctl restart fail2ban
echo "\033[92;1mfail2ban installed and configured\033[Om"
