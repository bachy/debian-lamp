#!/bin/sh
# bachir soussi chiadmi
#
# http://www.pontikis.net/blog/debian-9-stretch-rc3-web-server-setup-php7-mariadb
# http://web-74.com/blog/reseaux/gerer-le-deploiement-facilement-avec-git/
#

echo '\033[35m
    ____       __    _                _____
   / __ \___  / /_  (_)___ _____     / ___/___  ______   _____  _____
  / / / / _ \/ __ \/ / __ `/ __ \    \__ \/ _ \/ ___/ | / / _ \/ ___/
 / /_/ /  __/ /_/ / / /_/ / / / /   ___/ /  __/ /   | |/ /  __/ /
/_____/\___/_.___/_/\__,_/_/ /_/   /____/\___/_/    |___/\___/_/

\033[0m'
echo "\033[35;1mThis script has been tested only on Linux Debian 9 \033[0m"
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

echo '\033[35m
   __  ______  __________  ___    ____  ______
  / / / / __ \/ ____/ __ \/   |  / __ \/ ____/
 / / / / /_/ / / __/ /_/ / /| | / / / / __/
/ /_/ / ____/ /_/ / _, _/ ___ |/ /_/ / /___
\____/_/    \____/_/ |_/_/  |_/_____/_____/
\033[0m'
apt-get update
apt-get upgrade

echo '\033[35m
    __  ____
   /  |/  (_)_________
  / /|_/ / / ___/ ___/
 / /  / / (__  ) /__
/_/  /_/_/____/\___/

\033[0m'
apt-get install vim
sed -i "s/^# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen
locale-gen
apt-get install ntp

echo '\033[35m
    ______________  _______       _____    __    __
   / ____/  _/ __ \/ ____/ |     / /   |  / /   / /
  / /_   / // /_/ / __/  | | /| / / /| | / /   / /
 / __/ _/ // _, _/ /___  | |/ |/ / ___ |/ /___/ /___
/_/   /___/_/ |_/_____/  |__/|__/_/  |_/_____/_____/
\033[0m'
echo "\033[35;1mInstalling ufw and setup firewall (allowing only ssh and http) \033[0m"
sleep 3
apt-get install ufw
# ufw allow ssh # knockd will open the ssh port
ufw allow http
ufw allow https
ufw enable
ufw status verbose
echo "\033[92;1mufw installed and firwall configured\033[Om"

echo '\033[35m
    ______      _ _____   __
   / ____/___ _(_) /__ \ / /_  ____ _____
  / /_  / __ `/ / /__/ // __ \/ __ `/ __ \
 / __/ / /_/ / / // __// /_/ / /_/ / / / /
