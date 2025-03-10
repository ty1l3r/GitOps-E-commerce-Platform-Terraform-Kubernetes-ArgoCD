import api from 'axios';

// Définition correcte de l'URL de base
const BASE_URL = process.env.BASE_URL;
api.defaults.baseURL = BASE_URL;
console.log("BASE_URL utilisée:", process.env.BASE_URL);
console.log("api.defaults.baseURL:", api.defaults.baseURL);

const setHeader = () => {
  const token = localStorage.getItem('token');
  if (token) {
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }
};

export const GetData = async(endPoint,options) => {
  try {
    setHeader();
    const response = await api.get(endPoint);
    return response
  } catch (err) {
      throw err;
  }
}

export const PostData = async(endPoint,options) => {
  try {
    setHeader();
    const response = await api.post(endPoint, options);
    return response
  } catch (err) {
      throw err;
  }
}

export const PutData = async(endPoint,options) => {

  try {
    setHeader();
    const response = await api.put(endPoint, options);
    return response
  } catch (err) {
      throw err;
  }
}

export const DeleteData = async(endPoint) => {

  try {
    setHeader();
    const response = await api.delete(endPoint);
    return response
  } catch (err) {
      throw err;
  }
}