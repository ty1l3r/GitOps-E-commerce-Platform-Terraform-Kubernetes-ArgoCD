const ShoppingService = require("../services/shopping-service");
const { PublishCustomerEvent, SubscribeMessage, PublishMessage } = require("../utils");
const UserAuth = require('./middlewares/auth');
const { CUSTOMER_SERVICE } = require('../config');

module.exports = (app, channel) => {
    const service = new ShoppingService();
    SubscribeMessage(channel, service);

    // **Route pour passer une commande**
    app.post('/shopping/order', UserAuth, async (req, res, next) => {
        try {
            const { _id } = req.user;
            const { txnId } = req.body;  // Correction de txnNumber à txnId
            const { data } = await service.PlaceOrder({ _id, txnId });
            const payload = await service.GetOrderPayload(_id, data, 'CREATE_ORDER');
            PublishMessage(channel, CUSTOMER_SERVICE, JSON.stringify(payload));
            res.status(200).json(data);
        } catch (error) {
            console.error('Error placing order:', error);
            res.status(500).json({ error: 'Failed to place order' });
        }
    });

    // **Route pour obtenir les commandes**
    app.get('/shopping/orders', UserAuth, async (req, res, next) => {
        try {
            const { _id } = req.user;
            const { data } = await service.GetOrders(_id);
            res.status(200).json(data);
        } catch (error) {
            console.error('Error fetching orders:', error);
            res.status(500).json({ error: 'Failed to fetch orders' });
        }
    });

    // **Route pour ajouter un produit au panier**
    app.put('/shopping/cart', UserAuth, async (req, res, next) => {
        try {
            const { _id } = req.user;
            const { _id: productId } = req.body;
            const { data } = await service.AddToCart(_id, productId);
            res.status(200).json(data);
        } catch (error) {
            console.error('Error adding to cart:', error);
            res.status(500).json({ error: 'Failed to add to cart' });
        }
    });

    // **Route pour supprimer un produit du panier**
    app.delete('/shopping/cart/:id', UserAuth, async (req, res, next) => {
        try {
            const { _id } = req.user;
            const productId = req.params.id;
            const { data } = await service.RemoveFromCart(_id, productId);  // Correction de AddToCart à RemoveFromCart
            res.status(200).json(data);
        } catch (error) {
            console.error('Error removing from cart:', error);
            res.status(500).json({ error: 'Failed to remove from cart' });
        }
    });

    // **Route pour obtenir le panier**
    app.get('/shopping/cart', UserAuth, async (req, res, next) => {
        try {
            const { _id } = req.user;
            const { data } = await service.GetCart({ _id });
            res.status(200).json(data);
        } catch (error) {
            console.error('Error fetching cart:', error);
            res.status(500).json({ error: 'Failed to fetch cart' });
        }
    });

    // **Route de test**
    app.get('/shopping/whoami', (req, res, next) => {
        res.status(200).json({ msg: '/shopping : I am Shopping Service' });
    });
};
