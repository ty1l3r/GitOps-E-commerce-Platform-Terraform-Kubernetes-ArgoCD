#!/bin/bash

echo "🚀 Installation de cert-manager"

# Installation cert-manager
echo "📦 Ajout repo Helm..."
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

echo "⚙️ Installation cert-manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.13.3 \
    --set installCRDs=true \
    --wait \
    --timeout 3m

if [ $? -eq 0 ]; then
    echo "✅ Installation complète"
else
    echo "❌ Échec de l'installation"
    exit 1
fi