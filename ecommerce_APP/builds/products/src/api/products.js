const { CUSTOMER_SERVICE, SHOPPING_SERVICE } = require("../config");
const ProductService = require("../services/product-service");
const {
  PublishCustomerEvent,
  PublishShoppingEvent,
  PublishMessage,
} = require("../utils");
const UserAuth = require("./middlewares/auth");

module.exports = (app, channel) => {
  const service = new ProductService();

  // Route pour la liste des produits
  app.get("/product", async (req, res, next) => {
    console.log('GET /product called');
    try {
      console.log('Fetching products...');
      const { data } = await service.GetProducts();
      console.log('Products fetched:', data);
      return res.status(200).json(data);
    } catch (error) {
      console.error('Error fetching products:', error);
      return res.status(404).json({ error });
    }
  });

  // IMPORTANT: Placez cette route AVANT "/product/:id"
  // Route pour obtenir les produits par catégorie
  app.get("/product/category/:type", async (req, res, next) => {
    const type = req.params.type;
    try {
      const { data } = await service.GetProductsByCategory(type);
      return res.status(200).json(data);
    } catch (error) {
      return res.status(404).json({ error });
    }
  });

  // Route pour obtenir les détails d'un produit
  app.get("/product/:id", async (req, res, next) => {
    const productId = req.params.id;
    try {
      const { data } = await service.GetProductDescription(productId);
      return res.status(200).json(data);
    } catch (error) {
      return res.status(404).json({ error });
    }
  });

  // Autres routes...

  app.post("/product/create", async (req, res, next) => {
    const { name, desc, type, unit, price, available, suplier, banner } = req.body;
    const { data } = await service.CreateProduct({
      name,
      desc,
      type,
      unit,
      price,
      available,
      suplier,
      banner,
    });
    return res.json(data);
  });

  app.post("/product/ids", async (req, res, next) => {
    const { ids } = req.body;
    const products = await service.GetSelectedProducts(ids);
    return res.status(200).json(products);
  });

  app.put("/product/wishlist", UserAuth, async (req, res, next) => {
    const { _id } = req.user;
    const { data } = await service.GetProductPayload(
      _id,
      { productId: req.body._id },
      "ADD_TO_WISHLIST"
    );
    PublishMessage(channel, CUSTOMER_SERVICE, JSON.stringify(data));
    res.status(200).json(data.data.product);
  });

  app.delete("/product/wishlist/:id", UserAuth, async (req, res, next) => {
    const { _id } = req.user;
    const productId = req.params.id;
    const { data } = await service.GetProductPayload(
      _id,
      { productId },
      "REMOVE_FROM_WISHLIST"
    );
    PublishMessage(channel, CUSTOMER_SERVICE, JSON.stringify(data));
    res.status(200).json(data.data.product);
  });

  app.put("/product/cart", UserAuth, async (req, res, next) => {
    const { _id } = req.user;
    const { data } = await service.GetProductPayload(
      _id,
      { productId: req.body._id, qty: req.body.qty },
      "ADD_TO_CART"
    );
    PublishMessage(channel, CUSTOMER_SERVICE, JSON.stringify(data));
    PublishMessage(channel, SHOPPING_SERVICE, JSON.stringify(data));
    const response = { product: data.data.product, unit: data.data.qty };
    res.status(200).json(response);
  });

  app.delete("/product/cart/:id", UserAuth, async (req, res, next) => {
    const { _id } = req.user;
    const productId = req.params.id;
    const { data } = await service.GetProductPayload(
      _id,
      { productId },
      "REMOVE_FROM_CART"
    );
    PublishMessage(channel, CUSTOMER_SERVICE, JSON.stringify(data));
    PublishMessage(channel, SHOPPING_SERVICE, JSON.stringify(data));
    const response = { product: data.data.product, unit: data.data.qty };
    res.status(200).json(response);
  });

  app.get("/product/whoami", (req, res, next) => {
    return res.status(200).json({ msg: "/product : I am Products Service" });
  });
};
