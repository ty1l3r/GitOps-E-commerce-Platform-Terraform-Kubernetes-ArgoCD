# Build stage
FROM node:16 AS build
WORKDIR /app
# Copier les fichiers package
COPY package*.json ./
# Install et audit
RUN npm install
# Copier le reste des fichiers
COPY . .
# Build en mode production
RUN npm run build
# Production stage
FROM nginx:alpine
# Copier la configuration nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copier les fichiers buildés
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]