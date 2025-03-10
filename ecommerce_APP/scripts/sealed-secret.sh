#!/bin/bash

create_secrets() {
    local namespace=$1
    local env=$2

    # Définition des variables selon l'environnement
    if [ "$env" == "production" ]; then
        local db_user=${DB_USER_PROD}
        local db_password=${DB_PASSWORD_PROD}
        local rabbit_user=${RABBIT_USER}
        local rabbit_password=${RABBIT_PASSWORD}
        local app_secret=${APP_SECRET_PROD}
        local rabbit_erlang_cookie=${RABBIT_ERLANG_COOKIE}
    else
        local db_user=${DB_USER}
        local db_password=${DB_PASSWORD}
        local rabbit_user=${RABBIT_USER}
        local rabbit_password=${RABBIT_PASSWORD}
        local app_secret=${APP_SECRET}
        local rabbit_erlang_cookie=${RABBIT_ERLANG_COOKIE}
    fi

    echo "🔑 Création des secrets pour ${env}..."

    # Application secrets
    cat << EOF > /tmp/raw-secrets-${env}.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ${env}-secrets
  namespace: ${namespace}
  labels:
    environment: ${env}
type: Opaque
data:
  # RabbitMQ
  RABBITMQ_USER: ${rabbit_user}
  RABBITMQ_PASSWORD: ${rabbit_password}
  RABBITMQ_ERLANG_COOKIE: ${rabbit_erlang_cookie}
  # Database
  DB_USER: ${db_user}
  DB_PASSWORD: ${db_password}
  # Application
  APP_SECRET: ${app_secret}
EOF

    # Registry secret
    cat << EOF > /tmp/registry-secret-${env}.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-registry-secret
  namespace: ${namespace}
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $(echo -n "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\",\"auth\":\"$(echo -n "$CI_REGISTRY_USER:$CI_REGISTRY_PASSWORD" | base64)\"}}}" | base64 -w 0)
EOF

    echo "🔒 Chiffrement des secrets..."
    kubeseal --format=yaml \
        --controller-name=sealed-secrets \
        --controller-namespace=kube-system \
        --scope cluster-wide \
        < /tmp/raw-secrets-${env}.yaml > /tmp/sealed-secrets-${env}.yaml

    kubeseal --format=yaml \
        --controller-name=sealed-secrets \
        --controller-namespace=kube-system \
        --scope cluster-wide \
        < /tmp/registry-secret-${env}.yaml > /tmp/sealed-registry-${env}.yaml

    echo "📦 Application des secrets..."
    kubectl apply -f /tmp/sealed-secrets-${env}.yaml
    kubectl apply -f /tmp/sealed-registry-${env}.yaml

    rm -f /tmp/raw-secrets-${env}.yaml /tmp/sealed-secrets-${env}.yaml
    rm -f /tmp/registry-secret-${env}.yaml /tmp/sealed-registry-${env}.yaml
}

# Main
echo "🚀 Création des secrets..."
create_secrets "${NAMESPACE_DEV}" "dev"
create_secrets "${NAMESPACE_STAGING}" "staging"
create_secrets "${NAMESPACE_PRODUCTION}" "production"
echo "✅ Configuration terminée"