#!/bin/bash

BACKUP_DIR="backups"
DATE=$(date +%Y%m%d)

echo "🔐 Sauvegarde des clés sealed-secrets..."

# Création du répertoire de backup à la racine du projet
mkdir -p "${BACKUP_DIR}"

# Récupération du secret
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > "${BACKUP_DIR}/sealed-secrets-key-${DATE}.yaml"

echo "✅ Backup créé dans ${BACKUP_DIR}/sealed-secrets-key-${DATE}.yaml"