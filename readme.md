# Install LEMP web server and secure it on debian 10

Fail2ban, Ufw, Proftpd, Knockd, Nginx, Mariadb, php7.0-fpm, redis, vhosts, git barre repos, zabbix-agent, dotfiles and more

## how to use it
on a fresh install

All commands below are run as root user. Either log in as root user directly or log in as your normal user and then use the command ```su -``` to become root user on your server before you proceed. IMPORTANT: You must use ```su -``` and not just ```su```, otherwise your PATH variable is set wrong by Debian.

1 install git
```
apt-get install git
```

2 clone the repo
```
git clone https://figureslibres.io/gogs/bachir/debian-web-server.git
```

3 change defaut shell from dash to bash
```
dpkg-reconfigure dash
```
and answer NO to the the question

4 run the script as root
```
su
cd debian-web-server
chmod a+x install.sh
./install.sh

```


## ref
http://www.debian.org/doc/manuals/securing-debian-howto/
https://www.thefanclub.co.za/how-to/how-secure-ubuntu-1204-lts-server-part-1-basics
https://www.linode.com/docs/websites/lamp/lamp-server-on-debian-7-wheezy
https://www.evernote.com/Home.action#n=28425519-ee9f-4efc-a13b-5426f4b31a78&ses=1&sh=5&sds=5&x=git%2520deploy&
https://github.com/Mins/TuxLite
