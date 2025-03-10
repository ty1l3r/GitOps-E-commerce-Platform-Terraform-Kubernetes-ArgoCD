#!/bin/bash

# Couleurs pour le feedback visuel
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m" # No Color

# Délimiteur visuel
SEPARATOR="\n=====================================================\n"

# Variables pour la machine distante
REMOTE_USER="ubuntu"
REMOTE_HOST="YOUR_IP_ADDRESS"
PASSWORD_FILE="password.txt"
LOCAL_KUBECONFIG_PATH="$HOME/.kube/config"
REMOTE_K3S_CTL_PATH="/etc/rancher/k3s/k3s.yaml"

# Charger le mot de passe utilisateur ubuntu à partir du fichier
if [ ! -f "$PASSWORD_FILE" ]; then
  echo -e "${RED}Le fichier de mot de passe $PASSWORD_FILE est manquant...FAIL${NC}"
  exit 1
fi

REMOTE_PASS=$(cat "$PASSWORD_FILE")

echo -e "$SEPARATOR Début de la configuration du pare-feu sur la VM distante $SEPARATOR"

# Connexion SSH et exécution du script de configuration du pare-feu
sshpass -p "$REMOTE_PASS" ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST << 'EOF'
# Définir les couleurs pour le feedback visuel
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m" # No Color



# Délimiteur visuel
SEPARATOR="\n=====================================================\n"

echo -e "$SEPARATOR Début de la configuration du pare-feu sur la VM $SEPARATOR"

#########################################################################
#               DÉFINITION DES PORTS À AUTORISER                        #
#########################################################################

ports_to_allow=(
  "22/tcp"      # SSH
  "6443/tcp"    # API Kubernetes kubectl
  "8472/udp"    # Communication réseau entre les nœuds (flannel)
  "10250/tcp"   # Kubelet
  "10251/tcp"   # Kube-scheduler
  "10252/tcp"   # Kube-controller-manager
  "80/tcp"      # HTTP
  "443/tcp"     # HTTPS
  "5672"
  "15672"
  "31854"       #NodePort http
  "30763"       #Nodeports https
  "9090"        #Prometheus
  "8081"        #mongoexpress products
  "8082"        #mongoexpress custom
)

#########################################################################
#        CONFIGURATION POUR IGNORER L'IPV6 SI NÉCESSAIRE                #
#########################################################################

echo -e "$SEPARATOR Désactivation de l'IPv6 dans UFW si non nécessaire $SEPARATOR"
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw
sudo systemctl restart ufw
sleep 2  # Pause pour stabiliser UFW après le redémarrage

#########################################################################
#        RÉINITIALISATION DU PARE-FEU UFW EN CAS DE CONFLIT             #
#########################################################################

echo -e "$SEPARATOR Réinitialisation de UFW $SEPARATOR"
sudo ufw --force reset
sleep 2  # Pause pour stabiliser UFW après la réinitialisation

#########################################################################
#      VÉRIFICATION ET ACTIVATION DU PARE-FEU (SI NÉCESSAIRE)           #
#########################################################################

sudo ufw status | grep -q "Status: active"
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Le pare-feu est déjà activé.${NC}"
else
  echo -e "${GREEN}Activation du pare-feu UFW...${NC}"
  echo "y" | sudo ufw --force enable
  sleep 2
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Pare-feu activé avec succès...PASS${NC}"
  else
    echo -e "${RED}Échec lors de l'activation du pare-feu...FAIL${NC}"
    sudo ufw status verbose
    exit 1
  fi
fi

#########################################################################
#          AUTORISER LES PORTS DÉFINIS DANS LE TABLEAU                  #
#########################################################################

for port in "${ports_to_allow[@]}"; do
  sudo ufw status | grep -q "$port"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Le port $port est déjà ouvert.${NC}"
  else
    echo -e "$SEPARATOR Ouverture du port $port $SEPARATOR"
    sudo ufw allow "$port"
    sleep 1  # Pause pour éviter les conflits de verrouillage
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Port $port ouvert avec succès...PASS${NC}"
    else
      echo -e "${RED}Échec lors de l'ouverture du port $port...FAIL${NC}"
      exit 1
    fi
  fi
done

#########################################################################
#            APPLIQUER LES RÈGLES PAR DÉFAUT DU PARE-FEU                #
#########################################################################

echo -e "$SEPARATOR Application des règles par défaut : refuser tout trafic entrant, permettre tout trafic sortant $SEPARATOR"
sudo ufw default deny incoming
sleep 1
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de la configuration des règles par défaut du trafic entrant...FAIL${NC}"
  exit 1
fi

sudo ufw default allow outgoing
sleep 1
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de la configuration des règles par défaut du trafic sortant...FAIL${NC}"
  exit 1
fi

#########################################################################
#                 DÉSACTIVER LA JOURNALISATION DU PARE-FEU             #
#########################################################################

echo -e "$SEPARATOR Désactivation des règles de journalisation $SEPARATOR"
sudo ufw logging off
if [ $? -ne 0 ]; then
  echo -e "${RED}Échec lors de la désactivation des règles de journalisation...FAIL${NC}"
fi

#########################################################################
#                 VÉRIFICATION FINALE DU STATUT DU PARE-FEU             #
#########################################################################

echo -e "$SEPARATOR Vérification finale du pare-feu $SEPARATOR"
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}Pare-feu activé et fonctionnel...PASS${NC}"
else
    echo -e "${RED}Le pare-feu n'est pas activé...FAIL${NC}"
    exit 1
fi

echo -e "$SEPARATOR Pare-feu configuré avec succès! $SEPARATOR"
EOF

# Vérification du succès de l'exécution distante
if [ $? -ne 0 ]; then
  echo -e "${RED}L'exécution du script sur la machine distante a échoué...FAIL${NC}"
  exit 1
else
  echo -e "${GREEN}Script exécuté avec succès sur la machine distante...PASS${NC}"
fi
