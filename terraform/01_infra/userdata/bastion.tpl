#!/bin/bash

apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get install docker-ce=17.06.0~ce-0~ubuntu -y

cat << EOF > /etc/systemd/system/vpn.service
[Unit]
Description=Libreswan Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop %n
ExecStartPre=-/usr/bin/docker rm %n
ExecStartPre=/usr/bin/docker pull hwdsl2/ipsec-vpn-server
ExecStart=/usr/bin/docker run --rm -e VPN_IPSEC_PSK=${vpn_psk} -e VPN_PASSWORD=${vpn_password} -e VPN_USER=${vpn_user} --name %n --net host --privileged hwdsl2/ipsec-vpn-server

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vpn
systemctl start vpn
