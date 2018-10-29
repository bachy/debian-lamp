#!/bin/sh


echo -e '\033[35m
 _____         __    __    _
/__  /  ____ _/ /_  / /_  (_)  __
  / /  / __ `/ __ \/ __ \/ / |/_/
 / /__/ /_/ / /_/ / /_/ / />  <
/____/\__,_/_.___/_.___/_/_/|_|
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

wget -P /tmp/ http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
dpkg -i /tmp/zabbix-release_3.4-1+stretch_all.deb

apt-get update -y

apt-get install zabbix-agent -y

# configure
echo -n "Please provide the zabbix-server's ip : "
read _ip
echo -n "Please provide the hostname of this agent : "
read _host_name
echo -n "Please provide the mysql root password : "
read _root_mysql_passwd

_agent_conf_d="/etc/zabbix/zabbix_agentd.d" # for debian 8
if [ ! -d "$_agent_conf_d" ]; then
  _agent_conf_d="/etc/zabbix/zabbix_agentd.conf.d" # for debian 9
fi

# configure zabbix agent
sed -i "s#Server=127.0.0.1#Server=$_ip#g" /etc/zabbix/zabbix_agentd.conf
sed -i "s#ServerActive=127.0.0.1#ServerActive=$_ip#g" /etc/zabbix/zabbix_agentd.conf
sed -i "s#Hostname=Zabbix server#Hostname=$_host_name#g" /etc/zabbix/zabbix_agentd.conf

# APT
# check for debian security updates
# not working : https://www.osso.nl/blog/zabbix-counting-security-updates
# https://github.com/theranger/zabbix-apt
# enable automatic update of apt
cp "$_assets"/zabbix/misc/02periodic /etc/apt/apt.conf.d/
cp "$_assets"/zabbix/apt.conf "$_agent_conf_d"/

# MYSQL
# https://serverfault.com/questions/737018/zabbix-user-parameter-mysql-status-setting-home
# create zabbix user home
mkdir /var/lib/zabbix
# generate random password for zabbix mysql user
_passwd="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12)"
# add mysql credentials to zabbix home
printf "[client]\n
user=zabbix\n
password=$_passwd" > /var/lib/zabbix/.my.cnf
# create zabbix mysql user
mysql -uroot -p"$_root_mysql_passwd" -e "CREATE USER 'zabbix' IDENTIFIED BY '$_passwd';"
mysql -uroot -p"$_root_mysql_passwd" -e "GRANT USAGE ON *.* TO 'zabbix'@'localhost' IDENTIFIED BY '$_passwd';"
# add zabbix-agent parameter
cp "$_assets"/zabbix/userparameter_mysql.conf "$_agent_conf_d"/

# NGINX
# https://github.com/sfuerte/zbx-nginx
# nginxconf already included in default.nginxconf asset
sed -i "s/# allow ZABBIX-SERVER-IP/allow $_ip/g" /etc/nginx/sites-available/default
cp "$_assets"/zabbix/userparameter_nginx.conf "$_agent_conf_d"/
mkdir /etc/zabbix/zabbix_agentd.scripts
cp "$_assets"/zabbix/scripts/nginx-stat.py /etc/zabbix/zabbix_agentd.scripts/
chmod +x /etc/zabbix/zabbix_agentd.scripts/nginx-stat.py

echo -n "This is box is a proxmox CT? [Y|n] "
read yn
yn=${yn:-y}
if [ "$yn" = "Y" ] || [ "$yn" = "y" ]; then
  cp "$_assets"/zabbix/proxmox-ct.conf "$_agent_conf_d"/
fi

# TODO add modules path to agent ??

# allow comm. port with zabbix-server
ufw allow from "$_ip" to any port 10050
ufw allow from "$_ip" to any port 22
# ufw allow from "$_ip" to any port 10051
# iptables -A INPUT -p tcp -m tcp --dport 10050 -j ACCEPT

systemctl restart zabbix-agent
systemctl enable zabbix-agent

echo -e "\033[92;1mZabbix-agent installed and configured, please add the host $_host_name in your zabbix-server \033[Om"
echo -e "\033[92;1mAnd import requested templates in assets/zabbix/templates/ \033[Om"
echo -e "\033[92;1mzabbix user mysql password is $_passwd \033[Om"
