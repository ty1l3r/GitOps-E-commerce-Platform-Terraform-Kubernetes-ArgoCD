# Utilisation de l'image Node.js classique (complète) pour maximiser la compatibilité en développement
FROM node:16

# Définition du répertoire de travail à l'intérieur du container
WORKDIR /app

# Copie uniquement du fichier package.json
COPY package.json ./

# Installation des dépendances (inclut les dépendances de développement)
RUN npm install

# Copie de tout le code source du service dans le conteneur
COPY . .

# Exposition du port sur lequel le service écoute
EXPOSE 8003

# Commande pour démarrer l'application en mode développement
CMD ["npm", "start"]
