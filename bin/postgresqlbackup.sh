#!/bin/sh

echo -e '\033[35m
  ___        _                ___  ___  _      ___          _
 | _ \___ __| |_ __ _ _ _ ___/ __|/ _ \| |    | _ ) __ _ __| |___  _ _ __
 |  _/ _ (_-<  _/ _. | ._/ -_)__ \ (_) | |__  | _ \/ _. / _| / / || | ._ \
 |_| \___/__/\__\__, |_| \___|___/\__\_\____| |___/\__,_\__|_\_\\_,_| .__/
                |___/                                               |_|
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
cp "$_assets"/pgsqlbackup.sh /usr/local/bin/
chmod +x /usr/local/bin/pgsqlbackup.sh

# configure
echo -n "Please provide the postgresql host : "
read _pg_host
sed -i "s/HOST/$_pg_host/g" /usr/local/bin/pgsqlbackup.sh

echo -n "Please provide the postgresql port : "
read _pg_port
sed -i "s/PORT/$_pg_port/g" /usr/local/bin/pgsqlbackup.sh

echo -n "Please provide the postgresql user : "
read _pg_user
sed -i "s/USER/$_pg_user/g" /usr/local/bin/pgsqlbackup.sh

echo -n "Please provide the postgresql passwd : "
read _pg_passwd
sed -i "s/PASSWD/$_pg_passwd/g" /usr/local/bin/pgsqlbackup.sh

# creating crontab
touch /var/spool/cron/crontabs/root
crontab -l > /tmp/mycron
echo "30 2 */2 * * /usr/local/bin/pgsqlbackup.sh" >> /tmp/mycron
crontab /tmp/mycron
rm /tmp/mycron
