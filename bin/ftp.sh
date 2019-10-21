#!/bin/sh


echo -e '\033[35m
  ______ _______ _____
 |  ____|__   __|  __ \
 | |__     | |  | |__) |
 |  __|    | |  |  ___/
 | |       | |  | |
 |_|       |_|  |_|
\033[0m'

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
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

echo "installing proftpd"
apt-get --yes install proftpd
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
cp "$_assets"/proftpd.conf /etc/proftpd/conf.d/"$_server_name".conf
sed -i -r "s/example/$_server_name/g" /etc/proftpd/conf.d/"$_server_name".conf

ufw allow ftp

addgroup ftpuser

systemctl enable proftpd
systemctl restart proftpd

echo "ftp installtion done"
echo "to permit to a user to connect through ftp, add him to the ftpuser group by running : usermod -a -G ftpuser USERNAME"
echo "FTP users are jailed on their home by default"


# TODO : allow ssh/ftp connection only from given ips
