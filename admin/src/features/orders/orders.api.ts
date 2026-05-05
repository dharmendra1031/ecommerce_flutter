import api from '@/lib/axios';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useOrders = (page: number, limit: number, search: string, status?: string) =>
  useQuery({
    queryKey: ['orders', page, limit, search, status],
    queryFn: () => api.get('/orders/admin/all', { params: { page, limit, search, status } }),
  });

export const useOrder = (id: string) =>
  useQuery({
    queryKey: ['orders', id],
    queryFn: () => api.get(`/orders/${id}`),
    enabled: !!id,
  });

export const useUpdateOrderStatus = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      api.put(`/orders/admin/${id}/status`, { status }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['orders'] }),
  });
};
