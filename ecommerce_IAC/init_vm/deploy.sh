#!/bin/bash

# Couleurs pour le feedback visuel
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m" # No Color

# Délimiteur visuel
SEPARATOR="\n=====================================================\n"

# Variables
REMOTE_USER="ubuntu"
REMOTE_HOST="IP_ADDRESS"
PASSWORD_FILE="password.txt"

# Charger le mot de passe utilisateur ubuntu à partir du fichier
if [ ! -f "$PASSWORD_FILE" ]; then
  echo -e "${RED}Le fichier de mot de passe $PASSWORD_FILE est manquant...FAIL${NC}"
  exit 1
fi

REMOTE_PASS=$(cat "$PASSWORD_FILE")

echo -e "$SEPARATOR Lancement du déploiement de la machine distante $SEPARATOR"
#########################################################################
#       ÉTAPE 1 : INITIALISATION DE LA MACHINE AVEC INITIALISATION-VM   #
#########################################################################
echo -e "${GREEN}Étape 1 : Initialisation de la machine avec initialisation-vm.sh...${NC}"
# Exécuter le script initialisation-vm.sh et vérifier son succès
./initialisation-vm.sh
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec de l'initialisation de la machine...FAIL${NC}"
  exit 1
fi
echo -e "${GREEN}Initialisation de la machine réussie...PASS${NC}"

#########################################################################
#   ÉTAPE 2 : INSTALLATION DES OUTILS DE BASE AVEC PACKAGE-VM.SH        #
#########################################################################
echo -e "${GREEN}Étape 3 : Installation des outils de base avec package-vm.sh...${NC}"
# Exécuter le script package-vm.sh pour installer les outils de base
./package-vm.sh
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de l'installation des outils...FAIL${NC}"
  exit 1
fi

echo -e "${GREEN}Installation des outils de base réussie...PASS${NC}"

#########################################################################
#   ÉTAPE 3 : INSTALLATION DU DOCKER & K3S-RUNNER.SH          #
#########################################################################

echo -e "${GREEN}Étape 5 : Installation du GitLab Runner avec k3s-runner.sh...${NC}"

# Exécuter le script k3s-runner.sh pour installer le GitLab Runner
./k3s-runner.sh
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de l'installation du GitLab Runner...FAIL${NC}"
  exit 1
fi

echo -e "${GREEN}Installation du GitLab Runner réussie...PASS${NC}"

########################################################################
 # DÉPLOIEMENT VM TERMINÉ AVEC SUCCÈS                        #
########################################################################

echo -e "$SEPARATOR Déploiement terminé avec succès! $SEPARATOR"
