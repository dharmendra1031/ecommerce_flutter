import api from '@/lib/axios';

export const authApi = {
  login: (email: string, password: string) =>
    api.post('/auth/login', { email, password }),

  me: () => api.get('/auth/me'),

  logout: () => api.post('/auth/logout'),
};
