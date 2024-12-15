#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
sudo apt-get install -y -qq sshpass >/dev/null
sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master01:~/join_worker.sh ~/join_worker.sh >/dev/null 2>&1
sed -i 's/kubeadm/sudo kubeadm/g' ~/join_worker.sh
bash ~/join_worker.sh >/dev/null
