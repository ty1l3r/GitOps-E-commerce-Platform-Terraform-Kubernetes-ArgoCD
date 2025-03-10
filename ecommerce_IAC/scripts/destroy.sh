#!/bin/bash
set -e

echo "🔧 Installation des outils nécessaires..."
apt-get update && apt-get install -y curl
curl -LO "https://dl.k8s.io/release/v1.26.0/bin/linux/amd64/kubectl"
chmod +x kubectl && mv kubectl /usr/local/bin/
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Remplacer la ligne problématique par :
echo "🔄 Configuration kubectl..."
CLUSTER_NAME="red-project-production"  # Nom fixe du cluster
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${AWS_DEFAULT_REGION}"
echo "🧹 Démarrage du nettoyage préliminaire pour destruction Terraform..."

# Vérifier la connexion à Kubernetes
if ! kubectl cluster-info &>/dev/null; then
  echo "⚠️ Impossible de se connecter au cluster. Vérifiez vos identifiants AWS et le nom du cluster."
  exit 1
fi

echo "🧹 Nettoyage des CRDs ArgoCD..."
kubectl patch crd applications.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl patch crd applicationsets.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl patch crd appprojects.argoproj.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl delete crd applications.argoproj.io --force --grace-period=0 || true
kubectl delete crd applicationsets.argoproj.io --force --grace-period=0 || true
kubectl delete crd appprojects.argoproj.io --force --grace-period=0 || true

echo "🧹 Nettoyage des CRDs cert-manager..."
kubectl patch crd certificates.cert-manager.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl patch crd issuers.cert-manager.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl patch crd clusterissuers.cert-manager.io -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl delete crd certificates.cert-manager.io --force --grace-period=0 || true
kubectl delete crd issuers.cert-manager.io --force --grace-period=0 || true
kubectl delete crd clusterissuers.cert-manager.io --force --grace-period=0 || true

echo "🧹 Nettoyage des webhooks..."
kubectl delete validatingwebhookconfiguration cert-manager-webhook --force --grace-period=0 || true
kubectl delete mutatingwebhookconfiguration cert-manager-webhook --force --grace-period=0 || true

echo "🧹 Nettoyage d'urgence des namespaces problématiques..."
kubectl patch namespace argocd -p '{"metadata":{"finalizers":[]}}' --type=merge || true
kubectl patch namespace cert-manager -p '{"metadata":{"finalizers":[]}}' --type=merge || true

echo "🧹 Désinstallation forcée des releases Helm problématiques..."
helm uninstall argocd -n argocd || true
helm uninstall cert-manager -n cert-manager || true
helm uninstall prometheus -n monitoring || true

echo "⏳ Pause pour permettre aux changements de se propager..."
sleep 30

echo "✅ Nettoyage préliminaire terminé"