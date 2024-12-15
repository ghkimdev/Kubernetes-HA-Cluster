#!/bin/bash

# Disable swap
echo "[TASK 1] Disable and turn off SWAP"
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Add sysctl settings
echo "[TASK 2] Add sysctl settings"

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system > /dev/null

# Install containerd from Docker-ce repository
echo "[TASK 3] Install containerd runtime"
sudo apt-get -qq update
sudo apt-get -y -qq install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -qq update
sudo apt-get install -y -qq containerd.io

containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd >/dev/null 2>&1
sudo systemctl enable containerd >/dev/null 2>&1

echo "[TASK 4] Add yum repo file for kubernetes"
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y -qq apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Install Kubernetes
echo "[TASK 5] Install Kubernetes (kubeadm, kubelet and kubectl)"
sudo apt-get update -qq
sudo apt-get install -y -qq kubelet kubeadm kubectl
sudo systemctl enable --now kubelet > /dev/null

# Set kubectl Auto Complete
echo "[TASK 6] Set kubectl auto complete"
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
exec bash

