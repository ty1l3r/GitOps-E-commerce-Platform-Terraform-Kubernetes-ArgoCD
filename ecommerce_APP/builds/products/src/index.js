const express = require('express');
const { PORT } = require('./config');
const { databaseConnection } = require('./database');
const expressApp = require('./express-app');

const StartServer = async() => {

    const app = express();
    
    app.get('/health', (req, res) => {
        res.status(200).json({
            status: 'UP',
            timestamp: new Date(),
            service: 'products'
        });
    });

    await databaseConnection();

    await expressApp(app);

    app.listen(PORT, () => {
        console.log(`listening to port ${PORT}`);
    })
    .on('error', (err) => {
        console.log(err);
        process.exit();
    })

}

StartServer();
