#!/bin/bash

# Couleurs pour le feedback visuel
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m" # No Color

# Délimiteur visuel
SEPARATOR="\n=====================================================\n"

# Variables
REMOTE_USER="ubuntu"
REMOTE_HOST="YOUR_IP_ADDRESS"
PASSWORD_FILE="password.txt"

# Charger le mot de passe utilisateur ubuntu à partir du fichier
if [ ! -f "$PASSWORD_FILE" ];then
  echo -e "${RED}Le fichier de mot de passe $PASSWORD_FILE est manquant...FAIL${NC}"
  exit 1
fi

REMOTE_PASS=$(cat "$PASSWORD_FILE")


#########################################################################
#   INSTALLATION DES OUTILS CLASSIQUES DE DÉBOGAGE ET DE tree           #
#########################################################################

echo -e "$SEPARATOR Installation des outils classiques de débogage et de tree $SEPARATOR"

# Connexion SSH à la machine distante et installation des paquets
sshpass -p "$REMOTE_PASS" ssh -t -o StrictHostKeyChecking=no -i "$HOME/.ssh/vmf" $REMOTE_USER@$REMOTE_HOST <<'EOF'
  # Mettre à jour la liste des paquets
  sudo DEBIAN_FRONTEND=noninteractive apt-get update

  # Installer nano, tree, curl et d'autres outils utiles
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nano tree curl htop net-tools nginx
EOF

# Vérification du succès de l'installation
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de l'installation des outils...FAIL${NC}"
  exit 1
fi

echo -e "${GREEN}Installation des outils réussie...PASS${NC}"
echo -e "$SEPARATOR Fin de l'installation des outils $SEPARATOR"
