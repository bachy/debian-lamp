#!/bin/sh
# bachir soussi chiadmi
#
# http://www.debian.org/doc/manuals/securing-debian-howto/
# https://www.thefanclub.co.za/how-to/how-secure-ubuntu-1204-lts-server-part-1-basics
# https://www.linode.com/docs/websites/lamp/lamp-server-on-debian-7-wheezy/
# http://web-74.com/blog/reseaux/gerer-le-deploiement-facilement-avec-git/
#

echo '
    ____       __    _                _____
   / __ \___  / /_  (_)___ _____     / ___/___  ______   _____  _____
  / / / / _ \/ __ \/ / __ `/ __ \    \__ \/ _ \/ ___/ | / / _ \/ ___/
 / /_/ /  __/ /_/ / / /_/ / / / /   ___/ /  __/ /   | |/ /  __/ /
/_____/\___/_.___/_/\__,_/_/ /_/   /____/\___/_/    |___/\___/_/

'
echo "\033[35;1mThis script has been tested only on Linux Debian 7 \033[0m"
echo "Please run this script as root"

echo -n "Should we start? [Y|n] "
read yn
yn=${yn:-y}
if [ "$yn" != "y" ]; then
  echo "aborting script!"
  exit
fi

# get the current position
_cwd="$(pwd)"

echo '
   __  ______  __________  ___    ____  ______
  / / / / __ \/ ____/ __ \/   |  / __ \/ ____/
 / / / / /_/ / / __/ /_/ / /| | / / / / __/
/ /_/ / ____/ /_/ / _, _/ ___ |/ /_/ / /___
\____/_/    \____/_/ |_/_/  |_/_____/_____/
'
apt-get update
apt-get upgrade

echo '
    __  ____
   /  |/  (_)_________
  / /|_/ / / ___/ ___/
 / /  / / (__  ) /__
/_/  /_/_/____/\___/

'
apt-get install vim
# TODO colorize vim
cat "syntax on" >> ~/.vimrc
# TODO colorize ls
cat "$_cwd"/assets/.bashrc > ~/.bashrc


echo '
    __  _____    ____  ____  _______   __
   / / / /   |  / __ \/ __ \/ ____/ | / /
  / /_/ / /| | / /_/ / / / / __/ /  |/ /
 / __  / ___ |/ _, _/ /_/ / /___/ /|  /
/_/ /_/_/  |_/_/ |_/_____/_____/_/ |_/
'
echo "\033[35;1mInstalling harden \033[0m"
sleep 3
apt-get install harden
echo "Harden instaled"
echo "033[92;1m* * *033[Om"

echo '
    ______________  _______       _____    __    __
   / ____/  _/ __ \/ ____/ |     / /   |  / /   / /
  / /_   / // /_/ / __/  | | /| / / /| | / /   / /
 / __/ _/ // _, _/ /___  | |/ |/ / ___ |/ /___/ /___
/_/   /___/_/ |_/_____/  |__/|__/_/  |_/_____/_____/
'
echo "\033[35;1mInstalling ufw and setup firewall (allowing only ssh and http) \033[0m"
sleep 3
apt-get install ufw
ufw allow ssh
ufw allow http
ufw enable
ufw status verbose
echo "ufw installed and firwall configured"
echo "033[92;1m* * *033[Om"

echo '
    ______      _ _____   __
   / ____/___ _(_) /__ \ / /_  ____ _____
  / /_  / __ `/ / /__/ // __ \/ __ `/ __ \
 / __/ / /_/ / / // __// /_/ / /_/ / / / /
/_/    \__,_/_/_//____/_.___/\__,_/_/ /_/

'
echo "\033[35;1mInstalling fall2ban \033[0m"
apt-get install fail2ban
cat "$_cwd"/assets/fail2ban.jail.conf > /etc/fail2ban/jail.conf
echo "fail2ban installed and configured"
echo "033[92;1m* * *033[Om"

