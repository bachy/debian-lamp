#!/bin/sh

echo -e '\033[35m
    __
   / /__  ____ ___  ____
  / / _ \/ __ `__ \/ __ \
 / /  __/ / / / / / /_/ /
/_/\___/_/ /_/ /_/ .___/
                /_/
\033[0m'
echo -e "\033[35;1mLEMP server (Nginx Mysql Php-fpm) \033[0m"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# get the current position
_cwd="$(pwd)"
# check for assets forlder
_assets="$_cwd/assets"
if [ ! -d "$_assets" ]; then
  _assets="$_cwd/../assets"
  if [ ! -d "$_assets" ]; then
    echo "!! can't find assets directory !!"
    exit
  fi
fi

sleep 2

echo -e '\033[35m
    __  ___                 __
   /  |/  /_  ___________ _/ /
  / /|_/ / / / / ___/ __ `/ /
 / /  / / /_/ (__  ) /_/ / /
/_/  /_/\__, /____/\__, /_/
       /____/        /_/
\033[0m'
echo -e "\033[35;1minstalling Mysql \033[0m"
sleep 3
apt-get --yes install mariadb-server
mysql_secure_installation

cp "$_assets"/mysql/innodb-file-per-table.cnf /etc/mysql/conf.d/

systemctl enable mariadb.service
systemctl restart mariadb.service
echo -e "\033[92;1mmysql installed\033[Om"

echo -e '\033[35m
    ____  __  ______
   / __ \/ / / / __ \
  / /_/ / /_/ / /_/ /
 / ____/ __  / ____/
/_/   /_/ /_/_/
\033[0m'
echo -e "\033[35;1mInstalling PHP 7.3 \033[0m"
sleep 3

# mv: cannot stat '/etc/php/7.0/fpm/php.ini': No such file or directory
# cp: cannot create regular file '/etc/php/7.0/fpm/php.ini': No such file or directory
# Configuring PHP
# Failed to enable unit: Unit file php7.0-fpm.service does not exist.
# Failed to start php7.0-fpm.service: Unit php7.0-fpm.service not found.

apt-get --yes install php7.3-fpm php7.3-mysql php7.3-opcache php7.3-curl php7.3-mbstring php7.3-zip php7.3-xml php7.3-gd php-memcached php7.3-imagick php7.3-apcu
# php7.3-mcrypt  ??

mv /etc/php/7.3/fpm/php.ini /etc/php/7.3/fpm/php.ini.back
cp "$_assets"/php-fpm.ini /etc/php/7.3/fpm/php.ini

echo "Configuring PHP"

mkdir /var/log/php
chown www-data /var/log/php
cp "$_assets"/logrotate-php /etc/logrotate.d/php

systemctl enable php7.3-fpm
systemctl start php7.3-fpm

# echo "Installing memecached"
# replaced by redis
# apt-get --yes install memcached
# sed -i "s/-m\s64/-m 128/g" /etc/memcached.conf
#
# systemctl start memcached

echo -e "\033[92;1mphp installed\033[Om"

echo -e '\033[35m
    _   __      _
   / | / /___ _(_)___  _  __
  /  |/ / __ `/ / __ \| |/_/
 / /|  / /_/ / / / / />  <
/_/ |_/\__, /_/_/ /_/_/|_|
      /____/
\033[0m'
echo -e "\033[35;1mInstalling Nginx \033[0m"
sleep 3
apt-get --yes install nginx
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.ori
cp "$_assets"/default.nginxconf /etc/nginx/sites-available/default

systemctl enable nginx
systemctl restart nginx
echo -e "\033[92;1mNginx installed\033[Om"

echo -e '\033[35m
           __          __  ___      ___       __          _
    ____  / /_  ____  /  |/  /_  __/   | ____/ /___ ___  (_)___
   / __ \/ __ \/ __ \/ /|_/ / / / / /| |/ __  / __ `__ \/ / __ \
  / /_/ / / / / /_/ / /  / / /_/ / ___ / /_/ / / / / / / / / / /
 / .___/_/ /_/ .___/_/  /_/\__, /_/  |_\__,_/_/ /_/ /_/_/_/ /_/
/_/         /_/           /____/
\033[0m'
echo -e "\033[35;1mInstalling phpMyAdmin \033[0m"
##### Building dependency tree
##### Reading state information... Done
##### Package phpmyadmin is not available, but is referred to by another package.
##### This may mean that the package is missing, has been obsoleted, or
##### is only available from another source
#####
##### E: Package 'phpmyadmin' has no installation candidate
##### cp: missing destination file operand after '/root/debian-web-server/assets/nginx-phpmyadmin.conf'
##### Try 'cp --help' for more information.

# TODO no pma package available :(
# apt-get --yes install phpmyadmin
# ln -s /usr/share/phpmyadmin /var/www/html/
# cp "$_assets"/nginx-phpmyadmin.conf > /etc/nginx/sites-available/phpmyadmin.conf
# ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
# echo -e "\033[92;1mphpMyAdmin installed\033[Om"
# echo -e "\033[92;1mYou can access it at yourip/phpmyadmin\033[Om"

# install from source
apt-get install php-{mbstring,zip,gd,xml,pear,gettext,cgi}
cd /var/www/html/
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip
unzip phpMyAdmin-latest-all-languages.zip
mv phpMyAdmin-*-all-languages pma
rm phpMyAdmin-latest-all-languages.zip
# cp "$_assets"/nginx-phpmyadmin.conf > /etc/nginx/sites-available/phpmyadmin.conf
# ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
echo -e "\033[92;1mphpMyAdmin installed\033[Om"
echo -e "\033[92;1mYou can access it at yourip/pma\033[Om"



echo -e '\033[35m
    ____           ___
   / __ \___  ____/ (_)____
  / /_/ / _ \/ __  / / ___/
 / _, _/  __/ /_/ / (__  )
/_/ |_|\___/\__,_/_/____/
\033[0m'
echo -e "\033[35;1mInstalling Redis \033[0m"
sleep 3
apt-get --yes install redis-server php-redis

# TODO set maxmemory=2gb
# TODO set maxmemory-policy=volatile-lru
# TODO comment all save line

# WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
# WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
# WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.

# https://blog.opstree.com/2019/04/16/redis-best-practices-and-performance-tuning/

systemctl enable redis-server
systemctl restart redis-server
systemctl restart php7.3-fpm
echo -e "\033[92;1mRedis installed\033[Om"

echo -e '\033[35m
   ______
  / ____/___  ____ ___  ____  ____  ________  _____
 / /   / __ \/ __ `__ \/ __ \/ __ \/ ___/ _ \/ ___/
/ /___/ /_/ / / / / / / /_/ / /_/ (__  )  __/ /
\____/\____/_/ /_/ /_/ .___/\____/____/\___/_/
                    /_/
\033[0m'
echo -e "\033[35;1mInstalling Composer \033[0m"
sleep 3
export COMPOSER_HOME=/usr/local/composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo -e "\033[92;1mComposer installed\033[Om"


echo -e '\033[35m
    ____                  __
   / __ \_______  _______/ /_
  / / / / ___/ / / / ___/ __ \
 / /_/ / /  / /_/ (__  ) / / /
/_____/_/   \__,_/____/_/ /_/
\033[0m'
echo -e "\033[35;1mInstalling Drush and DrupalConsole\033[0m"
sleep 3
curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal
# curl https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar -L -o /usr/local/bin/drush
wget -O /usr/local/bin/drush https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
chmod +x /usr/local/bin/drush
echo -e "\033[92;1mDrush and DrupalConsoleinstalled\033[Om"
