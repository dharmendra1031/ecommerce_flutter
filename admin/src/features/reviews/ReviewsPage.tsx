import { HStack, Text, Avatar, Icon } from '@chakra-ui/react';
import { FiStar } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import DataTable from '@/components/common/DataTable';
import { useReviews } from './reviews.api';
import { usePagination } from '@/hooks/usePagination';
import { formatDate, truncate } from '@/lib/utils';

interface Review {
  _id: string;
  user?: { name: string; avatar?: { url: string } };
  product?: { name: string };
  rating: number;
  comment: string;
  createdAt: string;
}

export default function ReviewsPage() {
  const { page, limit, search, setPage, setSearch } = usePagination();
  const { data, isLoading } = useReviews(page, limit, search);

  const reviews: Review[] = data?.data?.reviews ?? [];
  const totalPages: number = data?.data?.pagination?.pages ?? 1;

  const columns = [
    {
      header: 'User',
      render: (r: Review) => (
        <HStack>
          <Avatar size="xs" name={r.user?.name} src={r.user?.avatar?.url} />
          <Text fontSize="sm">{r.user?.name || 'N/A'}</Text>
        </HStack>
      ),
    },
    {
      header: 'Product',
      render: (r: Review) => (
        <Text fontSize="sm">{truncate(r.product?.name || 'N/A', 30)}</Text>
      ),
    },
    {
      header: 'Rating',
      render: (r: Review) => (
        <HStack spacing={0}>
          {Array.from({ length: 5 }, (_, i) => (
            <Icon key={i} as={FiStar} boxSize={4} color={i < r.rating ? 'yellow.400' : 'gray.300'} fill={i < r.rating ? 'yellow.400' : 'none'} />
          ))}
        </HStack>
      ),
    },
    {
      header: 'Comment',
      render: (r: Review) => (
        <Text fontSize="sm">{truncate(r.comment, 50)}</Text>
      ),
    },
    {
      header: 'Date',
      render: (r: Review) => formatDate(r.createdAt),
    },
  ];

  return (
    <>
      <PageHeader title="Reviews" />
      <DataTable
        columns={columns}
        data={reviews}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        search={search}
        onSearchChange={setSearch}
        keyExtractor={(r) => r._id}
      />
    </>
  );
}