echo '
    __                    __       __
   / /______  ____  _____/ /______/ /
  / //_/ __ \/ __ \/ ___/ //_/ __  /
 / ,< / / / / /_/ / /__/ ,< / /_/ /
/_/|_/_/ /_/\____/\___/_/|_|\__,_/

'
echo "\033[35;1mInstalling knockd \033[0m"
echo "031[92;1m!! Experimental !!033[Om"
sleep 3
apt-get install knockd
echo -n "define a sequence number for opening (as 7000,8000,9000) : "
read sq1
echo -n "define a sequence number for closing (as 9000,8000,7000) : "
read sq2
sed -i "s/7000,8000,9000/$sq1/g" /etc/knockd.conf
sed -i "s/9000,8000,7000/$sq2/g" /etc/knockd.conf
sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
echo "knockd installed and configured"
echo "please note these sequences then hit enter to continue"
echo -n "opening : $sq1 ; closing : $sq2"
echo "031[92;1m!! PLEASE CHECK THESE VALUES on /etc/knockd.conf !!033[Om"
echo "033[92;1m* * *033[Om"

echo '
   __  _______ __________
  / / / / ___// ____/ __ \
 / / / /\__ \/ __/ / /_/ /
/ /_/ /___/ / /___/ _, _/
\____//____/_____/_/ |_|
'
echo "\033[35;1mCreate new user (you will be asked a user name and a password) \033[0m"
sleep 3
echo -n "Enter user name: "
read user
# read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
adduser "$user"
echo "adding $user to admin group and limiting su to the admin group"
groupadd admin
usermod -a -G admin "$user"
dpkg-statoverride --update --add root admin 4750 /bin/su
echo "user $user configured"
echo "033[92;1m* * *033[Om"

echo '
   __________ __  __
  / ___/ ___// / / /
  \__ \\__ \/ /_/ /
 ___/ /__/ / __  /
/____/____/_/ /_/
'
while [ "$securssh" != "y" ] && [ "$securssh" != "n" ]
do
echo -n "Securing ssh (disabling root login)? [y|n] "
read securssh
# securssh=${securssh:-y}
done

if [ "$securssh" = "y" ]; then
  sed -i 's/PermitRootLogin\ yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/PermitEmptyPasswords\ yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  sed -i 's/Protocol\ [0-9]/Protocol 2/g' /etc/ssh/sshd_config
  service ssh reload
  echo "SSH secured"
else
  echo 'root user can still conect through ssh'
fi
echo "033[92;1m* * *033[Om"

# TODO : allow ssh/ftp connection only from given ips


echo "\033[35;1mInstalling AMP web server \033[0m"

echo '
    ___                     __        ___
   /   |  ____  ____ ______/ /_  ___ |__ \
  / /| | / __ \/ __ `/ ___/ __ \/ _ \__/ /
 / ___ |/ /_/ / /_/ / /__/ / / /  __/ __/
/_/  |_/ .___/\__,_/\___/_/ /_/\___/____/
      /_/
'
echo "\033[35;1mInstalling Apache2 \033[0m"
sleep 3
apt-get install apache2
a2enmod rewrite
cat "$_cwd"/assets/apache2.conf > /etc/apache2/apache2.conf
# Change logrotate for Apache2 log files to keep 10 days worth of logs
sed -i 's/\tweekly/\tdaily/' /etc/logrotate.d/apache2
sed -i 's/\trotate .*/\trotate 10/' /etc/logrotate.d/apache2
# Remove Apache server information from headers.
sed -i 's/ServerTokens .*/ServerTokens Prod/' /etc/apache2/conf.d/security
sed -i 's/ServerSignature .*/ServerSignature Off/' /etc/apache2/conf.d/security
service apache2 restart
echo "Apache2 installed"
echo "033[92;1m* * *033[Om"

echo '
    __  ___                 __
   /  |/  /_  ___________ _/ /
  / /|_/ / / / / ___/ __ `/ /
 / /  / / /_/ (__  ) /_/ / /
