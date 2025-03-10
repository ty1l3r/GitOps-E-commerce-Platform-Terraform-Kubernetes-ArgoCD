#!/bin/bash

# Variables globales
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
API_BASE_URL="http://url.fr"

# Fonction helper pour les logs
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Vérification utilisateur
check_user() {
    local email="$1"
    log "Vérification de l'existence de l'utilisateur : $email"
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

# Vérification données initiales
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

# Création utilisateur
create_user() {
    local email="$1"
    local password="$2"
    local phone="$3"

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
    fi
}

# Création produit
create_product() {
    local name="$1"
    local desc="$2"
    local type="$3"
    local banner="$4"
    local unit="$5"
    local price="$6"
    local suplier="$7"

    log "Création du produit : $name"
    local json_data="{\"name\":\"$name\",\"desc\":\"$desc\",\"type\":\"$type\",\"banner\":\"$banner\",\"unit\":$unit,\"price\":$price,\"available\":true,\"suplier\":\"$suplier\"}"

    response=$(curl -s -X POST "${API_BASE_URL}/product/create" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    if [[ "$response" == *"error"* ]]; then
        echo -e "${RED}✗${NC} Erreur lors de la création du produit: $response"
        return 1
    else
        echo -e "${GREEN}✓${NC} Produit créé avec succès"
        sleep 2
    fi
}

# Fonction principale
main() {
    log "Démarrage de la vérification des données"

    if check_initial_data; then
        log "Les données sont déjà initialisées, aucune action nécessaire"
        exit 0
    fi

    log "Démarrage de l'initialisation des données pour l'environnement staging"
    log "Attente de 30 secondes pour que les services démarrent..."
    sleep 30

    # Création des utilisateurs
    create_user "a@example.com" "${USER_PASSWORD:-$(openssl rand -base64 12)}" "+0000000000"
    create_user "b@example.com" "${USER_PASSWORD:-$(openssl rand -base64 12)}" "+0000000001"
    create_user "c@example.com" "${USER_PASSWORD:-$(openssl rand -base64 12)}" "+0000000002"
    create_user "d@example.com" "${USER_PASSWORD:-$(openssl rand -base64 12)}" "+0000000003"

    log "Création des produits..."

    # 10 Fruits
    create_product "Premium Alphonso Mango" "High Quality Indian Mango" "fruits" "https://images.unsplash.com/photo-1553279768-865429fa0078" 1 300 "Premium Fruits Co."
    create_product "Green Apple" "Fresh Green Apples" "fruits" "https://images.unsplash.com/photo-1619546813926-a78fa6372cd2" 1 140 "Premium Fruits Co."
    create_product "Red Dragon Fruit" "Exotic Dragon Fruit" "fruits" "https://images.unsplash.com/photo-1527325678286-3f47c727f8ee" 1 250 "Exotic Fruits Inc"
    create_product "Golden Kiwi" "Sweet Golden Kiwi" "fruits" "https://images.unsplash.com/photo-1585059895289-5c2d611b8127" 1 180 "Premium Fruits Co."
    create_product "Fresh Strawberries" "Organic Strawberries" "fruits" "https://images.unsplash.com/photo-1464965911861-746a04b4bca6" 1 220 "Bio Farms Inc"
    create_product "Sweet Cherries" "Premium Cherries" "fruits" "https://images.unsplash.com/photo-1528821128474-27f963b062bf" 1 280 "Premium Fruits Co."
    create_product "Yellow Banana" "Fresh Bananas" "fruits" "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e" 1 160 "Tropical Fruits Ltd"
    create_product "Red Pomegranate" "Fresh Pomegranate" "fruits" "https://images.unsplash.com/photo-1541344999736-83eca272f6fc" 1 290 "Premium Fruits Co."
    create_product "Sweet Orange" "Juicy Oranges" "fruits" "https://images.unsplash.com/photo-1547514701-42782101795e" 1 170 "Citrus Co."
    create_product "Fresh Blueberries" "Organic Blueberries" "fruits" "https://images.unsplash.com/photo-1498557850523-fd3d118b962e" 1 240 "Bio Farms Inc"

    # 10 Légumes
    create_product "Organic Broccoli" "Fresh Organic Broccoli" "vegetables" "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc" 1 280 "Bio Farms Inc"
    create_product "Premium Carrots" "Fresh Carrots" "vegetables" "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37" 1 150 "Bio Farms Inc"
    create_product "Red Tomatoes" "Vine Ripened Tomatoes" "vegetables" "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2" 1 190 "Fresh Veggies Co"
    create_product "Green Lettuce" "Crisp Lettuce" "vegetables" "https://images.unsplash.com/photo-1622205313162-be1d5712a43f" 1 170 "Bio Farms Inc"
    create_product "Sweet Corn" "Fresh Corn" "vegetables" "https://images.unsplash.com/photo-1551754655-cd27e38d2076" 1 160 "Farm Fresh Ltd"
    create_product "Red Bell Pepper" "Sweet Peppers" "vegetables" "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83" 1 220 "Fresh Veggies Co"
    create_product "White Mushrooms" "Fresh Mushrooms" "vegetables" "https://images.unsplash.com/photo-1504545958425-d3e961f81fb8" 1 250 "Mushroom Farm"
    create_product "Green Zucchini" "Fresh Zucchini" "vegetables" "https://images.unsplash.com/photo-1596142332133-327e2a0ff6f8" 1 180 "Bio Farms Inc"
    create_product "Purple Eggplant" "Fresh Eggplant" "vegetables" "https://images.unsplash.com/photo-1615484477778-ca3b77940c25" 1 200 "Fresh Veggies Co"
    create_product "Green Asparagus" "Premium Asparagus" "vegetables" "https://images.unsplash.com/photo-1515471022490-7d975235c8b8" 1 270 "Bio Farms Inc"

    # 10 Huiles
    create_product "Extra Virgin Olive Oil" "Premium Italian" "oils" "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5" 1 400 "Italian Oils Ltd"
    create_product "Coconut Oil" "Organic Coconut Oil" "oils" "https://images.unsplash.com/photo-1621939514649-280e2ee25f60" 1 350 "Tropical Oils Co"
    create_product "Avocado Oil" "Pure Avocado Oil" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 380 "Healthy Oils Inc"
    create_product "Sesame Oil" "Asian Sesame Oil" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 290 "Asian Oils Ltd"
    create_product "Walnut Oil" "Premium Walnut Oil" "oils" "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5" 1 420 "Nut Oils Co"
    create_product "Grapeseed Oil" "Pure Grapeseed" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 340 "Vineyard Oils"
    create_product "Sunflower Oil" "Pure Sunflower" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 280 "Sunflower Co"
    create_product "Peanut Oil" "Premium Peanut Oil" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 310 "Nut Oils Co"
    create_product "Macadamia Oil" "Gourmet Macadamia" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 450 "Premium Oils"
    create_product "Truffle Oil" "Black Truffle Oil" "oils" "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1" 1 500 "Gourmet Oils"

    log "Initialisation terminée"
}

# Exécution du script
main