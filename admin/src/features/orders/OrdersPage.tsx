import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Badge, Text, IconButton, Select, HStack } from '@chakra-ui/react';
import { FiEye, FiDownload } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import DataTable from '@/components/common/DataTable';
import { useOrders } from './orders.api';
import { usePagination } from '@/hooks/usePagination';
import { formatPrice, formatDate, getStatusColor, exportToCsv } from '@/lib/utils';

interface Order {
  _id: string;
  user?: { name: string; email: string };
  totalPrice: number;
  status: string;
  isPaid: boolean;
  createdAt: string;
}

export default function OrdersPage() {
  const navigate = useNavigate();
  const { page, limit, search, setPage, setSearch } = usePagination();
  const [statusFilter, setStatusFilter] = useState('');
  const { data, isLoading } = useOrders(page, limit, search, statusFilter || undefined);

  const orders: Order[] = data?.data?.orders ?? [];
  const totalPages: number = data?.data?.pagination?.pages ?? 1;

  const handleExport = () => {
    exportToCsv(orders, 'orders', [
      { key: '_id', label: 'Order ID' },
      { key: 'totalPrice', label: 'Total' },
      { key: 'status', label: 'Status' },
      { key: 'isPaid', label: 'Paid' },
      { key: 'createdAt', label: 'Date' },
    ]);
  };

  const columns = [
    {
      header: 'Order #',
      render: (o: Order) => (
        <Text fontWeight="medium" color="brand.500" cursor="pointer" onClick={() => navigate(`/orders/${o._id}`)}>
          #{o._id.slice(-6)}
        </Text>
      ),
    },
    { header: 'Customer', render: (o: Order) => o.user?.name || 'N/A' },
    { header: 'Total', render: (o: Order) => formatPrice(o.totalPrice) },
    {
      header: 'Status',
      render: (o: Order) => (
        <Badge colorScheme={getStatusColor(o.status)}>{o.status}</Badge>
      ),
    },
    {
      header: 'Paid',
      render: (o: Order) => (
        <Badge colorScheme={o.isPaid ? 'green' : 'yellow'}>{o.isPaid ? 'Yes' : 'No'}</Badge>
      ),
    },
    { header: 'Date', render: (o: Order) => formatDate(o.createdAt) },
    {
      header: 'Actions',
      render: (o: Order) => (
        <IconButton
          aria-label="View order" icon={<FiEye />} size="xs" variant="ghost"
          onClick={() => navigate(`/orders/${o._id}`)}
        />
      ),
    },
  ];

  return (
    <>
      <PageHeader title="Orders" />
      <HStack mb={4} spacing={3}>
        <Select
          maxW="200px"
          size="sm"
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
          placeholder="All Statuses"
        >
          <option value="pending">Pending</option>
          <option value="processing">Processing</option>
          <option value="shipped">Shipped</option>
          <option value="delivered">Delivered</option>
          <option value="cancelled">Cancelled</option>
        </Select>
        <IconButton
          aria-label="Export CSV"
          icon={<FiDownload />}
          size="sm"
          variant="outline"
          onClick={handleExport}
          isDisabled={orders.length === 0}
        />
      </HStack>
      <DataTable
        columns={columns}
        data={orders}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        search={search}
        onSearchChange={setSearch}
        keyExtractor={(o) => o._id}
      />
    </>
  );
}
