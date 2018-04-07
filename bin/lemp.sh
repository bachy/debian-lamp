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
apt-get --yes --force-yes install mariadb-server
mysql_secure_installation
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
apt-get --yes --force-yes install php7.0-fpm php7.0-mysql php7.0-opcache php7.0-curl php7.0-mbstring php7.0-zip php7.0-xml php7.0-gd php7.0-mcrypt php-memcached

mv /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.back
cp "$_cwd"/assets/php-fpm.ini /etc/php/7.0/fpm/php.ini

echo "Configuring PHP"

mkdir /var/log/php
chown www-data /var/log/php
cp "$_cwd"/assets/logrotate-php /etc/logrotate.d/php

systemctl enable php7.0-fpm
systemctl start php7.0-fpm

# echo "Installing memecached"
# replaced by redis
# apt-get --yes --force-yes install memcached
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
apt-get --yes --force-yes install nginx
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.ori
cp "$_cwd"/assets/default.nginxconf /etc/nginx/sites-available/default

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
apt-get --yes --force-yes install phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/
# cp "$_cwd"/assets/nginx-phpmyadmin.conf > /etc/nginx/sites-available/phpmyadmin.conf
# ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf

# echo "\033[35;1msecuring phpMyAdmin \033[0m"
# sed -i "s/DirectoryIndex index.php/DirectoryIndex index.php\nAllowOverride all/"
# cp "$_cwd"/assets/phpmyadmin_htaccess > /usr/share/phpmyadmin/.htaccess
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
apt-get --yes --force-yes install redis-server php-redis

systemctl enable redis-server
systemctl restart redis-server
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


echo '\033[35m
        __               __
 _   __/ /_  ____  _____/ /_
| | / / __ \/ __ \/ ___/ __/
| |/ / / / / /_/ (__  ) /_
|___/_/ /_/\____/____/\__/
\033[0m'
echo "\033[35;1mVHOST install \033[0m"
while [ "$vh" != "y" ] && [ "$vh" != "n" ]
do
echo -n "Should we install a vhost? [y|n] "
read vh
# vh=${vh:-y}
done
if [ "$vh" = "y" ]; then

  while [ "$_domain" = "" ]
  do
  read -p "enter a hostname ? " _domain
  if [ "$_domain" != "" ]; then
    read -p "is hostname $_domain correcte [y|n] " validated
    if [ "$validated" = "y" ]; then
      break
    else
      _domain=""
    fi
  fi
  done
  # ask for simple php conf or drupal conf
  while [ "$_drupal" != "yes" ] && [ "$_drupal" != "no" ]
  do
    echo -n "Is your site is a drupal one? [yes|no] "
    read _drupal
  done
  # ask for let's encrypt
  while [ "$_letsencrypt" != "yes" ] && [ "$_letsencrypt" != "no" ]
  do
    echo "Let's encrypt"
    echo "Let's encrypt needs a public registered domain name with proper DNS records ( A records or CNAME records for subdomains pointing to your server)."
    echo -n "Should we install let's encrypt certificate with $_domain? [yes|no] "
    read _letsencrypt
  done

  # lets'encrypt
  # https://certbot.eff.org/lets-encrypt/debianstretch-nginx
  if [ "$_letsencrypt" = "yes" ]; then
    apt-get install certbot
    certbot certonly --cert-name "$_domain" --standalone –d "$_domain"
    openssl dhparam –out /etc/nginx/dhparam.pem 2048
    # TODO renewing
    touch /var/spool/crontab/root
    crontab -l > mycron
    echo "0 3 * * * certbot renew --pre-hook 'systemctl stop nginx' --post-hook 'systemctl start nginx' --cert-name $_domain" >> mycron
    crontab mycron
    rm mycron
  fi

  if [ "$_drupal" = "yes" ]; then
    if [ "$_letsencrypt" = "yes" ]; then
      _conffile = "drupal-ssl.nginxconf"
    else
      _conffile = "drupal.nginxconf"
    fi
  else
    if [ "$_letsencrypt" = "yes" ]; then
      _conffile = "simple-phpfpm-ssl.nginxconf"
    else
      _conffile = "simple-phpfpm.nginxconf"
    fi
  fi

  cp "$_cwd"/assets/"$_conffile" /etc/nginx/sites-available/"$_domain".conf
  sed -ir "s/DOMAIN\.LTD/$_domain/g" /etc/nginx/sites-available/"$_domain".conf

  mkdir -p /var/www/"$_domain"/public_html
  mkdir /var/www/"$_domain"/logs
  #set proper right to user will handle the app
  chown -R root:admin  /var/www/"$_domain"/
  chmod -R g+w /var/www/"$_domain"/
  chmod -R g+r /var/www/"$_domain"/

  # create a shortcut to the site
  # TODO ask for $user name if not existing
  mkdir /home/"$user"/www/
  chown "$user":admin /home/"$user"/www/
  ln -s /var/www/"$_domain" /home/"$user"/www/"$_domain"

  # activate the vhost
  ln -s /etc/nginx/sites-available/"$_domain".conf /etc/nginx/sites-enabled/"$_domain".conf

  # restart nginx
  systemctl restart nginx
  echo "\033[92;1mvhost $_domain configured\033[Om"
else
  echo "Vhost installation aborted"
fi


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
# apt-get --yes --force-yes install munin munin-node munin-plugins-extra
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
# apt-get --yes --force-yes install monit
# # TODO setup monit rc
# cat "$_cwd"/assets/monitrc > /etc/monit/monitrc
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
# apt-get --yes --force-yes install awstats
# # Configure AWStats
# temp=`grep -i sitedomain /etc/awstats/awstats.conf.local | wc -l`
# if [ $temp -lt 1 ]; then
#     echo SiteDomain="$_domain" >> /etc/awstats/awstats.conf.local
# fi
# # Disable Awstats from executing every 10 minutes. Put a hash in front of any line.
# sed -i 's/^[^#]/#&/' /etc/cron.d/awstats
# echo "\033[92;1mAwstat installed\033[Om"
