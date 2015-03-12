#!/bin/sh
# bachir soussi chiadmi
#
# http://www.debian.org/doc/manuals/securing-debian-howto/
# https://www.thefanclub.co.za/how-to/how-secure-ubuntu-1204-lts-server-part-1-basics
# https://www.linode.com/docs/websites/lamp/lamp-server-on-debian-7-wheezy/
# http://web-74.com/blog/reseaux/gerer-le-deploiement-facilement-avec-git/
#

echo "This script has been tested only on Linux Debian 7"
echo "Please run this script as root"

read -e -p "Should we start ? [Y:n]" i "y" start
if [start != 'y']; then
  exit
fi

echo "* * *"

# get the current position
_cwd="$(pwd)"

echo "Installing harden"
sleep 5
apt-get install harden
echo "Harden instaled"
echo "* * *"

echo "Installing ufw and setup firewall (allowing only ssh and http)"
sleep 5
apt-get install ufw
ufw allow ssh
ufw allow http
ufw enable
ufw status verbose
echo "ufw installed and firwall configured"
echo "* * *"

echo "Create new user (you will be asked a user name and a password)"
sleep 5
read -p "Enter user name: " user
# read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
adduser "$user"
echo "adding $user to admin group and limiting su to the admin group"
groupadd admin
usermod -a -G admin "$user"
dpkg-statoverride --update --add root admin 4750 /bin/su
echo "user $user configured"
echo "* * *"

read -e -p "Securing ssh (disabling root login) [Y:n]" -i "y" securssh
if [$securssh = 'y']; then
  sed -i 's/PermitRootLogin\ yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/PermitEmptyPasswords\ yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
  sed -i 's/Protocol\ [0-9]/Protocol 2/g' /etc/ssh/sshd_config
  echo "SSH secured"
else
  echo 'root user can stile coonect through ssh'
fi
echo "* * *"

echo "Installing AMP web server"
echo "Installing Apache2"
sleep 5
apt-get install apache2
a2enmod rewrite
service apache2 restart
echo "Apache2 installed"
echo "* * *"

echo "installing Mysql"
sleep 5
apt-get install mysql-server
mysql_secure_installation
echo "mysql installed"
echo "* * *"

echo "Installing PHP"
sleep 5
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
echo "* * *"

echo "Installing Awstat"
sleep 5
apt-get install awstats
echo "Awstat installed"
echo "* * *"

read -e -p "Should we installe vhost [Y:n]" -i "y" vh
if [ $vh = "y"]; then
  read -p "hostname ? " _host_name
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
echo "* * *"

#installing better prompt and some goodies for root
echo "Installing shell prompt for root"
sleep 5
git clone git://github.com/bachy/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh && cd -
source ~/.bashrc
echo "done"
echo "* * *"

#    __  _______ __________
#   / / / / ___// ____/ __ \
#  / / / /\__ \/ __/ / /_/ /
# / /_/ /___/ / /___/ _, _/
# \____//____/_____/_/ |_|

# setup user environment
echo "Installing shell prompt for $user"
sleep 5
cd ~
git clone git://github.com/bachy/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh && cd -
cd ~
source .bashrc
echo "done"
echo "* * *"

# setup bare repositorie to push to
echo "setup git repositories for $_host_name"
sleep 5
mkdir ~/git-repositories
mkdir ~/git-repositories/"$_host_name".git
cd ~/git-repositories/"$_host_name".git
git init --bare

# setup git repo on site folder
cd /srv/www/"$_host_name"/public_html/
git init
# link to the bare repo
git remote add origin ~/git-repositories/"$_host_name".git

# create hooks that will update the site repo
cd ~
cp "$_cwd"/assets/git-pre-receive ~/git-repositories/"$_host_name".git/hooks/pre-receive
cp "$_cwd"/assets/git-post-receive ~/git-repositories/"$_host_name".git/hooks/post-receive

sed -ir "s/PRODDIR=\"www\"/PRODDIR=\/srv\/www\/$_host_name\/public_html/g" ~/git-repositories/"$_host_name".git/hooks/pre-receive
sed -ir "s/PRODDIR=\"www\"/PRODDIR=\/srv\/www\/$_host_name\/public_html/g" ~/git-repositories/"$_host_name".git/hooks/post-receive

cd ~/git-repositories/"$_host_name".git/hooks/
chmod +x post-receive pre-receive

# done
echo "git repos for $_host_name install succeed"
echo "your site stay now to ~/www/$_host_name"
echo "you can push updates on prod branch through $user@IP.IP.IP.IP:git-repositories/$_host_name.git"
echo "* * *"
