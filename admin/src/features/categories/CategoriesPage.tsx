import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { HStack, IconButton, useDisclosure } from '@chakra-ui/react';
import { FiEdit, FiTrash2 } from 'react-icons/fi';
import { getErrorMessage } from '@/lib/utils';
import toast from 'react-hot-toast';
import PageHeader from '@/components/common/PageHeader';
import DataTable from '@/components/common/DataTable';
import ConfirmDialog from '@/components/common/ConfirmDialog';
import { useCategories, useDeleteCategory } from './categories.api';

interface Category {
  _id: string;
  name: string;
  description?: string;
  slug: string;
  parent?: { name: string };
  isActive: boolean;
}

export default function CategoriesPage() {
  const navigate = useNavigate();
  const { data, isLoading } = useCategories();
  const deleteCategory = useDeleteCategory();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [search, setSearch] = useState('');

  const allCategories: Category[] = data?.data?.categories ?? [];
  const filtered = search
    ? allCategories.filter((c) => c.name.toLowerCase().includes(search.toLowerCase()))
    : allCategories;

  const handleDelete = (id: string) => {
    setDeleteId(id);
    onOpen();
  };

  const confirmDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteCategory.mutateAsync(deleteId);
      toast.success('Category deleted');
      onClose();
    } catch (err) {
      toast.error(getErrorMessage(err, 'Failed to delete'));
    }
  };

  const columns = [
    { header: 'Name', accessor: 'name' as const },
    { header: 'Slug', accessor: 'slug' as const },
    { header: 'Parent', render: (c: Category) => c.parent?.name || '-' },
    { header: 'Description', render: (c: Category) => c.description || '-' },
    {
      header: 'Actions',
      render: (c: Category) => (
        <HStack spacing={1}>
          <IconButton
            aria-label="Edit" icon={<FiEdit />} size="xs" variant="ghost"
            onClick={() => navigate(`/categories/${c._id}/edit`)}
          />
          <IconButton
            aria-label="Delete" icon={<FiTrash2 />} size="xs" variant="ghost" colorScheme="red"
            onClick={() => handleDelete(c._id)}
          />
        </HStack>
      ),
    },
  ];

  return (
    <>
      <PageHeader title="Categories" actionLabel="Add Category" actionHref="/categories/new" />
      <DataTable
        columns={columns}
        data={filtered}
        isLoading={isLoading}
        page={1}
        totalPages={1}
        onPageChange={() => {}}
        search={search}
        onSearchChange={(s) => setSearch(s)}
        keyExtractor={(c) => c._id}
      />
      <ConfirmDialog
        isOpen={isOpen}
        onClose={onClose}
        onConfirm={confirmDelete}
        title="Delete Category"
        message="Are you sure you want to delete this category?"
        isLoading={deleteCategory.isPending}
      />
    </>
  );
}
