import { DeleteData, GetData, PostData, PutData } from '../../utils';
import { Action } from '.';

export const onGetProducts = () => async (dispatch) => {
  try {
    // Utilisation de "/product" pour récupérer les produits
    const response = await GetData('/product');
    dispatch({ type: Action.LANDING_PRODUCTS, payload: response.data });
  } catch (err) {
    console.error('Error fetching products:', err);
  }
};

export const onGetProductDetails = (id) => async (dispatch) => {
  try {
    // Utilisation de "/product/:id" pour récupérer les détails d'un produit
    const response = await GetData(`/product/${id}`);
    dispatch({ type: Action.PRODUCT_DETAILS, payload: response.data });
  } catch (err) {
    console.error('Error fetching product details:', err);
  }
};

/* ------------------- Wishlist --------------------- */

export const onAddToWishlist = (_id) => async (dispatch) => {
  try {
    const response = await PutData('/product/wishlist', { _id });
    dispatch({ type: Action.ADD_TO_WISHLIST, payload: response.data });
  } catch (err) {
    console.error('Error adding to wishlist:', err);
  }
};

export const onRemoveFromWishlist = (_id) => async (dispatch) => {
  try {
    const response = await DeleteData(`/product/wishlist/${_id}`);
    dispatch({ type: Action.REMOVE_FROM_WISHLIST, payload: response.data });
  } catch (err) {
    console.error('Error removing from wishlist:', err);
  }
};


/* ------------------- Cart --------------------- */
export const onAddToCart = ({ _id, qty }) => async (dispatch) => {
  try {
    const response = await PutData('/product/cart', { _id, qty }); // Préfixe ajouté
    dispatch({ type: Action.ADD_TO_CART, payload: response.data });
  } catch (err) {
    console.error('Error adding to cart:', err);
  }
};

export const onRemoveFromCart = (_id) => async (dispatch) => {
  try {
    const response = await DeleteData(`/product/cart/${_id}`); // Préfixe ajouté
    dispatch({ type: Action.REMOVE_FROM_CART, payload: response.data });
  } catch (err) {
    console.error('Error removing from cart:', err);
  }
};


/* ------------------- Address --------------------- */

export const onCreateAddress = ({ street, postalCode, city, country }) => async (dispatch) => {
  try {
    const response = await PostData('/customer/address/', {
      street,
      postalCode,
      city,
      country,
    });
    dispatch({ type: Action.ADDED_NEW_ADDRESS, payload: response.data });
  } catch (err) {
    console.error('Error creating address:', err);
  }
};

/* ------------------- Order --------------------- */

export const onPlaceOrder = ({ txnId }) => async (dispatch) => {
  try {
    const response = await PostData('/shopping/order', { txnId });
    console.log('Order placed:', response.data);
    dispatch({ type: Action.PLACE_ORDER, payload: response.data });
  } catch (err) {
    console.error('Error placing order:', err);
  }
};
