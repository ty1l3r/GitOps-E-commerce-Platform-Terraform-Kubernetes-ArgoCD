#!/bin/bash

#------------------------------------------------------------------
# CONFIGURATION
#------------------------------------------------------------------
MAX_RETRIES=10
RETRY_INTERVAL=10
KUBESEAL_VERSION="0.24.4"
NAMESPACE="kube-system"
CONTROLLER_NAME="sealed-secrets-controller"

#------------------------------------------------------------------
# FONCTIONS DE VÉRIFICATION
#------------------------------------------------------------------
verify_deployment() {
    echo "⏳ Vérification du déploiement..."

    if ! kubectl rollout status deployment/${CONTROLLER_NAME} -n ${NAMESPACE} --timeout=180s; then
        echo "❌ Échec du déploiement"
        return 1
    fi
    if ! kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=sealed-secrets -n ${NAMESPACE} --timeout=180s; then
        echo "❌ Pod non prêt après 3 minutes"
        return 1
    fi
    echo "✅ Déploiement vérifié"
    return 0
}

#------------------------------------------------------------------
# INSTALLATION
#------------------------------------------------------------------
install_controller() {
    echo "🔄 INSTALLATION DU CONTROLLER"
    echo "============================"
    echo "📦 Configuration Helm..."
    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
    helm repo update

    echo "🚀 Installation du controller..."
    helm upgrade --install sealed-secrets sealed-secrets/sealed-secrets \
        --namespace ${NAMESPACE} \
        --set fullnameOverride=${CONTROLLER_NAME} \
        --set controller.create=true \
        --set controller.generateKey=true \
        --wait
    verify_deployment || return 1
    echo "✅ Controller installé"
    echo "⏳ Attente de 30 secondes pour la génération du secret..."
    sleep 30
    return 0
}

install_kubeseal() {
    echo "🔧 INSTALLATION DE KUBESEAL"
    echo "=========================="
    echo "📥 Téléchargement..."
    wget -q "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"

    echo "📦 Installation..."
    tar -xzf "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" kubeseal
    install -m 755 kubeseal /usr/local/bin/kubeseal
    rm -f kubeseal "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
    if ! command -v kubeseal &>/dev/null; then
        echo "❌ Installation échouée"
        return 1
    fi
    kubeseal --version
    echo "✅ Kubeseal installé"
    return 0
}

#------------------------------------------------------------------
# TEST DE CHIFFREMENT
#------------------------------------------------------------------
test_encryption() {
    echo "🔑 Test du chiffrement..."
    local retry_count=0

    while [ $retry_count -lt $MAX_RETRIES ]; do
        echo "⏳ Tentative $((retry_count + 1))/$MAX_RETRIES..."

        # Recherche du secret avec un pattern
        local SECRET_NAME=$(kubectl get secrets -n ${NAMESPACE} -l sealedsecrets.bitnami.com/sealed-secrets-key=active -o jsonpath='{.items[0].metadata.name}')

        if [ -z "$SECRET_NAME" ]; then
            echo "⚠️ Secret actif non trouvé, nouvelle tentative..."
            ((retry_count++))
            sleep $RETRY_INTERVAL
            continue
        fi

        # Récupération du certificat avec le nom trouvé
        local CERT=$(kubectl get secret ${SECRET_NAME} -n ${NAMESPACE} -o jsonpath='{.data.tls\.crt}')
        if [ -z "$CERT" ]; then
            echo "⚠️ Certificat non trouvé dans le secret ${SECRET_NAME}, nouvelle tentative..."
            ((retry_count++))
            sleep $RETRY_INTERVAL
            continue
        fi

        # Test de chiffrement
        if echo "test" | kubeseal --raw --scope cluster-wide --cert <(echo $CERT | base64 -d) >/dev/null 2>&1; then
            echo "✅ Test de chiffrement réussi avec le secret ${SECRET_NAME}"
            return 0
        fi

        echo "⚠️ Échec du chiffrement, nouvelle tentative..."
        ((retry_count++))
        sleep $RETRY_INTERVAL
    done

    echo "❌ Échec du test de chiffrement après $MAX_RETRIES tentatives"
    return 1
}

#------------------------------------------------------------------
# PROGRAMME PRINCIPAL
#------------------------------------------------------------------
main() {
    echo "🚀 DÉMARRAGE DE L'INSTALLATION"
    echo "============================="

    install_controller || {
        echo "❌ Échec de l'installation du controller"
        exit 1
    }

    install_kubeseal || {
        echo "❌ Échec de l'installation de kubeseal"
        exit 1
    }

    test_encryption || {
        echo "❌ Échec de la vérification du chiffrement"
        exit 1
    }

    echo "✅ INSTALLATION TERMINÉE AVEC SUCCÈS"
    echo "=================================="
}

# Exécution
main