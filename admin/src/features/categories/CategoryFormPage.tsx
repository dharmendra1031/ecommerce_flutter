import { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { Box, Button, HStack, VStack, useToast } from '@chakra-ui/react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { FiSave, FiArrowLeft } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import LoadingSpinner from '@/components/common/LoadingSpinner';
import TextField from '@/components/forms/TextField';
import TextAreaField from '@/components/forms/TextAreaField';
import SelectField from '@/components/forms/SelectField';
import ImageUpload from '@/components/forms/ImageUpload';
import { categorySchema, type CategoryFormData } from './category.schema';
import { useCategory, useCreateCategory, useUpdateCategory, useCategories } from './categories.api';
import { getErrorMessage } from '@/lib/utils';

export default function CategoryFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const toast = useToast();
  const isEdit = !!id;

  const { data: categoryData, isLoading } = useCategory(id ?? '');
  const { data: allCategories } = useCategories();
  const createCategory = useCreateCategory();
  const updateCategory = useUpdateCategory();

  const { control, handleSubmit, reset, setValue, watch } = useForm<CategoryFormData>({
    resolver: zodResolver(categorySchema),
    mode: 'onBlur',
    defaultValues: { name: '', description: '', image: [], parent: '' },
  });

  const images = watch('image') ?? [];

  useEffect(() => {
    if (isEdit && categoryData?.data?.category) {
      const c = categoryData.data.category;
      reset({
        name: c.name,
        description: c.description || '',
        image: c.image ? [c.image] : [],
        parent: c.parent?._id || '',
      });
    }
  }, [isEdit, categoryData, reset]);

  const parentOptions = [
    { value: '', label: 'None (Root Category)' },
    ...((allCategories?.data?.categories ?? [])
      .filter((c: { _id: string }) => c._id !== id)
      .map((c: { _id: string; name: string }) => ({ value: c._id, label: c.name }))),
  ];

  const onSubmit = async (data: CategoryFormData) => {
    try {
      const payload = {
        ...data,
        image: data.image?.[0] ?? null,
        parent: data.parent || undefined,
      };
      if (isEdit) {
        await updateCategory.mutateAsync({ id, data: payload });
        toast({ title: 'Category updated', status: 'success' });
      } else {
        await createCategory.mutateAsync(payload);
        toast({ title: 'Category created', status: 'success' });
      }
      navigate('/categories');
    } catch (err) {
      toast({ title: getErrorMessage(err, 'Failed to save category'), status: 'error' });
    }
  };

  if (isEdit && isLoading) return <LoadingSpinner />;

  return (
    <>
      <PageHeader
        title={isEdit ? 'Edit Category' : 'New Category'}
        breadcrumbs={[
          { label: 'Categories', href: '/categories' },
          { label: isEdit ? 'Edit' : 'New' },
        ]}
      />

      <Box bg="bg.card" p={6} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
        <form onSubmit={handleSubmit(onSubmit)}>
          <VStack spacing={5} align="stretch" maxW="600px">
            <TextField name="name" control={control} label="Name" isRequired />
            <TextAreaField name="description" control={control} label="Description" rows={3} />
            <SelectField name="parent" control={control} label="Parent Category" options={parentOptions} placeholder="Select parent (optional)" />

            <ImageUpload
              images={images}
              onChange={(imgs) => setValue('image', imgs)}
              maxFiles={1}
            />

            <HStack justify="flex-end" spacing={3}>
              <Button variant="ghost" leftIcon={<FiArrowLeft />} onClick={() => navigate('/categories')}>
                Cancel
              </Button>
              <Button
                type="submit"
                leftIcon={<FiSave />}
                isLoading={createCategory.isPending || updateCategory.isPending}
              >
                {isEdit ? 'Update' : 'Create'} Category
              </Button>
            </HStack>
          </VStack>
        </form>
      </Box>
    </>
  );
}