/_/  /_/\__, /____/\__, /_/
       /____/        /_/
'
echo "\033[35;1minstalling Mysql \033[0m"
sleep 3
apt-get install mysql-server
mysql_secure_installation
echo "mysql installed"
echo "033[92;1m* * *033[Om"

echo '
    ____  __  ______
   / __ \/ / / / __ \
  / /_/ / /_/ / /_/ /
 / ____/ __  / ____/
/_/   /_/ /_/_/
'
echo "\033[35;1mInstalling PHP \033[0m"
sleep 3
apt-get install php5 php-pear php5-gd
echo "Configuring PHP"
cp /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.back
sed -i "s/max_execution_time\ =\ [0-9]\+/max_execution_time = 60/g" /etc/php5/apache2/php.ini
sed -i "s/max_input_time\ =\ [0-9]\+/max_input_time = 60/g" /etc/php5/apache2/php.ini
sed -i "s/memory_limit\ =\ [0-9]\+M/memory_limit = 512M/g" /etc/php5/apache2/php.ini
sed -i "s/;\?error_reporting\ =\ [^\n]\+/error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR/g" /etc/php5/apache2/php.ini
sed -i "s/;\?display_errors\ =\ On/display_errors = Off/g" /etc/php5/apache2/php.ini
sed -i "s/;\?log_errors\ =\ Off/log_errors = On/g" /etc/php5/apache2/php.ini
# following command doesn't work, make teh change manualy
#sed -ri ":a;$!{N;ba};s/;\?\ \?error_log\ =\ [^\n]\+([^\n]*\n(\n|$))/error_log = \/var\/log\/php\/error.log\1/g" /etc/php5/apache2/php.ini
echo "register_globals = Off" >> /etc/php5/apache2/php.ini

mkdir /var/log/php
chown www-data /var/log/php

apt-get install php5-mysql
echo "php installed"
echo "033[92;1m* * *033[Om"

echo '
           __          __  ___      ___       __          _
    ____  / /_  ____  /  |/  /_  __/   | ____/ /___ ___  (_)___
   / __ \/ __ \/ __ \/ /|_/ / / / / /| |/ __  / __ `__ \/ / __ \
  / /_/ / / / / /_/ / /  / / /_/ / ___ / /_/ / / / / / / / / / /
 / .___/_/ /_/ .___/_/  /_/\__, /_/  |_\__,_/_/ /_/ /_/_/_/ /_/
/_/         /_/           /____/
'
echo "\033[35;1mInstalling phpMyAdmin \033[0m"
apt-get install phpmyadmin
echo "phpMyAdmin installed"
echo "033[92;1m* * *033[Om"

echo '
        __               __
 _   __/ /_  ____  _____/ /_
| | / / __ \/ __ \/ ___/ __/
| |/ / / / / /_/ (__  ) /_
|___/_/ /_/\____/____/\__/
'
echo "\033[35;1mVHOST install \033[0m"
while [ "$vh" != "y" ] && [ "$vh" != "n" ]
do
echo -n "Should we install a vhost? [y|n] "
read vh
# vh=${vh:-y}
done
if [ "$vh" = "y" ]; then

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

  mkdir -p /srv/www/"$_host_name"/public_html
  mkdir /srv/www/"$_host_name"/logs
  #set proper right to user will handle the app
  chown -R root:admin  /srv/www/"$_host_name"/
  chmod -R g+w /srv/www/"$_host_name"/
  chmod -R g+r /srv/www/"$_host_name"/

  # create a shortcut to the site
  mkdir /home/"$user"/www/
  chown "$user":admin /home/"$user"/www/
  ln -s /srv/www/"$_host_name" /home/"$user"/www/"$_host_name"

  #activate the vhost
  a2ensite "$_host_name".conf

  #restart apache
  service apache2 restart
  echo "vhost $_host_name configured"
else
  echo "Vhost installation aborted"
fi
echo "033[92;1m* * *033[Om"

echo '
    ___                __        __
   /   |_      _______/ /_____ _/ /_
  / /| | | /| / / ___/ __/ __ `/ __/
 / ___ | |/ |/ (__  ) /_/ /_/ / /_
