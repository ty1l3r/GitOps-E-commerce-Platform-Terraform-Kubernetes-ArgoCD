#!/bin/bash

# Couleurs pour les logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# URL de base de l'API
API_BASE_URL="http://dev.dev-euphony.fr"

# Fonction pour les logs
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Fonction pour vérifier si un utilisateur existe
check_user() {
    local email="$1"
    log "Vérification de l'existence de l'utilisateur : $email"

    # On essaie de se connecter avec l'utilisateur
    response=$(curl -s -X POST "${API_BASE_URL}/customer/signin" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$email\", \"password\": \"1234\"}")

    if [[ "$response" == *"\"token\""* ]]; then
        echo -e "${YELLOW}⚠${NC} L'utilisateur $email existe déjà"
        return 0
    else
        echo -e "${GREEN}✓${NC} L'utilisateur $email n'existe pas encore"
        return 1
    fi
}

# Fonction pour vérifier si les données initiales existent déjà
check_initial_data() {
    log "Vérification de l'existence des données initiales..."

    response=$(curl -s "${API_BASE_URL}/product")

    if [[ "$response" == *"\"name\""* ]]; then
        echo -e "${YELLOW}⚠${NC} Des produits existent déjà dans la base de données"
        return 0
    else
        echo -e "${GREEN}✓${NC} Base de données vide, initialisation nécessaire"
        return 1
    fi
}

# Fonction pour créer un utilisateur
create_user() {
    local email="$1"
    local password="$2"
    local phone="$3"

    # Vérifier d'abord si l'utilisateur existe
    if ! check_user "$email"; then
        log "Création de l'utilisateur : $email"
        response=$(curl -s -X POST "${API_BASE_URL}/customer/signup" \
            -H "Content-Type: application/json" \
            -d "{\"email\": \"$email\", \"password\": \"$password\", \"phone\": \"$phone\"}")

        if [[ "$response" == *"error"* ]]; then
            echo -e "${RED}✗${NC} Erreur lors de la création de l'utilisateur: $response"
        else
            echo -e "${GREEN}✓${NC} Utilisateur créé avec succès"
        fi
    else
        log "Utilisateur existant, pas besoin de le créer"
    fi
}

# Fonction pour créer un produit
create_product() {
    local name="$1"
    local desc="$2"
    local type="$3"
    local banner="$4"
    local unit="$5"
    local price="$6"
    local suplier="$7"

    log "Création du produit : $name"

    # Création du JSON avec des valeurs échappées
    local json_data="{\"name\":\"$name\",\"desc\":\"$desc\",\"type\":\"$type\",\"banner\":\"$banner\",\"unit\":$unit,\"price\":$price,\"available\":true,\"suplier\":\"$suplier\"}"

    response=$(curl -s -X POST "${API_BASE_URL}/product/create" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    if [[ "$response" == *"error"* ]]; then
        echo -e "${RED}✗${NC} Erreur lors de la création du produit: $response"
        return 1
    else
        echo -e "${GREEN}✓${NC} Produit créé avec succès"
    fi
}

# Script principal
main() {
    log "Démarrage de la vérification des données"

    if check_initial_data; then
        log "Les données sont déjà initialisées, aucune action nécessaire"
        exit 0
    fi

    log "Démarrage de l'initialisation des données"

    # Attente que les services soient prêts
    log "Attente de 30 secondes pour que les services démarrent..."
    sleep 30

    # Création de l'utilisateur
    create_user "admin@example.com" "${ADMIN_PASSWORD:-$(openssl rand -base64 12)}" "+0000000000"

    # Liste des produits à créer
    log "Création des produits..."
    sleep 2  # Petite pause avant de commencer

    create_product \
        "alphonso mango" \
        "great Quality of Mango" \
        "fruits" \
        "https://cdn.pixabay.com/photo/2015/08/19/15/50/mango-896179_1280.jpg" \
        1 \
        300 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Apples" \
        "great Quality of Apple" \
        "fruits" \
        "https://cdn.pixabay.com/photo/2022/05/27/10/57/apples-7224924_1280.jpg" \
        1 \
        140 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Kesar Mango" \
        "great Quality of Mango" \
        "fruits" \
        "https://cdn.pixabay.com/photo/2015/08/19/15/58/mango-896189_1280.jpg" \
        1 \
        170 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Langra Mango" \
        "great Quality of Mango" \
        "fruits" \
        "https://cdn.pixabay.com/photo/2012/02/29/16/01/mango-19320_1280.jpg" \
        1 \
        280 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Broccoli" \
        "great Quality of Fresh Vegetable" \
        "vegetables" \
        "https://cdn.pixabay.com/photo/2016/03/05/19/02/broccoli-1238250_1280.jpg" \
        1 \
        280 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Cauliflower" \
        "great Quality of Fresh Vegetable" \
        "vegetables" \
        "https://cdn.pixabay.com/photo/2015/09/25/16/51/cabbage-957778_1280.jpg" \
        1 \
        280 \
        "Golden seed firming"
    sleep 2

    create_product \
        "Olive Oil" \
        "great Quality of Oil" \
        "oils" \
        "https://cdn.pixabay.com/photo/2014/05/28/00/27/olive-oil-356102_1280.jpg" \
        1 \
        400 \
        "Golden seed firming"

    log "Initialisation terminée"
}

# Exécution du script
main