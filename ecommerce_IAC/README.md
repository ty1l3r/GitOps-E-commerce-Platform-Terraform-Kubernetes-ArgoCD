
# Infrastructure as Code - Ecommerce

Ce dépôt contient les configurations Infrastructure as Code (IaC) pour déployer et gérer l'infrastructure d'une application e-commerce. Nous utilisons Terraform pour définir et provisionner l'infrastructure sur AWS, ainsi que plusieurs scripts pour installer et configurer les composants nécessaires sur Kubernetes.

## Structure du Dépôt

- **scripts/** : Contient des scripts bash pour installer et configurer divers composants Kubernetes.
- **terraform/** : Contient les configurations Terraform pour déployer l'infrastructure sur AWS.

## Composants Principaux

### Terraform
Terraform est utilisé pour définir et provisionner l'infrastructure. Les configurations incluent :
- **VPC** : Création d'un réseau privé virtuel pour isoler les ressources.
- **EKS** : Déploiement d'un cluster Kubernetes géré par AWS.
- **Sous-réseaux** : Configuration de sous-réseaux privés et publics.
- **NAT Gateways** : Permet aux ressources des sous-réseaux privés d'accéder à Internet.
- **S3 Buckets** : Stockage pour l'état de Terraform et les backups Velero.
- **DynamoDB** : Gestion des verrouillages d'état lors des déploiements Terraform.

### Scripts d'Installation
Les scripts bash dans le répertoire `scripts/` sont utilisés pour installer et configurer les composants suivants :
- **Helm** : Gestionnaire de packages pour Kubernetes.
- **MetalLB** : LoadBalancer pour les clusters Kubernetes.
- **Nginx Ingress** : Contrôleur Ingress pour gérer l'accès HTTP/HTTPS.
- **cert-manager** : Gestion des certificats SSL/TLS.
- **Sealed Secrets** : Gestion sécurisée des secrets Kubernetes.

## Pipeline CI/CD

Le fichier `.gitlab-ci.yml` définit les pipelines CI/CD pour automatiser le déploiement et la gestion de l'infrastructure. Les principaux stages incluent :
- **infrastructure-vm** : Configuration de la VM de développement.
- **backend-aws** : Configuration du backend AWS pour Terraform.
- **infrastructure-aws** : Déploiement de l'infrastructure AWS.
- **cleanup** : Destruction de l'infrastructure et nettoyage des ressources.

## Réinitialisation de la VM
Ajoutez les variables suivantes dans GitLab CI/CD Settings :

KUBE_CONFIG_DEV (File, Protected)
KUBE_CONFIG_STAGING (File, Protected)

## Modules Terraform
Les modules Terraform à implémenter incluent :

Helm
Prometheus & Grafana
Cert-Manager
SealedSecret
Nginx-Ingress
ArgoCD
Velero
Fluentd

## 🔄 Procédures de sauvegarde et restauration

    # Liste des backups disponibles
    aws s3 ls s3://red-project-production-tfstate-backup/

    # Création sauvegarde de sécurité
    aws s3 cp \
        s3://red-project-production-tfstate/terraform.tfstate \
        s3://red-project-production-tfstate/terraform.tfstate.pre-restore.$(date +%Y%m%d_%H%M)

    # Restauration depuis backup (remplacer YYYY-MM-DD_HH-MM par la date voulue)
    aws s3 cp \
        s3://red-project-production-tfstate-backup/YYYY-MM-DD_HH-MM/terraform.tfstate \
        s3://red-project-production-tfstate/terraform.tfstate

    # Vérification
    cd terraform
    terraform init
    terraform plan
    
## Destruction de l'Infrastructure

    terraform init
    terraform workspace select production
    terraform destroy


## Runners
    Configuré sur la VM de développement
    Choix fait pour contraintes de projet étudiant
    En production réelle : recommandé d'utiliser un runner dedié



## En cas de réinitialisation de la vm
    sudo cat /etc/rancher/k3s/k3s.yaml | grep server  # Vérifier IP
    sudo cat /etc/rancher/k3s/k3s.yaml | base64 -w 0  # Pour GitLab
    Settings > CI/CD > Variables
    Ajouter:
    KUBE_CONFIG_DEV (File, Protected)
    KUBE_CONFIG_STAGING (File, Protected)
    Coller sortie base64

## Commande pour copier correctement le BASE64 du Kubeconfig:
    cat << 'EOF' > /tmp/get-kubeconfig.sh
    #!/bin/bash
    sudo cat /etc/rancher/k3s/k3s.yaml | base64 -w 0
    EOF

    chmod +x /tmp/get-kubeconfig.sh
    /tmp/get-kubeconfig.sh > /tmp/kubeconfig.base64
    cat /tmp/kubeconfig.base64

# 1. Destroy
terraform init
terraform workspace select production
terraform destroy