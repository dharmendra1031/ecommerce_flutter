import { useEffect } from 'react';
import { Navigate } from 'react-router-dom';
import { useAuthStore } from '@/stores/auth-store';
import { Center, Spinner } from '@chakra-ui/react';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export default function ProtectedRoute({ children }: ProtectedRouteProps) {
  const { accessToken, user, fetchMe, isLoading } = useAuthStore();

  useEffect(() => {
    if (accessToken && !user) {
      fetchMe();
    }
  }, [accessToken, user, fetchMe]);

  if (!accessToken) {
    return <Navigate to="/login" replace />;
  }

  if (isLoading || !user) {
    return (
      <Center h="100vh">
        <Spinner size="xl" color="brand.500" />
      </Center>
    );
  }

  if (user.role !== 'admin') {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
}
