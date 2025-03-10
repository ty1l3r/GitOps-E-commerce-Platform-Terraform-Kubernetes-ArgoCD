#!/bin/bash
echo "🚀 Installation Sealed Secrets"
# Installation Sealed Secrets
echo "📦 Installation..."
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
    --namespace kube-system \
    --create-namespace \
    --wait || exit 1

# Installation kubeseal
echo "🔧 Installation kubeseal..."
KUBESEAL_VERSION="0.24.4"
wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm -f kubeseal "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"

echo "✅ Installation terminée"