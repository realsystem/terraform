#!/bin/bash

set -ex

export WORDPRESS_DB_HOST="${db_address}:${db_port}"
export WORDPRESS_DB_PASSWORD=${db_password}
export WORDPRESS_DB_USER=${db_username}
export WORDPRESS_DB_NAME=${db_name}

export EFS_MOUNT="/mnt/efs"
export WORDPRESS_DATA="$${EFS_MOUNT}/wp"

export WEBSERVER_PORT=${server_port}

apt update
apt -y install vim git docker-compose nfs-common

mkdir -p $${WORDPRESS_DATA}
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_data}:/ $${EFS_MOUNT}

echo "${efs_data}:/ $${EFS_MOUNT}  nfs  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0" >> /etc/fstab

cd /var/local
git clone git://github.com/realsystem/wordpress.git

cd wordpress
sed -i 's/.*server_name.*/\tserver_name overlandn.com www.overlandn.com;/' nginx-conf/nginx.conf

docker-compose up -d
