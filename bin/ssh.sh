#!/bin/sh


echo -e '\033[35m
   __________ __  __
  / ___/ ___// / / /
  \__ \\__ \/ /_/ /
 ___/ /__/ / __  /
/____/____/_/ /_/
\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

sed -i 's/PermitRootLogin\ yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/PermitEmptyPasswords\ yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
sed -i 's/Protocol\ [0-9]/Protocol 2/g' /etc/ssh/sshd_config
systemctl reload ssh
echo -e "\033[92;1mSSH secured\033[Om"
