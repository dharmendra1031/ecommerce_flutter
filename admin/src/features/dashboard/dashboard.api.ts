import api from '@/lib/axios';

export const dashboardApi = {
  getStats: () => api.get('/admin/dashboard'),
  getRecentOrders: () => api.get('/orders/admin/all?limit=5'),
};
