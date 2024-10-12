#!/bin/bash

# Disable swap
echo "[TASK 3] Disable and turn off SWAP"
swapoff -a
sed -i '/swap/d' /etc/fstab

# Add sysctl settings
echo "[TASK 4] Add sysctl settings"

cat >> /etc/sysctl.d/k8s.conf<<EOF
net.ipv4.ip_forward                 = 1
EOF

sysctl --system > /dev/null

# Install containerd from Docker-ce repository
echo "[TASK 5] Install containerd runtime"
apt-get -qq update
apt-get -y -qq install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -qq update
apt-get install -y -qq containerd.io

containerd config default > /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd >/dev/null 2>&1
systemctl enable containerd >/dev/null 2>&1

echo "[TASK 6] Add yum repo file for kubernetes"
# apt-transport-https may be a dummy package; if so, you can skip that package
apt-get install -y -qq apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

## Install Kubernetes
echo "[TASK 7] Install Kubernetes (kubeadm, kubelet and kubectl)"
apt-get install -y -qq kubelet kubeadm kubectl
systemctl enable --now kubelet > dev/null

# Set kubectl Auto Complete
echo "[TASK 8] Set kubectl auto complete"
echo 'source <(kubectl completion bash)' >> /etc/bashrc
echo 'alias k=kubectl' >> /etc/bashrc
echo 'complete -o default -F __start_kubectl k' >> /etc/bashrc
exec bash

