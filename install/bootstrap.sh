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
172.16.0.101 master1.example.com  master1
172.16.0.102 master2.example.com  master2
172.16.0.103 master3.example.com  master3
172.16.0.111 worker1.example.com  worker1
172.16.0.112 worker2.example.com  worker2
172.16.0.113 worker3.example.com  worker3
172.16.0.121 lb1.example.com      lb1
172.16.0.122 lb2.example.com      lb2
EOF
