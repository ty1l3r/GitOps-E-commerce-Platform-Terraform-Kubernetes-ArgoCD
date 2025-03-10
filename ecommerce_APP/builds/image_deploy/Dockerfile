# Utiliser une base légère avec AWS CLI
FROM amazonlinux:2

# Définition des variables d'environnement
ENV AWS_CLI_VERSION="2.13.13"
ENV YQ_VERSION="v4.40.5"

# Mise à jour des paquets et installation des dépendances
RUN yum update -y && \
    yum install -y \
    unzip \
    curl \
    tar \
    gzip \
    python3 \
    python3-pip \
    jq \
    git \
    shadow-utils \
    openssl \
    wget && \
    yum clean all

# Installation d'AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Installation de yq
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Installation de Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Vérification des versions installées
RUN aws --version && helm version && yq --version

# Définition du répertoire de travail par défaut
WORKDIR /app

# Commande par défaut pour garder le conteneur actif
CMD ["/bin/bash"]