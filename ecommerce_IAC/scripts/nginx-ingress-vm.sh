#!/bin/bash

echo "🚀 Installation de Nginx Ingress"

echo "📦 Installation de Nginx Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update && \
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace \
--set controller.service.type=LoadBalancer \
--set controller.service.externalTrafficPolicy=Local \
--set controller.allowSnippetAnnotations=true \
--set controller.enableAnnotationSnippets=true || exit 1

# Vérification IP
echo "⏳ Attente attribution IP..."
for i in $(seq 1 12); do
    echo "📊 Vérification IP (tentative $i/12)"
    IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ "$IP" = "85.215.217.45" ]; then
        echo "✅ IP $IP attribuée"
        exit 0
    fi
    sleep 10
done

echo "❌ Échec attribution IP"
kubectl describe svc -n ingress-nginx ingress-nginx-controller
exit 1