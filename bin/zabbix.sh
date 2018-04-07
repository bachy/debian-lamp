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


wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
dpkg -i zabbix-release_3.0-2+stretch_all.deb

apt-get update -y

apt-get install zabbix-agent -y

# configure
echo -n "Please provide the zabbix-server's ip : "
read _ip
echo -n "Please provide the hostname of this agent : "
read _host_name

sed -i 's#Server=127.0.0.1#Server=$_ip#g' /etc/zabbix/zabbix-agent.confd
sed -i 's#Hostname=Zabbix server#Hostname=$_host_name#g'

systemctl restart zabbix-agent
systemctl enable zabbix-agent

echo -e "\033[92;1mZabbix-agent installed and configured, please add the host in your zabbix-server \033[Om"
