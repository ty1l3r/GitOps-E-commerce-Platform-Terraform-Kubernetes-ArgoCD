#!/bin/bash

echo "🚀 Installation et vérification du ClusterIssuer..."

# Création du ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-euphoni
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: wonderteamdevops@gmail.com
    privateKeySecretRef:
      name: letsencrypt-euphoni
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# Vérification que le ClusterIssuer est prêt
echo "🔍 Vérification du statut..."
for i in {1..6}; do
  ISSUER_READY=$(kubectl get clusterissuer letsencrypt-euphoni -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  if [ "$ISSUER_READY" == "True" ]; then
    echo "✅ ClusterIssuer prêt!"
    exit 0
  fi
  echo "⏳ Attente... ($i/6)"
  sleep 30
done

echo "❌ Timeout: ClusterIssuer non prêt"
exit 1