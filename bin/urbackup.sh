#!/bin/sh


echo -e '\033[35m
  _   _     _             _                ___ _    _         _
 | | | |_ _| |__  __ _ __| |___  _ _ __   / __| |  (_)___ _ _| |_
 | |_| | '_| '_ \/ _` / _| / / || | '_ \ | (__| |__| / -_) ' \  _|
  \___/|_| |_.__/\__,_\__|_\_\\_,_| .__/  \___|____|_\___|_||_\__|
                                  |_|
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

# install urbackup client
# https://www.urbackup.org/client_debian_ubuntu_install.html
# https://blog.stephane-huc.net/systeme/debian/urbackup_client_gui
# https://urbackup.atlassian.net/wiki/spaces/US/pages/9142274/Headless+Linux+client+setup

# Install the dependencies UrBackup needs
apt install build-essential "g++" "libcrypto++-dev" libz-dev
#  libwxgtk3.0-dev

# Download the UrBackup client source files and extract them
wget -P /tmp/ https://hndl.urbackup.org/Client/latest/urbackup-client-2.2.5.tar.gz
cd /tmp
tar xzf /tmp/urbackup-client-2.2.5.tar.gz

# Build the UrBackup client and install it
cd /tmp/urbackup-client-2.2.5.0
./configure --enable-headless
make -j4
make install

# Make sure that the UrBackup client backend runs correctly
urbackupclientbackend -v info

# install and enable systemd service
cp "$_assets"/urbackup.service /etc/ststemd/system/
chmod a+x /etc/ststemd/system/urbackup.service

systemctl --system daemon-reload
systemctl start urbackup.service
systemctl enable urbackup.service
