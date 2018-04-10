# Install web server and secure it on debian 9

Fail2ban, Ufw, Proftpd, Knockd, Nginx, Mariadb, php7.0-fpm, redis, vhosts, git barre repos, zabbix-agent, dotfiles and more

## how to use it
on a fresh install
as root

1 install git
```
apt-get install git
```

2 clone the repo
```
git clone https://github.com/bachy/debian-web-server.git
```

3 run the script as root
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
