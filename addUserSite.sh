#!/bin/sh
# bachir soussi chiadmi



echo '\033[35m
   __  _______ __________
  / / / / ___// ____/ __ \
 / / / /\__ \/ __/ / /_/ /
/ /_/ /___/ / /___/ _, _/
\____//____/_____/_/ |_|
\033[0m'
echo "\033[35;1mCreate new user (you will be asked a user name and a password) \033[0m"
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

echo '\033[35m
        __               __
 _   __/ /_  ____  _____/ /_
| | / / __ \/ __ \/ ___/ __/
| |/ / / / / /_/ (__  ) /_
|___/_/ /_/\____/____/\__/
\033[0m'
echo "\033[35;1mVHOST install \033[0m"

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

cp "$_cwd"/assets/example.org.conf /etc/apache2/sites-available/"$_host_name".conf
sed -ir "s/example\.org/$_host_name/g" /etc/apache2/sites-available/"$_host_name".conf

#set proper right to user will handle the app
chown -R "$user":admin  /home/"$user"/public_html
chown -R "$user":admin  /home/"$user"/logs
chown -R "$user":admin  /home/"$user"/backups

chmod -R g+wr /home/"$user"/public_html
chmod -R g+wr /home/"$user"/logs

mkdir -p /var/www/"$_host_name"
ln -s /home/"$user"/public_html /var/www/"$_host_name"/public_html
ln -s /home/"$user"/logs /var/www/"$_host_name"/logs

#activate the vhost
a2ensite "$_host_name".conf

#restart apache
service apache2 restart
echo "\033[92;1mvhost $_host_name configured\033[Om"
