#!/bin/sh
# bachir soussi chiadmi


# TODO check if root

echo -e '\033[35m
   __  _______ __________
  / / / / ___// ____/ __ \
 / / / /\__ \/ __/ / /_/ /
/ /_/ /___/ / /___/ _, _/
\____//____/_____/_/ |_|
\033[0m'
echo -e "\033[35;1mCreate new user (you will be asked a user name and a password) \033[0m"
sleep 3
while [ "$user" = "" ]
do
read -p "Enter user name: " user
if [ "$user" != "" ]; then
  read -p "is user $user correcte [y|n] " validated
  if [ "$validated" = "y" ]; then
    break
  else
    user=""
  fi
fi
done
adduser "$user"


mkdir /home/$user/logs
mkdir /home/$user/public_html
mkdir /home/$user/backups

chmod -w /home/"$user"

echo -e '\033[35m
        __               __
 _   __/ /_  ____  _____/ /_
| | / / __ \/ __ \/ ___/ __/
| |/ / / / / /_/ (__  ) /_
|___/_/ /_/\____/____/\__/
\033[0m'
echo -e "\033[35;1mVHOST install \033[0m"

while [ "$_host_name" = "" ]
do
read -p "enter a hostname ? " _host_name
if [ "$_host_name" != "" ]; then
  read -p "is hostname $_host_name correcte [y|n] " validated
  if [ "$validated" = "y" ]; then
    break
  else
    _host_name=""
  fi
fi
done

#set proper right to user will handle the app
chown -R "$user":admin  /home/"$user"/public_html
chown -R "$user":admin  /home/"$user"/logs
chown -R "$user":admin  /home/"$user"/backups

chmod -R g+wr /home/"$user"/public_html
chmod -R g+wr /home/"$user"/logs

mkdir -p /var/www/"$_host_name"
ln -s /home/"$user"/public_html /var/www/"$_host_name"/public_html
ln -s /home/"$user"/logs /var/www/"$_host_name"/logs

# TODO create nginx vhost
# cp "$_cwd"/assets/example.org.conf /etc/apache2/sites-available/"$_host_name".conf
# sed -i -r "s/example\.org/$_host_name/g" /etc/apache2/sites-available/"$_host_name".conf
#activate the vhost
# a2ensite "$_host_name".conf
#restart apache
# service apache2 restart
echo -e "\033[92;1mvhost $_host_name configured\033[Om"


# todo add mysql user and database

echo -e '\033[35m
    __  ___                 __
   /  |/  /_  ___________ _/ /
  / /|_/ / / / / ___/ __ `/ /
 / /  / / /_/ (__  ) /_/ / /
/_/  /_/\__, /____/\__, /_/
       /____/        /_/
\033[0m'
echo -e "\033[35;1mMysql database \033[0m"

while [ "$_dbname" = "" ]
do
read -p "enter a database name ? " _dbname
if [ "$_dbname" != "" ]; then
  read -p "is database name $_dbname correcte [y|n] " validated
  if [ "$validated" = "y" ]; then
    break
  else
    _dbname=""
  fi
fi
done

passok=0
while [ "$passok" = "0" ]
do
  echo -n "Write database password for $user"
  read passwda
  echo -n "confirm password"
  read passwdb
  if [ "$passwda" = "$passwdb" ]; then
    $_pswd=$passwda
    passok=1
  else
    echo "pass words don't match, please try again"
  fi
done

if [ "$passok" = 1 ]; then
  # mysql> create user '$_dbname'@'localhost' identified by '$_pswd';
  # mysql> create database $_dbname;
  # mysql> grant all privileges on esadhar_eval.* to 'esadhar_eval'@'localhost';
  # mysql> flush privileges;
fi
