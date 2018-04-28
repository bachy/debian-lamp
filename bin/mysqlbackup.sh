#!/bin/sh

echo -e '\033[35m
  __  __               _   ___          _
 |  \/  |_  _ ___ __ _| | | _ ) __ _ __| |___  _ _ __ ___
 | |\/| | || (_-</ _  | | | _ \/ _  / _| / / || |  _ (_-<
 |_|  |_|\_, /__/\__, |_| |___/\__,_\__|_\_\\_,_| .__/__/
         |__/       |_|                         |_|
\033[0m'

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

# adding the script
cp "$_assets"/mysqlbackups.sh /usr/local/bin/
chmod +x /usr/local/bin/mysqlbackups.sh

# creating crontab
touch /var/spool/cron/crontabs/root
crontab -l > /tmp/mycron
echo -e "0 2 */2 * * /usr/local/bin/mysqlbackups.sh" >> /tmp/mycron
crontab /tmp/mycron
rm /tmp/mycron
