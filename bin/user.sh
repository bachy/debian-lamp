#!/bin/sh

echo -e '\033[35m
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

echo -n "Enter user name: "
read user
while [ "$user" = "" ]
do
  read -p "enter a user name ? " user
  if [ "$user" != "" ]; then
    # check if user already exists
    if id "$user" >/dev/null 2>&1; then
      echo "user $user alreday exists, you must provide a non existing user name."
      user=""
    else
      read -p "is user name $user correcte [y|n] " validated
      if [ "$validated" = "y" ]; then
        break
      else
        user=""
      fi
    fi
  fi
done

# TODO
# ./install.sh: 42: bin/user.sh: adduser: not found
# adding dev to admin group and limiting su to the admin group
# ./install.sh: 44: bin/user.sh: groupadd: not found
# ./install.sh: 45: bin/user.sh: usermod: not found
# dpkg-statoverride: error: group 'admin' does not exist

adduser "$user"
echo "adding $user to admin group and limiting su to the admin group"
groupadd admin
usermod -a -G admin "$user"
# allow admin group to su
dpkg-statoverride --update --add root admin 4750 /bin/su
echo "\033[92;1muser $user configured\033[Om"
