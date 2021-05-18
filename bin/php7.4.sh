#!/bin/bash

echo -e "\033[35;1mInstalling PHP 7.4 \033[0m"
apt-get -y install lsb-release apt-transport-https ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt-get update
apt-get -y install php7.4 php7.4-{fpm,mysql,opcache,curl,mbstring,zip,xml,gd,imagick,apcu}

mv /etc/php/7.4/fpm/php.ini /etc/php/7.4/fpm/php.ini.back
cp "$_assets"/php7.4-fpm.ini /etc/php/7.4/fpm/php.ini

systemctl enable php7.4-fpm
systemctl start php7.4-fpm

echo -e "\033[92;1mphp7.4-fpm installed\033[O"
