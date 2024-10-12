#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
apt-get install -y -qq sshpass >/dev/null
sshpass -p "admin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master1:/root/join_master.sh /root/join_master.sh >/dev/null 2>&1
bash /root/join_master.sh >/dev/null 2>&1
