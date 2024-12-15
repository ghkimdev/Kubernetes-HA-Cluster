#!/bin/bash

# Enable ssh password authentication
echo "Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "Set root password"
echo -e "admin\nadmin" | passwd root >/dev/null 2>&1

# Set Hosts file
cat <<EOF | tee -a /etc/hosts
172.16.0.101 master01.example.com  master01
172.16.0.102 master02.example.com  master02
172.16.0.103 master03.example.com  master03
172.16.0.111 worker01.example.com  worker01
172.16.0.112 worker02.example.com  worker02
172.16.0.113 worker03.example.com  worker03
172.16.0.114 worker04.example.com  worker04
172.16.0.121 lb01.example.com      lb01
172.16.0.122 lb02.example.com      lb02
EOF

chown -R vagrant:vagrant /opt
