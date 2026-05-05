import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { HStack, Badge, Image, Text, IconButton, useDisclosure, Select } from '@chakra-ui/react';
import { FiEdit, FiTrash2, FiDownload } from 'react-icons/fi';
import toast from 'react-hot-toast';
import PageHeader from '@/components/common/PageHeader';
import DataTable from '@/components/common/DataTable';
import ConfirmDialog from '@/components/common/ConfirmDialog';
import { useProducts, useDeleteProduct } from './products.api';
import { useCategories } from '@/features/categories/categories.api';
import { usePagination } from '@/hooks/usePagination';
import { formatPrice, truncate, exportToCsv } from '@/lib/utils';

interface Product {
  _id: string;
  name: string;
  price: number;
  stock: number;
  category?: { name: string; _id: string };
  images?: { url: string; public_id: string }[];
  isActive: boolean;
}

export default function ProductsPage() {
  const navigate = useNavigate();
  const { page, limit, search, setPage, setSearch } = usePagination();
  const [categoryFilter, setCategoryFilter] = useState('');
  const [stockFilter, setStockFilter] = useState('');
  const { data: productsData, isLoading } = useProducts(page, limit, search, categoryFilter || undefined, stockFilter || undefined);
  const { data: categoriesData } = useCategories();
  const deleteProduct = useDeleteProduct();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const products: Product[] = productsData?.data?.products ?? [];
  const totalPages: number = productsData?.data?.pagination?.pages ?? 1;

  const handleExport = () => {
    exportToCsv(products, 'products', [
      { key: 'name', label: 'Name' },
      { key: 'price', label: 'Price' },
      { key: 'stock', label: 'Stock' },
      { key: 'isActive', label: 'Status' },
    ]);
  };

  const handleDelete = (id: string) => {
    setDeleteId(id);
    onOpen();
  };

  const confirmDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteProduct.mutateAsync(deleteId);
      toast.success('Product deleted');
      onClose();
    } catch {
      toast.error('Failed to delete');
    }
  };

  const columns = [
    {
      header: 'Image',
      render: (p: Product) =>
        p.images?.[0] ? (
          <Image src={p.images[0].url} boxSize="40px" objectFit="cover" rounded="md" />
        ) : (
          <Text color="gray.400" fontSize="xs">No image</Text>
        ),
    },
    { header: 'Name', render: (p: Product) => truncate(p.name, 40) },
    { header: 'Price', render: (p: Product) => formatPrice(p.price) },
    { header: 'Stock', render: (p: Product) => <Text color={p.stock < 10 ? 'red.500' : 'inherit'}>{p.stock}</Text> },
    { header: 'Category', render: (p: Product) => p.category?.name || '-' },
    {
      header: 'Status',
      render: (p: Product) => (
        <Badge colorScheme={p.isActive ? 'green' : 'red'}>{p.isActive ? 'Active' : 'Inactive'}</Badge>
      ),
    },
    {
      header: 'Actions',
      render: (p: Product) => (
        <HStack spacing={1}>
          <IconButton
            aria-label="Edit" icon={<FiEdit />} size="xs" variant="ghost"
            onClick={() => navigate(`/products/${p._id}/edit`)}
          />
          <IconButton
            aria-label="Delete" icon={<FiTrash2 />} size="xs" variant="ghost" colorScheme="red"
            onClick={() => handleDelete(p._id)}
          />
        </HStack>
      ),
    },
  ];

  return (
    <>
      <PageHeader title="Products" actionLabel="Add Product" actionHref="/products/new" />
      <HStack mb={4} spacing={3} wrap="wrap">
        <Select
          maxW="200px"
          size="sm"
          value={categoryFilter}
          onChange={(e) => { setCategoryFilter(e.target.value); setPage(1); }}
          placeholder="All Categories"
        >
          {(categoriesData?.data?.categories ?? []).map((c: { _id: string; name: string }) => (
            <option key={c._id} value={c._id}>{c.name}</option>
          ))}
        </Select>
        <Select
          maxW="180px"
          size="sm"
          value={stockFilter}
          onChange={(e) => { setStockFilter(e.target.value); setPage(1); }}
          placeholder="All Stock"
        >
          <option value="in">In Stock</option>
          <option value="low">Low Stock (&lt;10)</option>
          <option value="out">Out of Stock</option>
        </Select>
        <IconButton
          aria-label="Export CSV"
          icon={<FiDownload />}
          size="sm"
          variant="outline"
          onClick={handleExport}
          isDisabled={products.length === 0}
        />
      </HStack>
      <DataTable
        columns={columns}
        data={products}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        search={search}
        onSearchChange={setSearch}
        keyExtractor={(p) => p._id}
      />
      <ConfirmDialog
        isOpen={isOpen}
        onClose={onClose}
        onConfirm={confirmDelete}
        title="Delete Product"
        message="Are you sure you want to delete this product? This action cannot be undone."
        isLoading={deleteProduct.isPending}
      />
    </>
  );
}
