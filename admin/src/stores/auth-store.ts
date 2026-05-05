import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import api from '@/lib/axios';
import { navigateTo } from '@/lib/navigation';

let onAuthError: ((message: string) => void) | null = null;
export const setAuthErrorHandler = (handler: (message: string) => void) => {
  onAuthError = handler;
};

interface User {
  id: string;
  name: string;
  email: string;
  role: 'user' | 'admin';
  avatar?: { public_id: string; url: string };
  isEmailVerified: boolean;
}

interface AuthState {
  user: User | null;
  accessToken: string | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  fetchMe: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      isLoading: false,

      login: async (email: string, password: string) => {
        const res = await api.post('/auth/login', { email, password });
        const { user, accessToken } = res.data;
        if (user.role !== 'admin') {
          throw new Error('Access denied. Admin role required.');
        }
        set({ user, accessToken });
      },

      logout: () => {
        set({ user: null, accessToken: null });
        navigateTo('/login', { replace: true });
      },

      fetchMe: async () => {
        const token = get().accessToken;
        if (!token) return;
        set({ isLoading: true });
        try {
          const res = await api.get('/auth/me');
          set({ user: res.data.user, isLoading: false });
        } catch {
          set({ user: null, accessToken: null, isLoading: false });
          onAuthError?.('Session expired. Please log in again.');
        }
      },
    }),
    {
      name: 'westore-admin-auth',
      partialize: (state) => ({ accessToken: state.accessToken }),
    }
  )
);
