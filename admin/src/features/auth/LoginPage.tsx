import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  Flex,
  Heading,
  Input,
  VStack,
  Text,
  useToast,
} from '@chakra-ui/react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuthStore } from '@/stores/auth-store';
import { loginSchema, type LoginFormData } from './auth.schema';
import { useEffect } from 'react';

export default function LoginPage() {
  const navigate = useNavigate();
  const toast = useToast();
  const { login, accessToken, user } = useAuthStore();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    mode: 'onBlur',
  });

  useEffect(() => {
    if (accessToken && user) {
      navigate('/dashboard', { replace: true });
    }
  }, [accessToken, user, navigate]);

  const onSubmit = async (data: LoginFormData) => {
    try {
      await login(data.email, data.password);
      toast({ title: 'Login successful', status: 'success', duration: 2000 });
      navigate('/dashboard', { replace: true });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Login failed';
      toast({ title: message, status: 'error', duration: 3000 });
    }
  };

  return (
    <Flex minH="100vh" align="center" justify="center" bg="bg.canvas">
      <Box bg="bg.card" p={8} rounded="xl" shadow="lg" w="full" maxW="md">
        <VStack spacing={6} align="stretch">
          <VStack spacing={2}>
            <Heading size="lg" textAlign="center">WeStore Admin</Heading>
            <Text color="text.muted" textAlign="center">Sign in to your admin account</Text>
          </VStack>

          <form onSubmit={handleSubmit(onSubmit)}>
            <VStack spacing={4}>
              <Box w="full">
                <Text fontSize="sm" fontWeight="medium" mb={1}>Email</Text>
                <Input
                  {...register('email')}
                  type="email"
                  placeholder="admin@westore.com"
                  size="lg"
                  isInvalid={!!errors.email}
                />
                {errors.email && (
                  <Text color="red.500" fontSize="xs" mt={1}>{errors.email.message}</Text>
                )}
              </Box>

              <Box w="full">
                <Text fontSize="sm" fontWeight="medium" mb={1}>Password</Text>
                <Input
                  {...register('password')}
                  type="password"
                  placeholder="Enter your password"
                  size="lg"
                  isInvalid={!!errors.password}
                />
                {errors.password && (
                  <Text color="red.500" fontSize="xs" mt={1}>{errors.password.message}</Text>
                )}
              </Box>

              <Button
                type="submit"
                w="full"
                size="lg"
                isLoading={isSubmitting}
                loadingText="Signing in..."
              >
                Sign In
              </Button>
            </VStack>
          </form>

          <Text fontSize="xs" color="text.faint" textAlign="center">
            Default: admin@westore.com / password123
          </Text>
        </VStack>
      </Box>
    </Flex>
  );
}
