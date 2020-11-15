#!/bin/sh

echo -e '
     _ _      _   _
  __| | |__  | | | |___ ___ _ _
 / _` |  _ \ | |_| (_-</ -_)  _|
 \__,_|_.__/  \___//__/\___|_|
'

echo -e "Create new mysql db and user (you will be asked a db name and a password)"

. bin/checkroot.sh

sleep 3

# configure
echo -n "Please provide the mysql root passwd : "
read _root_mysql_passwd

mysql -u root -p$_root_mysql_passwd -e "show databases;"

echo -n "Enter new db name: "
read db_name
while [ "$db_name" = "" ]
do
  read -p "enter a db name ? " db_name
  if [ "$db_name" != "" ]; then
    # TODO check if db already exists
    # if id "$db_name" >/dev/null 2>&1; then
    #   echo "user $db_name alreday exists, you must provide a non existing user name."
    #   db=""
    # else
      read -p "is db name $db_name correcte [y|n] " validated
      if [ "$validated" = "y" ]; then
        break
      else
        db_name=""
      fi
    # fi
  fi
done

# generate random password for new mysql user
_passwd="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c16)"

# create new mysql user
mysql -u root -p$_root_mysql_passwd -e "CREATE DATABASE $db_name;"
mysql -u root -p$_root_mysql_passwd -e "CREATE USER '$db_name'@'localhost' IDENTIFIED BY '$_passwd';"
mysql -u root -p$_root_mysql_passwd -e "GRANT ALL ON $db_name.* TO '$db_name'@'localhost';"

mysql -u root -p$_root_mysql_passwd -e "show databases;"

echo "database and user : $db_name installed"
echo " please record your password $_passwd"
echo "press any key to continue."
read continu
