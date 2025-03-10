#!/bin/bash
echo "Debug variables:"
echo "GITLAB_REGISTRY_USER: ${GITLAB_REGISTRY_USER:-non défini}"
echo "GITLAB_REGISTRY_TOKEN: ${GITLAB_REGISTRY_TOKEN:-non défini}"

create_secrets() {
    local namespace="production"

    echo "🔍 Recherche du secret actif..."
    local secret_name=$(kubectl get secrets -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o jsonpath='{.items[0].metadata.name}')
    if [ -z "$secret_name" ]; then
        echo "❌ Aucun secret actif trouvé"
        exit 1
    fi
    echo "✅ Secret trouvé: ${secret_name}"

    echo "🔑 Récupération du certificat..."
    local CERT=$(kubectl get secret ${secret_name} -n kube-system -o jsonpath='{.data.tls\.crt}')
    if [ -z "$CERT" ]; then
        echo "❌ Certificat non trouvé"
        exit 1
    fi

    echo "📝 Création des secrets applicatifs..."
    cat << EOF > /tmp/raw-secrets-prod.yaml
apiVersion: v1
kind: Secret
metadata:
  name: production-secrets
  namespace: ${namespace}
type: Opaque
stringData:
  RABBITMQ_USER: "${RABBIT_USER}"
  RABBITMQ_PASSWORD: "${RABBIT_PASSWORD}"
  RABBITMQ_ERLANG_COOKIE: "${RABBIT_ERLANG_COOKIE}"
  DB_USER: "${DB_USER_PROD}"
  DB_PASSWORD: "${DB_PASSWORD_PROD}"
  APP_SECRET: "${APP_SECRET_PROD}"
EOF

    echo "📝 Création du secret Docker Registry..."
    cat << EOF > /tmp/raw-registry-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-registry-secret
  namespace: ${namespace}
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: |
    {
      "auths": {
        "registry.gitlab.com": {
          "username": "gitlab-ci-token",
          "password": "${GITLAB_REGISTRY_TOKEN}",
          "email": "wonderteamdevops@gmail.com",
          "auth": "$(echo -n "${GITLAB_REGISTRY_USER}:${GITLAB_REGISTRY_TOKEN}" | base64)"
        }
      }
    }
EOF

    echo "🔒 Chiffrement des secrets..."
    kubeseal --format=yaml \
        --cert <(echo "$CERT" | base64 -d) \
        --scope cluster-wide \
        < /tmp/raw-secrets-prod.yaml > /tmp/sealed-secrets-prod.yaml

    kubeseal --format=yaml \
        --cert <(echo "$CERT" | base64 -d) \
        --scope cluster-wide \
        < /tmp/raw-registry-secret.yaml > /tmp/sealed-registry-secret.yaml

    echo "📦 Application des secrets..."
    kubectl apply -f /tmp/sealed-secrets-prod.yaml
    kubectl apply -f /tmp/sealed-registry-secret.yaml

    echo "🧹 Nettoyage des fichiers temporaires..."
    rm -f /tmp/raw-secrets-prod.yaml /tmp/raw-registry-secret.yaml
    rm -f /tmp/sealed-secrets-prod.yaml /tmp/sealed-registry-secret.yaml
}

echo "🚀 Démarrage de la création des secrets..."
create_secrets || {
    echo "❌ Erreur lors de la création des secrets"
    exit 1
}