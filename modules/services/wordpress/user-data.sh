#!/bin/bash

set -ex

apt update
apt -y install vim git docker-compose nfs-common

mkdir -p /mnt/efs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_data}:/ /mnt/efs
mkdir -p /mnt/efs/db
mkdir -p /mnt/efs/wp

echo "${efs_data}:/ /mnt/efs  nfs  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0" >> /etc/fstab

cat << EOF >> docker-compose.yaml
version: '3.3'
services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${wp_db_passwd}
      MYSQL_DATABASE: ${wp_db_name}
      MYSQL_USER: ${wp_db_user}
      MYSQL_PASSWORD: ${wp_db_user_passwd}

  wordpress:
    depends_on:
      - db
    image: wordpress:latest
    volumes:
      - wp_data:/var/www/html
    ports:
      - "${server_port}:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${wp_db_user}
      WORDPRESS_DB_PASSWORD: ${wp_db_passwd}
      WORDPRESS_DB_NAME: ${wp_db_name}
volumes:
  db_data:
    driver_opts:
      type: none
      device: /mnt/efs/db
      o: bind
  wp_data:
    driver_opts:
      type: none
      device: /mnt/efs/wp
      o: bind
EOF
docker-compose up -d
