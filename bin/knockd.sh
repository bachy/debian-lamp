#!/bin/sh

# TODO check if root

echo '\033[35m
    __                    __       __
   / /______  ____  _____/ /______/ /
  / //_/ __ \/ __ \/ ___/ //_/ __  /
 / ,< / / / / /_/ / /__/ ,< / /_/ /
/_/|_/_/ /_/\____/\___/_/|_|\__,_/
\033[0m'
echo "\033[35;1mInstalling knockd to control ssh port opening\033[0m"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sleep 2
apt-get --yes --force-yes install knockd

mv /etc/knockd.conf /etc/knockd.conf.ori
cp "$_cwd"/assets/knockd.conf /etc/knockd.conf
echo -n "define a sequence number for opening ssh (as 7000,8000,9000) : "
read sq
sed -i "s/7000,8000,9000/$sq/g" /etc/knockd.conf
sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
/etc/init.d/knockd start
echo "\033[92;1mknockd installed and configured\033[Om"
echo "\033[92;1mplease note this sequence for future ssh knocking\033[Om"
echo "$sq1"
sleep 3
