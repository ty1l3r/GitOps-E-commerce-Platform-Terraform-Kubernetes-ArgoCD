FROM node:16

# Définir le répertoire de travail dans /app
WORKDIR /app

# Copier les fichiers de dépendances
COPY package.json package-lock.json ./

# Installer les dépendances
RUN npm install

# Copier tous les fichiers du service dans l'image
COPY . .

# Exposer le port utilisé par le service
EXPOSE 8001

# Démarrer l'application
CMD ["npm", "start"]
