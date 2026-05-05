import { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Box,
  Button,
  HStack,
  VStack,
  useToast,
  SimpleGrid,
} from '@chakra-ui/react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { FiSave, FiArrowLeft } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import LoadingSpinner from '@/components/common/LoadingSpinner';
import TextField from '@/components/forms/TextField';
import NumberField from '@/components/forms/NumberField';
import TextAreaField from '@/components/forms/TextAreaField';
import SelectField from '@/components/forms/SelectField';
import ImageUpload from '@/components/forms/ImageUpload';
import { productSchema, type ProductFormData } from './product.schema';
import { getErrorMessage } from '@/lib/utils';
import { useProduct, useCreateProduct, useUpdateProduct } from './products.api';
import { useCategories } from '@/features/categories/categories.api';

export default function ProductFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const toast = useToast();
  const isEdit = !!id;

  const { data: productData, isLoading: productLoading } = useProduct(id ?? '');
  const { data: categoriesData } = useCategories();
  const createProduct = useCreateProduct();
  const updateProduct = useUpdateProduct();

  const { control, handleSubmit, reset, setValue, watch } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    mode: 'onBlur',
    defaultValues: { name: '', description: '', price: 0, stock: 0, brand: '', category: '' },
  });

  const images = watch('images') ?? [];

  useEffect(() => {
    if (isEdit && productData?.data?.product) {
      const p = productData.data.product;
      reset({
        name: p.name,
        description: p.description,
        price: p.price,
        stock: p.stock,
        brand: p.brand || '',
        category: p.category?._id || p.category || '',
        images: p.images || [],
      });
    }
  }, [isEdit, productData, reset]);

  const categoryOptions = (categoriesData?.data?.categories ?? []).map((c: { _id: string; name: string }) => ({
    value: c._id,
    label: c.name,
  }));

  const onSubmit = async (data: ProductFormData) => {
    try {
      if (isEdit) {
        await updateProduct.mutateAsync({ id, data });
        toast({ title: 'Product updated', status: 'success' });
      } else {
        await createProduct.mutateAsync(data);
        toast({ title: 'Product created', status: 'success' });
      }
      navigate('/products');
    } catch (err) {
      toast({ title: getErrorMessage(err, 'Failed to save product'), status: 'error' });
    }
  };

  if (isEdit && productLoading) return <LoadingSpinner />;

  return (
    <>
      <PageHeader
        title={isEdit ? 'Edit Product' : 'New Product'}
        breadcrumbs={[
          { label: 'Products', href: '/products' },
          { label: isEdit ? 'Edit' : 'New' },
        ]}
      />

      <Box bg="bg.card" p={6} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
        <form onSubmit={handleSubmit(onSubmit)}>
          <VStack spacing={5} align="stretch">
            <SimpleGrid columns={{ base: 1, md: 2 }} spacing={5}>
              <TextField name="name" control={control} label="Name" isRequired />
              <SelectField name="category" control={control} label="Category" options={categoryOptions} placeholder="Select a category" isRequired />
              <NumberField name="price" control={control} label="Price" min={0} precision={2} isRequired />
              <NumberField name="stock" control={control} label="Stock" min={0} isRequired />
            </SimpleGrid>

            <TextField name="brand" control={control} label="Brand" />
            <TextAreaField name="description" control={control} label="Description" isRequired />

            <ImageUpload
              images={images}
              onChange={(imgs) => setValue('images', imgs)}
            />

            <HStack justify="flex-end" spacing={3}>
              <Button variant="ghost" leftIcon={<FiArrowLeft />} onClick={() => navigate('/products')}>
                Cancel
              </Button>
              <Button
                type="submit"
                leftIcon={<FiSave />}
                isLoading={createProduct.isPending || updateProduct.isPending}
              >
                {isEdit ? 'Update' : 'Create'} Product
              </Button>
            </HStack>
          </VStack>
        </form>
      </Box>
    </>
  );
}
