#!/bin/bash

echo "🚀 Installation de MetalLB"

# Vérification et suppression Traefik si présent
if kubectl -n kube-system get helmcharts.helm.cattle.io traefik &>/dev/null; then
    echo "🗑️ Suppression de Traefik nécessaire..."
    kubectl -n kube-system delete helmcharts.helm.cattle.io traefik-crd 2>/dev/null || true
    kubectl -n kube-system delete helmcharts.helm.cattle.io traefik 2>/dev/null || true
    kubectl -n kube-system delete service traefik 2>/dev/null || true
    kubectl -n kube-system delete deployment traefik 2>/dev/null || true
    sleep 20
else
    echo "✅ Traefik déjà supprimé"
fi

# Installation MetalLB
echo "📦 Installation de MetalLB..."
helm repo add metallb https://metallb.github.io/metallb --force-update
helm repo update
helm upgrade --install metallb metallb/metallb \
    --namespace metallb-system \
    --create-namespace \
    --wait || exit 1

echo "⚙️ Configuration de MetalLB..."
cat <<'EOF' | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - YOURIP/32
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

# Vérification finale
echo "⏳ Attente des pods MetalLB..."
kubectl wait --namespace metallb-system \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=90s || exit 1

if kubectl get pods -n metallb-system -l app.kubernetes.io/component=controller | grep -q Running; then
    echo "✅ MetalLB installé et fonctionnel"
else
    echo "❌ Échec de l'installation MetalLB"
    kubectl get pods -n metallb-system
    exit 1
fi

echo "✅ Installation de MetalLB terminée"