import { Badge, Avatar, HStack, Text } from '@chakra-ui/react';
import PageHeader from '@/components/common/PageHeader';
import DataTable from '@/components/common/DataTable';
import { useUsers } from './users.api';
import { usePagination } from '@/hooks/usePagination';
import { formatDate } from '@/lib/utils';

interface User {
  _id: string;
  name: string;
  email: string;
  role: string;
  avatar?: { url: string };
  isEmailVerified: boolean;
  createdAt: string;
}

export default function UsersPage() {
  const { page, limit, search, setPage, setSearch } = usePagination();
  const { data, isLoading } = useUsers(page, limit, search);

  const users: User[] = data?.data?.users ?? [];
  const totalPages: number = data?.data?.pagination?.pages ?? 1;

  const columns = [
    {
      header: 'User',
      render: (u: User) => (
        <HStack>
          <Avatar size="sm" name={u.name} src={u.avatar?.url} />
          <Text fontWeight="medium">{u.name}</Text>
        </HStack>
      ),
    },
    { header: 'Email', accessor: 'email' as const },
    {
      header: 'Role',
      render: (u: User) => (
        <Badge colorScheme={u.role === 'admin' ? 'purple' : 'gray'}>{u.role}</Badge>
      ),
    },
    {
      header: 'Verified',
      render: (u: User) => (
        <Badge colorScheme={u.isEmailVerified ? 'green' : 'yellow'}>
          {u.isEmailVerified ? 'Yes' : 'No'}
        </Badge>
      ),
    },
    {
      header: 'Joined',
      render: (u: User) => formatDate(u.createdAt),
    },
  ];

  return (
    <>
      <PageHeader title="Users" />
      <DataTable
        columns={columns}
        data={users}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        search={search}
        onSearchChange={setSearch}
        keyExtractor={(u) => u._id}
      />
    </>
  );
}
