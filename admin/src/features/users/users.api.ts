import api from '@/lib/axios';
import { useQuery } from '@tanstack/react-query';

export const useUsers = (page: number, limit: number, search: string) =>
  useQuery({
    queryKey: ['users', page, limit, search],
    queryFn: () => api.get('/admin/users', { params: { page, limit, search } }),
  });
