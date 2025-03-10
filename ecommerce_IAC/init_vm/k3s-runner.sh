#!/bin/bash
# Couleurs pour le feedback visuel
GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m" # No Color
# Délimiteur visuel pour les étapes
SEPARATOR="\n=====================================================\n"

#########################################################################
#                           VARIABLES                                     #
#########################################################################

# Variables GitLab
GITLAB_URL="https://gitlab.com"
GITLAB_TOKEN_DOCKER="DOCKER_TOKEN"
GITLAB_TOKEN_SHELL="SHELL_TOKEN"
GITLAB_RUNNER_TAGS_DOCKER="docker,prod"
GITLAB_RUNNER_TAGS_SHELL="shell,prod"

# Variables de connexion
REMOTE_USER="ubuntu"
REMOTE_HOST="YOUR_IP_ADDRESS"
REMOTE_PRIVATE_KEY="$HOME/.ssh/cleSSH"

# Chemins de sauvegarde et configuration
LOCAL_BACKUP_DIR="/home/ubuntu/redproject/red-helm/backup"
CONFIG_TOML_LOCAL_BACKUP="/home/ubuntu/redproject/red-helm/backup/gitlab-runner-config-redproject.toml"
REMOTE_FINAL_TOML="/etc/gitlab-runner/config.toml"

#########################################################################
#                           FONCTIONS                                     #
#########################################################################

# Fonction de vérification des erreurs
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERREUR: $1...FAIL${NC}"
        exit 1
    else
        echo -e "${GREEN}$1...PASS${NC}"
    fi
}

# Fonction d'exécution de commandes SSH
run_ssh_command() {
    ssh -o StrictHostKeyChecking=no -i "$REMOTE_PRIVATE_KEY" $REMOTE_USER@$REMOTE_HOST "$1"
    check_error "$2"
}

#########################################################################
#                    INSTALLATION DE DOCKER                               #
#########################################################################

echo -e "$SEPARATOR Installation de Docker $SEPARATOR"

run_ssh_command "
set -e
echo '🔵 Mise à jour du système...'
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

echo '🔵 Configuration du référentiel Docker...'
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo '🔵 Ajout du référentiel Docker...'
echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
\$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo '🔵 Installation de Docker...'
sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo '🔵 Configuration des permissions...'
sudo usermod -aG docker $REMOTE_USER
" "Installation de Docker"

#########################################################################
#       DEPLOIEMENT DU FICHIER DE CONFIGURATION                          #
#########################################################################

echo -e "$SEPARATOR Déploiement du fichier de configuration $SEPARATOR"

# Création du répertoire de backup si non existant
mkdir -p "$LOCAL_BACKUP_DIR"

# Copie du fichier de configuration
scp -o StrictHostKeyChecking=no -i "$REMOTE_PRIVATE_KEY" "$CONFIG_TOML_LOCAL_BACKUP" $REMOTE_USER@$REMOTE_HOST:"/home/ubuntu/config.toml"

run_ssh_command "
    if [ -f /home/ubuntu/config.toml ]; then
        sudo chown root:ubuntu /etc/gitlab-runner
        sudo chmod 750 /etc/gitlab-runner
        sudo mv /home/ubuntu/config.toml $REMOTE_FINAL_TOML
        echo '✅ Fichier de configuration déployé'
    else
        echo '❌ Fichier de configuration non trouvé'
        exit 1
    fi
" "Déploiement du fichier de configuration"

#########################################################################
#                    INSTALLATION DE GITLAB RUNNER                        #
#########################################################################

echo -e "$SEPARATOR Installation de GitLab Runner $SEPARATOR"

run_ssh_command "
sudo apt-get update &&
sudo apt-get install -y curl &&
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash &&
sudo apt-get install gitlab-runner -y
" "Installation de GitLab Runner"

#########################################################################
#                    NETTOYAGE DES RUNNERS EXISTANTS                     #
#########################################################################

echo -e "$SEPARATOR Nettoyage des runners existants $SEPARATOR"

run_ssh_command "
sudo systemctl stop gitlab-runner
sudo gitlab-runner unregister --all-runners
sudo rm -f /etc/gitlab-runner/config.toml
" "Nettoyage des runners"

#########################################################################
#                    CONFIGURATION DES RUNNERS                            #
#########################################################################

echo -e "$SEPARATOR Enregistrement des runners $SEPARATOR"

# Configuration du runner Docker
run_ssh_command "
sudo gitlab-runner register --non-interactive \
    --url '$GITLAB_URL' \
    --token '$GITLAB_TOKEN_DOCKER' \
    --description 'Red Project Runner Docker' \
    --executor 'docker' \
    --docker-image 'docker:latest' \
    --docker-privileged=true
" "Configuration du runner Docker"

# Configuration du runner Shell
run_ssh_command "
sudo gitlab-runner register --non-interactive \
    --url '$GITLAB_URL' \
    --token '$GITLAB_TOKEN_SHELL' \
    --description 'Shell Runner' \
    --executor 'shell'
" "Configuration du runner Shell"

#########################################################################
#                    CONFIGURATION FINALE                                 #
#########################################################################

echo -e "$SEPARATOR Configuration finale $SEPARATOR"

run_ssh_command "
    # Configuration des permissions
    {
        # Docker permissions
        sudo usermod -aG docker gitlab-runner

        # Sudo configuration
        sudo usermod -aG sudo gitlab-runner
        echo 'gitlab-runner ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/gitlab-runner
        sudo chmod 440 /etc/sudoers.d/gitlab-runner

        # APT permissions
        sudo chown root:gitlab-runner /var/lib/apt/lists/lock
        sudo chmod 664 /var/lib/apt/lists/lock
        sudo chown root:gitlab-runner /var/cache/apt/archives/lock
        sudo chmod 664 /var/cache/apt/archives/lock
        sudo chown root:gitlab-runner /var/lib/dpkg/lock-frontend
        sudo chmod 664 /var/lib/dpkg/lock-frontend

        # Vérification finale
        echo '🔵 Vérification des permissions:'
        ls -l /var/lib/apt/lists/lock
        ls -l /var/cache/apt/archives/lock
        ls -l /var/lib/dpkg/lock-frontend
        id gitlab-runner

        # Redémarrage et vérification
        sudo systemctl restart gitlab-runner
        echo '🔵 Liste des runners configurés:'
        sudo gitlab-runner list
        echo '🔵 Statut du service gitlab-runner:'
        sudo systemctl status gitlab-runner --no-pager
    } 2>&1
" "Configuration finale"

echo -e "$SEPARATOR Installation terminée avec succès! $SEPARATOR"