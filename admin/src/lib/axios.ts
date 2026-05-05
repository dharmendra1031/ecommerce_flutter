import axios from 'axios';
import { useAuthStore } from '@/stores/auth-store';
import { navigateTo } from './navigation';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      const state = useAuthStore.getState();
      if (state.accessToken || state.user) {
        state.logout();
      }
      navigateTo('/login', { replace: true });
    }
    return Promise.reject(error.response?.data || error);
  }
);

export default api;
