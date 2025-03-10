#!/bin/bash

# Configuration
BACKUP_DIR="$HOME/sealed-secrets-backups/production"
DATE=$(date +%Y%m%d)
NAMESPACE="production"

echo "🔐 Sauvegarde locale des secrets de production..."

# Création de la structure des dossiers
mkdir -p "${BACKUP_DIR}"

# Export des secrets existants
echo "📦 Export des secrets..."
if kubectl get sealedsecrets -n ${NAMESPACE} &>/dev/null; then
    kubectl get sealedsecrets -n ${NAMESPACE} -o yaml > "${BACKUP_DIR}/sealed-secrets-${DATE}.yaml"
    echo "  ✅ Secrets sauvegardés dans: ${BACKUP_DIR}/sealed-secrets-${DATE}.yaml"
else
    echo "  ⚠️ Aucun sealed secret trouvé dans le namespace ${NAMESPACE}"
fi

# Export de la clé de chiffrement
echo "🔑 Export de la clé maître..."
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > "${BACKUP_DIR}/sealed-secrets-key-${DATE}.yaml"
echo "  ✅ Clé sauvegardée dans: ${BACKUP_DIR}/sealed-secrets-key-${DATE}.yaml"

# Création d'une archive
echo "📚 Création de l'archive..."
cd "${BACKUP_DIR}/.."
tar -czf "production-secrets-backup-${DATE}.tar.gz" "production"

echo "✨ Backup terminé!"
echo "📍 Localisation des backups:"
echo "  - Dossier: ${BACKUP_DIR}"
echo "  - Archive: ${BACKUP_DIR}/../production-secrets-backup-${DATE}.tar.gz"