const dotEnv = require("dotenv");

// Vérifier si les variables sont définies avant de construire l'URL
if (!process.env.RABBITMQ_USER || !process.env.RABBITMQ_PASSWORD) {
  console.error("Erreur : RABBITMQ_USER ou RABBITMQ_PASSWORD non définis.");
  process.exit(1);
}

// Construction de MSG_QUEUE_URL à partir des variables d'environnement
const MSG_QUEUE_URL = `amqp://${process.env.RABBITMQ_USER}:${process.env.RABBITMQ_PASSWORD}@${process.env.RABBITMQ_SERVICE}`;
console.log('MSG_QUEUE_URL:', MSG_QUEUE_URL);

module.exports = {
  PORT: process.env.PORT,
  DB_URL: process.env.MONGODB_URI,
  APP_SECRET: process.env.APP_SECRET,
  BASE_URL: process.env.BASE_URL,
  EXCHANGE_NAME: process.env.EXCHANGE_NAME,
  MSG_QUEUE_URL, // Utilisation de l'URL construite dynamiquement
  CUSTOMER_SERVICE: process.env.CUSTOMER_SERVICE,
  SHOPPING_SERVICE: process.env.SHOPPING_SERVICE,
  NODE_ENV: process.env.NODE_ENV
};
