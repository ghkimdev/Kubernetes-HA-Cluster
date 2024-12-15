#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
sudo apt-get install -y -qq sshpass >/dev/null
sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no master01:~/join_master.sh ~/join_master.sh >/dev/null 2>&1
sed -i 's/kubeadm/sudo kubeadm/g' ~/join_master.sh
bash ~/join_master.sh >/dev/null 2>&1

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