/_/    \__,_/_/_//____/_.___/\__,_/_/ /_/
\033[0m'
echo "\033[35;1mInstalling fall2ban \033[0m"
apt-get install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# ToDo ask for email and configure jail.local with it
service fail2ban restart
echo "\033[92;1mfail2ban installed and configured\033[Om"

echo '\033[35m
    __                    __       __
   / /______  ____  _____/ /______/ /
  / //_/ __ \/ __ \/ ___/ //_/ __  /
 / ,< / / / / /_/ / /__/ ,< / /_/ /
/_/|_/_/ /_/\____/\___/_/|_|\__,_/
\033[0m'
echo "\033[35;1mInstalling knockd \033[0m"
sleep 3
apt-get install knockd
echo -n "define a sequence number for opening (as 7000,8000,9000) : "
read sq1
echo -n "define a sequence number for closing (as 9000,8000,7000) : "
read sq2
sed -i "s/7000,8000,9000/$sq1/g" /etc/knockd.conf
sed -i "s/9000,8000,7000/$sq2/g" /etc/knockd.conf
sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
service knockd start
echo "\033[92;1mknockd installed and configured\033[Om"
echo "\033[92;1mplease note these sequences for future knocking\033[Om"
echo "opening : $sq1 ; closing : $sq2"

echo '\033[35m
   __  _______ __________
  / / / / ___// ____/ __ \
 / / / /\__ \/ __/ / /_/ /
/ /_/ /___/ / /___/ _, _/
\____//____/_____/_/ |_|
\033[0m'
echo "\033[35;1mCreate new user (you will be asked a user name and a password) \033[0m"
sleep 3
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


echo '\033[35m
    __  ______    ______
   /  |/  /   |  /  _/ /
  / /|_/ / /| |  / // /
 / /  / / ___ |_/ // /___
/_/  /_/_/  |_/___/_____/
\033[0m'
echo "\033[35;1mEnable mail sending for php \033[0m"
# http://www.sycha.com/lamp-setup-debian-linux-apache-mysql-php#anchor13
sleep 3
apt-get install exim4
echo "\033[35;1mConfiguring EXIM4 \033[0m"
while [ "$configexim" != "y" ] && [ "$configexim" != "n" ]
do
  echo -n "Should we configure exim4 ? [y|n] "
  read configexim
done
if [ "$configexim" = "y" ]; then
  echo "choose the first option :internet site; mail is sent and received directly using SMTP. Leave the other options as default exepted for domain name which should be valid domain name if you want your mails to not be considered as spam"
  echo "press any key to continue."
  read continu
  dpkg-reconfigure exim4-config
else
  echo 'exim not configured'
fi
service exim4 restart

# dkim spf
# https://debian-administration.org/article/718/DKIM-signing_outgoing_mail_with_exim4
echo "\033[35;1mConfiguring DKIM \033[0m"
while [ "$installdkim" != "y" ] && [ "$installdkim" != "n" ]
do
  echo -n "Should we install dkim for exim4 ? [y|n] "
  read installdkim
done
if [ "$installdkim" = "y" ]; then
  echo -n "Choose a domain for dkim (same domain as you chose before for exim4): "
  read domain
  selector=$(date +%Y%m%d)

  mkdir /etc/exim4/dkim
  openssl genrsa -out /etc/exim4/dkim/"$domain"-private.pem 1024 -outform PEM
  openssl rsa -in /etc/exim4/dkim/"$domain"-private.pem -out /etc/exim4/dkim/"$domain".pem -pubout -outform PEM
  chown root:Debian-exim /etc/exim4/dkim/"$domain"-private.pem
  chmod 440 /etc/exim4/dkim/"$domain"-private.pem

  cp "$_cwd"/assets/exima4_dkim.conf /etc/exim4/conf.d/main/00_local_macros
  sed -ir "s/DOMAIN_TO_CHANGE/$domain/g" /etc/exim4/conf.d/main/00_local_macros
  sed -ir "s/DATE_TO_CHANGE/$selector/g" /etc/exim4/conf.d/main/00_local_macros

  update-exim4.conf
  service exim4 restart
  echo "please create a TXT entry in your dns zone : $selector._domainkey.$domain \n"
  echo "your public key is : \n"
  cat /etc/exim4/dkim/"$domain".pem
  echo "press any key to continue."
  read continu
else
  echo 'dkim not installed'
fi



echo '\033[35m
   __________ __  __
  / ___/ ___// / / /
  \__ \\__ \/ /_/ /
 ___/ /__/ / __  /
/____/____/_/ /_/
\033[0m'
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
  echo "\033[92;1mSSH secured\033[Om"
else
  echo 'root user can still conect through ssh'
fi

echo '\033[35m
  ______ _______ _____
 |  ____|__   __|  __ \
 | |__     | |  | |__) |
 |  __|    | |  |  ___/
 | |       | |  | |
 |_|       |_|  |_|
\033[0m'

echo -n "Should we install ftp server? [Y|n] "
read yn
yn=${yn:-y}
if [ "$yn" = "y" ]; then
  echo "installing proftpd"
  apt-get install proftpd
  while [ "$_server_name" = "" ]
  do
  read -p "enter a server name ? " _server_name
  if [ "$_server_name" != "" ]; then
    read -p "is server name $_server_name correcte [y|n] " validated
    if [ "$validated" = "y" ]; then
      break
    else
      _server_name=""
    fi
  fi
  done

  echo "Configuring proftpd"
  cp "$_cwd"/assets/proftpd.conf /etc/proftpd/conf.d/"$_server_name".conf
  sed -ir "s/example/$_server_name/g" /etc/proftpd/conf.d/"$_server_name".conf

  ufw allow ftp

  addgroup ftpuser
  echo "ftp installtion done"
  echo "to permit to a user to connect through ftp, add him to the ftpuser group by running : usermod -a -G admin USERNAME"
  echo "FTP users are jailed on their home by default"

fi

# TODO : allow ssh/ftp connection only from given ips

echo "\033[35;1mInstalling AMP web server \033[0m"

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
apt-get install mariadb-server
mysql_secure_installation
systemctl restart mariadb.service
echo "\033[92;1mmysql installed\033[Om"


echo '\033[35m
    ___                     __        ___
   /   |  ____  ____ ______/ /_  ___ |__ \
  / /| | / __ \/ __ `/ ___/ __ \/ _ \__/ /
 / ___ |/ /_/ / /_/ / /__/ / / /  __/ __/
/_/  |_/ .___/\__,_/\___/_/ /_/\___/____/
      /_/
\033[0m'
echo "\033[35;1mInstalling Apache2 \033[0m"
sleep 3
apt-get install apache2
a2enmod rewrite
# cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.back
# cat "$_cwd"/assets/apache2.conf > /etc/apache2/apache2.conf
# Change logrotate for Apache2 log files to keep 10 days worth of logs
sed -i 's/\tweekly/\tdaily/' /etc/logrotate.d/apache2
sed -i 's/\trotate .*/\trotate 10/' /etc/logrotate.d/apache2
# Remove Apache server information from headers.
sed -i 's/ServerTokens .*/ServerTokens Prod/' /etc/apache2/conf-enabled/security.conf
sed -i 's/ServerSignature .*/ServerSignature Off/' /etc/apache2/conf-enabled/security.conf
service apache2 restart
echo "\033[92;1mApache2 installed\033[Om"


echo '\033[35m
    ____  __  ______
   / __ \/ / / / __ \
  / /_/ / /_/ / /_/ /
 / ____/ __  / ____/
/_/   /_/ /_/_/
\033[0m'
echo "\033[35;1mInstalling PHP \033[0m"
sleep 3
apt-get install php7.0 php-pear php7-gd
echo "Configuring PHP"
cp "$_cwd"/assets/99-lamp-php.ini /etc/php/7.0/apache2/conf.d/
# conffile=/etc/php/7.0/apache2/conf.d/99-lamp-php.ini
# cp /etc/php/7.0/apache2/php.ini $conffile
# sed -i "s/max_execution_time\ =\ [0-9]\+/max_execution_time = 60/g" $conffile
# sed -i "s/max_input_time\ =\ [0-9]\+/max_input_time = 60/g" $conffile
# sed -i "s/memory_limit\ =\ [0-9]\+M/memory_limit = 512M/g" $conffile
# sed -i "s/;\?error_reporting\ =\ [^\n]\+/error_reporting = E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR/g" $conffile
# sed -i "s/;\?display_errors\ =\ On/display_errors = Off/g" $conffile
# sed -i "s/;\?log_errors\ =\ Off/log_errors = On/g" $conffile
# echo "register_globals = Off" >> $conffile
# following command doesn't work, make teh change manualy
#sed -ri ":a;$!{N;ba};s/;\?\ \?error_log\ =\ [^\n]\+([^\n]*\n(\n|$))/error_log = \/var\/log\/php\/error.log\1/g" /etc/php5/apache2/php.ini

mkdir /var/log/php
chown www-data /var/log/php
cp "$_cwd"/assets/logrotate-php /etc/logrotate.d/php

apt-get install php7.0-mysql php7.0-curl php7.0-mbstring php7.0-zip php7.0-xml php7.0-gd php7.0-mcrypt php-memcached

apt-get install memcached
sed -i "s/-m\s64/-m 128/g" /etc/memcached.conf

systemctl start memcached

echo "\033[92;1mphp installed\033[Om"

echo '\033[35m
           __          __  ___      ___       __          _
    ____  / /_  ____  /  |/  /_  __/   | ____/ /___ ___  (_)___
   / __ \/ __ \/ __ \/ /|_/ / / / / /| |/ __  / __ `__ \/ / __ \
  / /_/ / / / / /_/ / /  / / /_/ / ___ / /_/ / / / / / / / / / /
 / .___/_/ /_/ .___/_/  /_/\__, /_/  |_\__,_/_/ /_/ /_/_/_/ /_/
/_/         /_/           /____/
\033[0m'
echo "\033[35;1mInstalling phpMyAdmin \033[0m"
apt-get install phpmyadmin
# echo "include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf
ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
a2enconf phpmyadmin.conf
echo "\033[35;1msecuring phpMyAdmin \033[0m"
# sed -i "s/DirectoryIndex index.php/DirectoryIndex index.php\nAllowOverride all/"
cp "$_cwd"/assets/phpmyadmin_htaccess > /usr/share/phpmyadmin/.htaccess
echo -n "define a user name for phpmyadmin : "
read un
htpasswd -c /etc/phpmyadmin/.htpasswd $un
service apache2 restart
echo "\033[92;1mphpMyAdmin installed\033[Om"
echo "\033[92;1mYou can access it at yourip/phpmyadmin\033[Om"

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
  echo "\033[92;1mvhost $_host_name configured\033[Om"
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
# apt-get install munin munin-node munin-plugins-extra
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
# apt-get install monit
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
# apt-get install awstats
# # Configure AWStats
# temp=`grep -i sitedomain /etc/awstats/awstats.conf.local | wc -l`
# if [ $temp -lt 1 ]; then
#     echo SiteDomain="$_host_name" >> /etc/awstats/awstats.conf.local
# fi
# # Disable Awstats from executing every 10 minutes. Put a hash in front of any line.
# sed -i 's/^[^#]/#&/' /etc/cron.d/awstats
# echo "\033[92;1mAwstat installed\033[Om"


# echo '\033[35m
#   ______________  _______
#  /_  __/ ____/  |/  / __ \
#   / / / __/ / /|_/ / /_/ /
#  / / / /___/ /  / / ____/
# /_/ /_____/_/  /_/_/
# \033[0m'
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

echo '\033[35m
    ____        __     _______ __
   / __ \____  / /_   / ____(_) /__  _____
  / / / / __ \/ __/  / /_  / / / _ \/ ___/
 / /_/ / /_/ / /_   / __/ / / /  __(__  )
/_____/\____/\__/  /_/   /_/_/\___/____/
\033[0m'
#installing better prompt and some goodies for root
echo "\033[35;1mInstalling shell prompt for root \033[0m"
sleep 3
echo "cloning github.com/bachy/dotfiles-server"
git clone git://github.com/bachy/dotfiles-server.git ~/.dotfiles-server && cd ~/.dotfiles-server && ./install.sh && cd ~
source ~/.bashrc
echo "\033[92;1mDot files installed for root, you should installed them manually for $USER\033[0m"

# TODO add warning message on ssh connection if system needs updates

# TODO install and configure tmux


echo '\033[35m
    ___         __           __  __          __      __
   /   | __  __/ /_____     / / / /___  ____/ /___ _/ /____
  / /| |/ / / / __/ __ \   / / / / __ \/ __  / __ `/ __/ _ \
 / ___ / /_/ / /_/ /_/ /  / /_/ / /_/ / /_/ / /_/ / /_/  __/
/_/  |_\__,_/\__/\____/   \____/ .___/\__,_/\__,_/\__/\___/
                              /_/
\033[0m'
# https://www.howtoforge.com/how-to-configure-automatic-updates-on-debian-wheezy
# https://www.bisolweb.com/tutoriels/serveur-vps-ovh-partie-5-installation-apticron/

echo "\033[35;1mInstalling apticron \033[0m"
apt-get install apticron

sleep 3
echo -n "Enter an email: "
read email

sed -ir "s/EMAIL=\"root\"/EMAIL=\"$email\"/g" /etc/apticron/apticron.conf
# sed -ir "s/# DIFF_ONLY=\"1\"/DIFF_ONLY=\"1\"/g" /etc/apticron/apticron.conf
sed -ir "s/# NOTIFY_NEW=\"0\"/NOTIFY_NEW=\"0\"/g" /etc/apticron/apticron.conf




echo "\033[92;1mApticron installed and configured\033[0m"



echo '\033[35m
                  __
  ___  ____  ____/ /
 / _ \/ __ \/ __  /
/  __/ / / / /_/ /
\___/_/ /_/\__,_/
\033[0m'
echo "\033[35;1m* * script done * * \033[0m"
