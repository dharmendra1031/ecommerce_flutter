import api from '@/lib/axios';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { type ProfileFormData } from './profile.schema';

export const useProfile = () =>
  useQuery({
    queryKey: ['profile'],
    queryFn: () => api.get('/users/profile'),
  });

export const useUpdateProfile = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: ProfileFormData) => api.put('/users/profile', data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['profile'] }),
  });
};
