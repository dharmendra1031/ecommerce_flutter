import { useEffect, useRef } from 'react';
import toast from 'react-hot-toast';
import { useAuthStore } from '@/stores/auth-store';
import { navigateTo } from '@/lib/navigation';

export function useSessionTimeout() {
  const warningShown = useRef(false);
  const accessToken = useAuthStore((s) => s.accessToken);

  useEffect(() => {
    if (!accessToken) {
      warningShown.current = false;
      return;
    }

    let payload: string | undefined;
    try {
      payload = accessToken.split('.')[1];
      if (!payload) return;
      const decoded = JSON.parse(atob(payload));
      const exp: number | undefined = decoded.exp;
      if (!exp) return;

      const now = Date.now() / 1000;
      const timeLeft = exp - now;

      if (timeLeft <= 0) {
        useAuthStore.getState().logout();
        navigateTo('/login', { replace: true });
        return;
      }

      const warningTime = 5 * 60;
      if (timeLeft <= warningTime && !warningShown.current) {
        warningShown.current = true;
        const mins = Math.floor(timeLeft / 60);
        toast.error(`Session expires in ${mins} minute${mins !== 1 ? 's' : ''}. Please save your work.`, { duration: 10000 });
      } else if (timeLeft > warningTime) {
        warningShown.current = false;
      }
    } catch {
    }
  }, [accessToken]);
}
