import api from '@/lib/axios';
import { useQuery } from '@tanstack/react-query';

export const useReviews = (page: number, limit: number, search?: string) =>
  useQuery({
    queryKey: ['reviews', page, limit, search],
    queryFn: () => api.get('/admin/reviews', { params: { page, limit, search } }),
  });
