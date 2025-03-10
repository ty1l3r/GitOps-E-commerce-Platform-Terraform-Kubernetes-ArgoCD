#!/bin/bash

REMOTE_HOST="YOUT_IP_ADDRESS"
DESIRED_VERSION="v1.27.4+k3s1"

echo "🚀 Installation K3s"

# Installation K3s
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$DESIRED_VERSION sh -s - \
    --write-kubeconfig-mode 640 \
    --disable traefik \
    --disable servicelb \
    --disable metrics-server

# Configuration permissions
echo "🔐 Configuration permissions..."
sudo groupadd -f k3susers
sudo usermod -aG k3susers ubuntu
sudo usermod -aG k3susers gitlab-runner
sudo chown root:k3susers /etc/rancher/k3s/k3s.yaml
sudo chmod 640 /etc/rancher/k3s/k3s.yaml

# Configuration IP
echo "🌐 Configuration IP..."
sudo sed -i "s|127.0.0.1|$REMOTE_HOST|" /etc/rancher/k3s/k3s.yaml

echo "⚠️ COPIER LE KUBECONFIG:"
sudo cat /etc/rancher/k3s/k3s.yaml | base64 -w 0