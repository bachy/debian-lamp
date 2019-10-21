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
# TODO --force-yes is deprecated, use one of the options starting with --allow instead.
apt-get --yes install vim curl
sed -i "s/^# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
locale-gen
apt-get --yes install ntp
dpkg-reconfigure tzdata
apt-get --yes install tmux etckeeper needrestart htop lynx unzip

# TODO cron
# https://askubuntu.com/questions/56683/where-is-the-cron-crontab-log/121560#121560



echo -e "\033[92;1mMisc done \033[Om"
