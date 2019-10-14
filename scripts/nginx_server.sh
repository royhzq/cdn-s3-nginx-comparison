#!/bin/bash
yum update -y
amazon-linux-extras install nginx1.12 -y
cat > local.conf <<- EOM
server {
    listen 80;
    server_name _;
    root /usr/share/nginx;
    location / {
    }
}
EOM
mv local.conf /etc/nginx/conf.d/local.conf
dd if=/dev/zero of=/usr/share/nginx/html/payload  bs=256KB  count=1
systemctl restart nginx
