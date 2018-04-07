#!/bin/sh

# TODO check if root

echo '\033[35m
    __  ____
   /  |/  (_)_________
  / /|_/ / / ___/ ___/
 / /  / / (__  ) /__
/_/  /_/_/____/\___/

\033[0m'
apt-get --yes --force-yes install vim curl
sed -i "s/^# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
locale-gen
apt-get --yes --force-yes install ntp
dpkg-reconfigure tzdata
