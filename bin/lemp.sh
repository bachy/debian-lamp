#!/bin/sh

echo '\033[35m
    __
   / /__  ____ ___  ____
  / / _ \/ __ `__ \/ __ \
 / /  __/ / / / / / /_/ /
/_/\___/_/ /_/ /_/ .___/
                /_/
\033[0m'
echo "\033[35;1mLEMP server (Nginx Mysql Php-fpm) \033[0m"

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

echo '\033[35m
    __  ___                 __
   /  |/  /_  ___________ _/ /
  / /|_/ / / / / ___/ __ `/ /
 / /  / / /_/ (__  ) /_/ / /
/_/  /_/\__, /____/\__, /_/
       /____/        /_/
\033[0m'
echo "\033[35;1minstalling Mysql \033[0m"
sleep 3
apt-get --yesinstall mariadb-server
mysql_secure_installation

cp "$_assets"/mysql/innodb-file-per-table.cnf /etc/mysql/conf.d/

systemctl enable mariadb.service
systemctl restart mariadb.service
echo "\033[92;1mmysql installed\033[Om"

echo '\033[35m
    ____  __  ______
   / __ \/ / / / __ \
  / /_/ / /_/ / /_/ /
 / ____/ __  / ____/
/_/   /_/ /_/_/
\033[0m'
echo "\033[35;1mInstalling PHP 7.0 \033[0m"
sleep 3
apt-get --yesinstall php7.0-fpm php7.0-mysql php7.0-opcache php7.0-curl php7.0-mbstring php7.0-zip php7.0-xml php7.0-gd php7.0-mcrypt php-memcached php7.0-imagick

mv /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.back
cp "$_assets"/php-fpm.ini /etc/php/7.0/fpm/php.ini

echo "Configuring PHP"

mkdir /var/log/php
chown www-data /var/log/php
cp "$_assets"/logrotate-php /etc/logrotate.d/php

systemctl enable php7.0-fpm
systemctl start php7.0-fpm

# echo "Installing memecached"
# replaced by redis
# apt-get --yesinstall memcached
# sed -i "s/-m\s64/-m 128/g" /etc/memcached.conf
#
# systemctl start memcached

echo "\033[92;1mphp installed\033[Om"

echo '\033[35m
    _   __      _
   / | / /___ _(_)___  _  __
  /  |/ / __ `/ / __ \| |/_/
 / /|  / /_/ / / / / />  <
/_/ |_/\__, /_/_/ /_/_/|_|
      /____/
\033[0m'
echo "\033[35;1mInstalling Nginx \033[0m"
sleep 3
apt-get --yesinstall nginx
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.ori
cp "$_assets"/default.nginxconf /etc/nginx/sites-available/default

systemctl enable nginx
systemctl restart nginx
echo "\033[92;1mNginx installed\033[Om"

echo '\033[35m
           __          __  ___      ___       __          _
    ____  / /_  ____  /  |/  /_  __/   | ____/ /___ ___  (_)___
   / __ \/ __ \/ __ \/ /|_/ / / / / /| |/ __  / __ `__ \/ / __ \
  / /_/ / / / / /_/ / /  / / /_/ / ___ / /_/ / / / / / / / / / /
 / .___/_/ /_/ .___/_/  /_/\__, /_/  |_\__,_/_/ /_/ /_/_/_/ /_/
/_/         /_/           /____/
\033[0m'
echo "\033[35;1mInstalling phpMyAdmin \033[0m"
apt-get --yesinstall phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/
cp "$_assets"/nginx-phpmyadmin.conf > /etc/nginx/sites-available/phpmyadmin.conf
ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf

# echo "\033[35;1msecuring phpMyAdmin \033[0m"
# sed -i "s/DirectoryIndex index.php/DirectoryIndex index.php\nAllowOverride all/"
# cp "$_assets"/phpmyadmin_htaccess > /usr/share/phpmyadmin/.htaccess
# echo -n "define a user name for phpmyadmin : "
# read un
# htpasswd -c /etc/phpmyadmin/.htpasswd $un
# service apache2 restart
echo "\033[92;1mphpMyAdmin installed\033[Om"
echo "\033[92;1mYou can access it at yourip/phpmyadmin\033[Om"

echo '\033[35m
    ____           ___
   / __ \___  ____/ (_)____
  / /_/ / _ \/ __  / / ___/
 / _, _/  __/ /_/ / (__  )
/_/ |_|\___/\__,_/_/____/
\033[0m'
echo "\033[35;1mInstalling Redis \033[0m"
sleep 3
apt-get --yesinstall redis-server php-redis

# TODO set maxmemory=2gb
# TODO set maxmemory-policy=volatile-lru
# TODO comment all save line


systemctl enable redis-server
systemctl restart redis-server
systemctl restart php7.0-fpm
echo "\033[92;1mRedis installed\033[Om"

echo '\033[35m
   ______
  / ____/___  ____ ___  ____  ____  ________  _____
 / /   / __ \/ __ `__ \/ __ \/ __ \/ ___/ _ \/ ___/
/ /___/ /_/ / / / / / / /_/ / /_/ (__  )  __/ /
\____/\____/_/ /_/ /_/ .___/\____/____/\___/_/
                    /_/
\033[0m'
echo "\033[35;1mInstalling Composer \033[0m"
sleep 3
export COMPOSER_HOME=/usr/local/composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "\033[92;1mComposer installed\033[Om"


echo '\033[35m
    ____                  __
   / __ \_______  _______/ /_
  / / / / ___/ / / / ___/ __ \
 / /_/ / /  / /_/ (__  ) / / /
/_____/_/   \__,_/____/_/ /_/
\033[0m'
echo "\033[35;1mInstalling Drush and DrupalConsole\033[0m"
sleep 3
curl https://drupalconsole.com/installer -L -o /usr/local/bin/drupal
chmod +x /usr/local/bin/drupal
curl https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar -L -o /usr/local/bin/drush
chmod +x /usr/local/bin/drush
echo "\033[92;1mDrush and DrupalConsoleinstalled\033[Om"



# TODO supervising
# echo '\033[35m
#    __  ___          _ __      __  __  ___          _
#   /  |/  /__  ___  (_) /_   _/_/ /  |/  /_ _____  (_)__
#  / /|_/ / _ \/ _ \/ / __/ _/_/  / /|_/ / // / _ \/ / _ \
# /_/  /_/\___/_//_/_/\__/ /_/   /_/  /_/\_,_/_//_/_/_//_/
# \033[0m'
# echo "\033[35;1mInstalling Munin \033[0m"
# sleep 3
# # https://www.howtoforge.com/tutorial/server-monitoring-with-munin-and-monit-on-debian/
# apt-get --yesinstall munin munin-node munin-plugins-extra
# # Configure Munin
# # enable plugins
# ln -s /usr/share/munin/plugins/mysql_ /etc/munin/plugins/mysql_
# ln -s /usr/share/munin/plugins/mysql_bytes /etc/munin/plugins/mysql_bytes
# ln -s /usr/share/munin/plugins/mysql_innodb /etc/munin/plugins/mysql_innodb
# ln -s /usr/share/munin/plugins/mysql_isam_space_ /etc/munin/plugins/mysql_isam_space_
# ln -s /usr/share/munin/plugins/mysql_queries /etc/munin/plugins/mysql_queries
# ln -s /usr/share/munin/plugins/mysql_slowqueries /etc/munin/plugins/mysql_slowqueries
# ln -s /usr/share/munin/plugins/mysql_threads /etc/munin/plugins/mysql_threads
#
# ln -s /usr/share/munin/plugins/apache_accesses /etc/munin/plugins/
# ln -s /usr/share/munin/plugins/apache_processes /etc/munin/plugins/
# ln -s /usr/share/munin/plugins/apache_volume /etc/munin/plugins/
#
# # ln -s /usr/share/munin/plugins/fail2ban /etc/munin/plugins/
#
# # dbdir, htmldir, logdir, rundir, and tmpldir
# sed -i 's/^#dbdir/dbdir/' /etc/munin/munin.conf
# sed -i 's/^#htmldir/htmldir/' /etc/munin/munin.conf
# sed -i 's/^#logdir/logdir/' /etc/munin/munin.conf
# sed -i 's/^#rundir/rundir/' /etc/munin/munin.conf
# sed -i 's/^#tmpldir/tmpldir/' /etc/munin/munin.conf
#
# sed -i "s/^\[localhost.localdomain\]/[${HOSTNAME}]/" /etc/munin/munin.conf
#
# # ln -s /etc/munin/apache24.conf /etc/apache2/conf-enabled/munin.conf
# sed -i 's/Require local/Require all granted\nOptions FollowSymLinks SymLinksIfOwnerMatch/g' /etc/munin/apache24.conf
# htpasswd -c /etc/munin/munin-htpasswd admin
# sed -i 's/Require all granted/AuthUserFile \/etc\/munin\/munin-htpasswd\nAuthName "Munin"\nAuthType Basic\nRequire valid-user/g' /etc/munin/apache24.conf
#
#
# service apache2 restart
# service munin-node restart
# echo "\033[92;1mMunin installed\033[Om"
#
# echo "\033[35;1mInstalling Monit \033[0m"
# sleep 3
# # https://www.howtoforge.com/tutorial/server-monitoring-with-munin-and-monit-on-debian/2/
# apt-get --yesinstall monit
# # TODO setup monit rc
# cat "$_assets"/monitrc > /etc/monit/monitrc
#
# # TODO setup webaccess
# passok=0
# while [ "$passok" = "0" ]
# do
#   echo -n "Write web access password to monit"
#   read passwda
#   echo -n "ReWrite web access password to monit"
#   read passwdb
#   if [ "$passwda" = "$passwdb" ]; then
#     sed -i 's/PASSWD_TO_REPLACE/$passwda/g' /etc/monit/monitrc
#     passok=1
#   else
#     echo "pass words don't match, please try again"
#   fi
# done
#
# # TODO setup mail settings
# sed -i "s/server1\.example\.com/$HOSTNAME/g" /etc/monit/monitrc
#
# mkdir /var/www/html/monit
# echo "hello" > /var/www/html/monit/token
#
# service monit start
#
# echo "\033[92;1mMonit installed\033[Om"


# echo '\033[35m
#     ___                __        __
#    /   |_      _______/ /_____ _/ /_
#   / /| | | /| / / ___/ __/ __ `/ __/
#  / ___ | |/ |/ (__  ) /_/ /_/ / /_
# /_/  |_|__/|__/____/\__/\__,_/\__/
# \033[0m'
# echo "\033[35;1mInstalling Awstat \033[0m"
# sleep 3
# apt-get --yesinstall awstats
# # Configure AWStats
# temp=`grep -i sitedomain /etc/awstats/awstats.conf.local | wc -l`
# if [ $temp -lt 1 ]; then
#     echo SiteDomain="$_domain" >> /etc/awstats/awstats.conf.local
# fi
# # Disable Awstats from executing every 10 minutes. Put a hash in front of any line.
# sed -i 's/^[^#]/#&/' /etc/cron.d/awstats
# echo "\033[92;1mAwstat installed\033[Om"
