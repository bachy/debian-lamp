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
echo "\033[35;1mThis script has been tested only on Linux Debian 10 \033[0m"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo -n "Should we start? [Y|n] "
read yn
yn=${yn:-y}
if [ "$yn" != "y" ]; then
  echo "aborting script!"
  exit
fi

# get the current position
_cwd="$(pwd)"

. bin/upgrade.sh
. bin/misc.sh
. bin/firewall.sh
. bin/fail2ban.sh
. bin/knockd.sh
. bin/user.sh
. bin/email.sh

while [ "$securssh" != "yes" ] && [ "$securssh" != "no" ]
do
echo -n "Securing ssh (disabling root login)? [yes|no] "
read securssh
# securssh=${securssh:-y}
done
if [ "$securssh" = "yes" ]; then
  . bin/ssh.sh
else
  echo 'root user can still conect through ssh'
fi


echo -n "Should we install ftp server? [Y|n] "
read yn
yn=${yn:-y}
if [ "$yn" = "y" ]; then
  . bin/ftp.sh
else
  echo 'ftp server not installed'
fi

while [ "$lemp" != "yes" ] && [ "$lemp" != "no" ]
do
  echo -n "Should we install lemp ? [yes|no] "
  read lemp
done
if [ "$lemp" = "yes" ]; then
  . bin/lemp.sh
else
  echo 'lemp server not installed'
fi

while [ "$_install_vhost" != "yes" ] && [ "$_install_vhost" != "no" ]
do
  echo -n "Should we install a vhost ? [yes|no] "
  read _install_vhost
done
if [ "$_install_vhost" = "yes" ]; then
  . bin/vhost.sh
else
  echo 'no vhost installed'
fi

while [ "$_install_zabbix_agent" != "yes" ] && [ "$_install_zabbix_agent" != "no" ]
do
  echo -n "Should we install zabbix-agent ? [yes|no] "
  read _install_zabbix_agent
done
if [ "$_install_zabbix_agent" = "yes" ]; then
  . bin/zabbix.sh
else
  echo 'zabbix-agent not installed'
fi

while [ "$_install_urbackup" != "yes" ] && [ "$_install_urbackup" != "no" ]
do
  echo -n "Should we install urbackup client ? [yes|no] "
  read _install_urbackup
done
if [ "$_install_urbackup" = "yes" ]; then
  . bin/urbackup.sh
else
  echo 'urbackup client not installed'
fi


. bin/dotfiles.sh
# . bin/autoupdate.sh

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

#   echo "\033[35;1m /tmp and /var/tmp secured using tmpfs. \033[0m"
# } # End function secure_tmp_tmpfs

# check_tmp_secured
# if [ $? = 0  ]; then
#     secure_tmp_tmpfs
# else
#     echo "\033[35;1mFunction canceled. /tmp already secured. \033[0m"
# fi

# TODO add warning message on ssh connection if system needs updates

# TODO install and configure tmux



echo '\033[35m
                  __
  ___  ____  ____/ /
 / _ \/ __ \/ __  /
/  __/ / / / /_/ /
\___/_/ /_/\__,_/
\033[0m'
echo "\033[35;1m* * script done * * \033[0m"
