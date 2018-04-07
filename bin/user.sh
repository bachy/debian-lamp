#!/bin/sh

echo '\033[35m
   __  _______ __________
  / / / / ___// ____/ __ \
 / / / /\__ \/ __/ / /_/ /
/ /_/ /___/ / /___/ _, _/
\____//____/_____/_/ |_|
\033[0m'
echo "\033[35;1mCreate new user (you will be asked a user name and a password) \033[0m"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

sleep 3

# TODO check if root

echo -n "Enter user name: "
read user
# read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
adduser "$user"
echo "adding $user to admin group and limiting su to the admin group"
groupadd admin
usermod -a -G admin "$user"
# allow admin group to su
dpkg-statoverride --update --add root admin 4750 /bin/su
echo "\033[92;1muser $user configured\033[Om"
