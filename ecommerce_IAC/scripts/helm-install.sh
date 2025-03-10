#!/bin/bash
echo "🚀 Installation de Helm"
# Vérification et installation de Helm
if ! command -v helm >/dev/null 2>&1; then
    echo "📦 Installation de Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh
else
    HELM_VERSION=$(helm version --short | cut -d'v' -f2)
    MIN_VERSION='3.12.0'
    if [[ $(echo -e "$HELM_VERSION\n$MIN_VERSION" | sort -V | head -n1) != $MIN_VERSION ]]; then
        echo "🔄 Mise à jour de Helm..."
        curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
        chmod 700 get_helm.sh && \
        ./get_helm.sh && \
        rm -f get_helm.sh
    else
        echo "✅ Helm v$HELM_VERSION est déjà installé et à jour"
    fi
fi
# Vérification finale
command -v helm || {
    echo "❌ Échec de la vérification de Helm"
    exit 1
}
echo "✅ Installation de Helm réussie"