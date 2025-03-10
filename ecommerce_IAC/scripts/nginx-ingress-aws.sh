#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"
SEPARATOR="\n=====================================================\n"

echo -e "$SEPARATOR Installation de Nginx Ingress (AWS) $SEPARATOR"

echo "📦 Installation de Nginx Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace \
--set controller.service.type=LoadBalancer \
--set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"=nlb || {
    echo -e "${RED}❌ Échec de l'installation de Nginx${NC}"
    exit 1
}

# Attente que le pod soit prêt
echo "⏳ Attente que le pod Nginx soit prêt..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s || {
    echo -e "${RED}❌ Le pod Nginx n'est pas devenu prêt${NC}"
    kubectl get pods -n ingress-nginx
    exit 1
}

echo -e "${GREEN}✅ Installation de Nginx Ingress Controller réussie${NC}"