/_/  |_|__/|__/____/\__/\__,_/\__/
'
echo "\033[35;1mInstalling Awstat \033[0m"
sleep 3
apt-get install awstats
# Configure AWStats
temp=`grep -i sitedomain /etc/awstats/awstats.conf.local | wc -l`
if [ $temp -lt 1 ]; then
    echo SiteDomain="$_host_name" >> /etc/awstats/awstats.conf.local
fi
# Disable Awstats from executing every 10 minutes. Put a hash in front of any line.
sed -i 's/^[^#]/#&/' /etc/cron.d/awstats
echo "Awstat installed"
echo "033[92;1m* * *033[Om"


# echo '
#   ______________  _______
#  /_  __/ ____/  |/  / __ \
#   / / / __/ / /|_/ / /_/ /
#  / / / /___/ /  / / ____/
# /_/ /_____/_/  /_/_/
# '
# function check_tmp_secured {

#   temp1=`grep -w "/var/tempFS /tmp ext3 loop,nosuid,noexec,rw 0 0" /etc/fstab | wc -l`
#   temp2=`grep -w "tmpfs /tmp tmpfs rw,noexec,nosuid 0 0" /etc/fstab | wc -l`

#   if [ $temp1  -gt 0 ] || [ $temp2 -gt 0 ]; then
#       return 1
#   else
#       return 0
#   fi
# } # End function check_tmp_secured

# function secure_tmp_tmpfs {

#   cp /etc/fstab /etc/fstab.bak
#   # Backup /tmp
#   cp -Rpf /tmp /tmpbackup

#   rm -rf /tmp
#   mkdir /tmp

#   mount -t tmpfs -o rw,noexec,nosuid tmpfs /tmp
#   chmod 1777 /tmp
#   echo "tmpfs /tmp tmpfs rw,noexec,nosuid 0 0" >> /etc/fstab

#   # Restore /tmp
#   cp -Rpf /tmpbackup/* /tmp/ >/dev/null 2>&1

#   #Remove old tmp dir
#   rm -rf /tmpbackup

#   # Backup /var/tmp and link it to /tmp
#   mv /var/tmp /var/tmpbackup
#   ln -s /tmp /var/tmp

#   # Copy the old data back
#   cp -Rpf /var/tmpold/* /tmp/ >/dev/null 2>&1
#   # Remove old tmp dir
#   rm -rf /var/tmpbackup

#   echo -e "\033[35;1m /tmp and /var/tmp secured using tmpfs. \033[0m"
# } # End function secure_tmp_tmpfs

# check_tmp_secured
# if [ $? = 0  ]; then
#     secure_tmp_tmpfs
# else
#     echo -e "\033[35;1mFunction canceled. /tmp already secured. \033[0m"
# fi

echo '
    ____                             __
   / __ \_________  ____ ___  ____  / /_
  / /_/ / ___/ __ \/ __ `__ \/ __ \/ __/
 / ____/ /  / /_/ / / / / / / /_/ / /_
/_/   /_/   \____/_/ /_/ /_/ .___/\__/
                          /_/
'
#installing better prompt and some goodies for root
echo "\033[35;1mInstalling shell prompt for root \033[0m"
sleep 3
git clone git://github.com/bachy/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh && cd ~
source ~/.bashrc
echo "done"
echo "033[92;1m* * *033[Om"

echo '
                  __
  ___  ____  ____/ /
 / _ \/ __ \/ __  /
/  __/ / / / /_/ /
\___/_/ /_/\__,_/
'
echo "\033[35;1m* * script done * * \033[0m"
