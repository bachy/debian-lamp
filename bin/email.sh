#!/bin/sh

echo '\033[35m
    __  ______    ______
   /  |/  /   |  /  _/ /
  / /|_/ / /| |  / // /
 / /  / / ___ |_/ // /___
/_/  /_/_/  |_/___/_____/
\033[0m'
echo "\033[35;1mEnable mail sending for php \033[0m"

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

# http://www.sycha.com/lamp-setup-debian-linux-apache-mysql-php#anchor13
sleep 2
apt-get --yesinstall exim4
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
systemctl enable exim4
systemctl restart exim4

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

  cp "$_assets"/exim4_dkim.conf /etc/exim4/conf.d/main/00_local_macros
  sed -i -r "s/DOMAIN_TO_CHANGE/$domain/g" /etc/exim4/conf.d/main/00_local_macros
  sed -i -r "s/DATE_TO_CHANGE/$selector/g" /etc/exim4/conf.d/main/00_local_macros

  update-exim4.conf
  systemctl restart exim4
  echo "please create a TXT entry in your dns zone : $selector._domainkey.$domain \n"
  echo "your public key is : \n"
  cat /etc/exim4/dkim/"$domain".pem
  echo "press any key to continue."
  read continu
else
  echo 'dkim not installed'
fi
