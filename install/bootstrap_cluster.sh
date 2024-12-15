#!/bin/bash

echo "[TASK 1] Pull required containers"
sudo kubeadm config images pull >/dev/null

echo "[TASK 2] Initialize Kubernetes Cluster"
sudo kubeadm init --apiserver-advertise-address $(hostname -I | awk '{print $2}') --control-plane-endpoint "172.16.0.120:6443" --upload-certs --pod-network-cidr=192.168.0.0/16 >> ~/kubeinit.log 2>/dev/null

grep -A3 "kubeadm join" ~/kubeinit.log | head -n 3 > ~/join_master.sh
sed -i "s/--token/--apiserver-advertise-address \$(hostname -I | awk '{print \$2}') --token/g" ~/join_master.sh
grep -A1 "kubeadm join" ~/kubeinit.log | tail -n 2 > ~/join_worker.sh

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Deploy calico network"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml

