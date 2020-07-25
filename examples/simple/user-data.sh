#!/bin/bash

set -ex

apt update
apt -y install vim git docker-compose

mkdir -p /mnt/efs
mkdir -p /mnt/efs/wp
cd /var/local
git clone git://github.com/realsystem/wordpress.git
cd wordpress
sed -i 's/.*server_name.*/\tserver_name overlandn.com www.overlandn.com;/' nginx-conf/nginx.conf
docker-compose up -d
