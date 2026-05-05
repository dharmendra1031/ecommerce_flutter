import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Button, HStack, VStack, Text, Avatar, Heading, useToast } from '@chakra-ui/react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { FiSave, FiArrowLeft } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import LoadingSpinner from '@/components/common/LoadingSpinner';
import TextField from '@/components/forms/TextField';
import { profileSchema, type ProfileFormData } from './profile.schema';
import { useProfile, useUpdateProfile } from './profile.api';
import { getErrorMessage } from '@/lib/utils';
import { useAuthStore } from '@/stores/auth-store';

export default function ProfilePage() {
  const navigate = useNavigate();
  const toast = useToast();
  const { data, isLoading } = useProfile();
  const updateProfile = useUpdateProfile();
  const user = useAuthStore((s) => s.user);

  const { control, handleSubmit, reset, formState: { isSubmitting } } = useForm<ProfileFormData>({
    resolver: zodResolver(profileSchema),
    mode: 'onBlur',
    defaultValues: { name: '', phone: '' },
  });

  useEffect(() => {
    if (data?.data?.user) {
      const u = data.data.user;
      reset({ name: u.name, phone: u.phone || '' });
    }
  }, [data, reset]);

  const onSubmit = async (formData: ProfileFormData) => {
    try {
      await updateProfile.mutateAsync(formData);
      toast({ title: 'Profile updated', status: 'success' });
    } catch (err) {
      toast({ title: getErrorMessage(err, 'Failed to update profile'), status: 'error' });
    }
  };

  if (isLoading) return <LoadingSpinner />;

  return (
    <>
      <PageHeader
        title="Profile"
        breadcrumbs={[{ label: 'Profile' }]}
      />

      <Box bg="bg.card" p={6} rounded="lg" shadow="sm" border="1px" borderColor="border.default" maxW="600px">
        <VStack spacing={6} align="stretch">
          <HStack spacing={4}>
            <Avatar size="xl" name={user?.name} src={user?.avatar?.url} />
            <VStack align="start" spacing={0}>
              <Heading size="md">{user?.name}</Heading>
              <Text color="text.muted" fontSize="sm">{user?.email}</Text>
            </VStack>
          </HStack>

          <form onSubmit={handleSubmit(onSubmit)}>
            <VStack spacing={5} align="stretch">
              <TextField name="name" control={control} label="Name" isRequired />
              <TextField name="phone" control={control} label="Phone" placeholder="+1234567890" />

              <Box>
                <Text fontSize="sm" fontWeight="medium" mb={1}>Email</Text>
                <Text fontSize="sm" color="text.muted" py={2}>{user?.email}</Text>
              </Box>

              <HStack justify="flex-end" spacing={3}>
                <Button variant="ghost" leftIcon={<FiArrowLeft />} onClick={() => navigate(-1)}>
                  Back
                </Button>
                <Button
                  type="submit"
                  leftIcon={<FiSave />}
                  isLoading={isSubmitting || updateProfile.isPending}
                >
                  Save Changes
                </Button>
              </HStack>
            </VStack>
          </form>
        </VStack>
      </Box>
    </>
  );
}
