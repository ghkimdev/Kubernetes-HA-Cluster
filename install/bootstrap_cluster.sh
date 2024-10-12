#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address $(hostname -I | awk '{print $2}') --control-plane-endpoint "172.16.0.120:6443" --upload-certs --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

grep -A3 "kubeadm join" /root/kubeinit.log | head -n 3 > /root/join_master.sh
sed -i "s/--token/--apiserver-advertise-address \$(hostname -I | awk '{print \$2}') --token/g" /root/join_master.sh
grep -A3 "kubeadm join" /root/kubeinit.log | tail -n 2 > /root/join_worker.sh

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Deploy calico network"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "[TASK 5] Deploy MetalLB"
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system > /dev/null 2>&1

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system > /dev/null 2>&1

curl --silent https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml -o /root/metallb-native.yaml 
kubectl apply -f /root/metallb-native.yaml > /dev/null 2>&1

cat >>/root/metallb-config.yaml<<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.16.0.240-172.16.0.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-12adv
  namespace: metallb-system
EOF

kubectl apply -f /root/metallb-config.yaml > /dev/null 2>&1

echo "[TASK 5] Deploy Ingress-Nginx Controller"
curl --silent https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/baremetal/deploy.yaml -o /root/ingress-nginx.yaml
kubectl apply -f /root/ingress-nginx.yaml

echo "[TASK 6] Deploy Kubernetes Metric Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml > /dev/null 2>&1
