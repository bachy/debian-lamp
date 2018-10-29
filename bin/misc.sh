#!/bin/sh

echo -e '\033[35m
    __  ____
   /  |/  (_)_________
  / /|_/ / / ___/ ___/
 / /  / / (__  ) /__
/_/  /_/_/____/\___/

\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

sleep 2
apt-get --yes --force-yes install vim curl
sed -i "s/^# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
locale-gen
apt-get --yes --force-yes install ntp
dpkg-reconfigure tzdata
apt-get --yes --force-yes install tmux etckeeper needrestart htop

# TODO cron
# https://askubuntu.com/questions/56683/where-is-the-cron-crontab-log/121560#121560



echo -e "\033[92;1mMisc done \033[Om"
