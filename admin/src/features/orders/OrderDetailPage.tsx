import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box, VStack, HStack, Heading, Text, Badge, Button,
  SimpleGrid, Table, Thead, Tbody, Tr, Th, Td, Image,
  Select, useToast, useDisclosure,
} from '@chakra-ui/react';
import { FiArrowLeft } from 'react-icons/fi';
import PageHeader from '@/components/common/PageHeader';
import LoadingSpinner from '@/components/common/LoadingSpinner';
import ConfirmDialog from '@/components/common/ConfirmDialog';
import { useOrder, useUpdateOrderStatus } from './orders.api';
import { formatPrice, formatDate, getStatusColor, getErrorMessage } from '@/lib/utils';

interface OrderItem {
  product?: string;
  name?: string;
  image?: string;
  quantity: number;
  price: number;
}

interface OrderDetail {
  _id: string;
  user?: { name: string; email: string };
  shippingAddress?: { fullName?: string; phone?: string; address?: string; city?: string; postalCode?: string };
  orderItems?: OrderItem[];
  totalPrice: number;
  shippingPrice: number;
  taxPrice: number;
  itemsPrice: number;
  status: string;
  isPaid: boolean;
  paidAt?: string;
  paymentMethod: string;
  createdAt: string;
}

export default function OrderDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const toast = useToast();
  const { data, isLoading, refetch } = useOrder(id ?? '');
  const updateStatus = useUpdateOrderStatus();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const [pendingStatus, setPendingStatus] = useState<string | null>(null);

  if (isLoading) return <LoadingSpinner />;

  const order: OrderDetail | null = data?.data?.order ?? null;
  if (!order) return <Text p={6}>Order not found</Text>;

  const statusOptions = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

  const handleStatusSelect = (newStatus: string) => {
    if (newStatus === order.status) return;
    setPendingStatus(newStatus);
    onOpen();
  };

  const confirmStatusChange = async () => {
    if (!pendingStatus) return;
    try {
      await updateStatus.mutateAsync({ id: order._id, status: pendingStatus });
      toast({ title: 'Status updated', status: 'success' });
      refetch();
    } catch (err) {
      toast({ title: getErrorMessage(err, 'Failed to update status'), status: 'error' });
    } finally {
      setPendingStatus(null);
      onClose();
    }
  };

  return (
    <>
      <PageHeader
        title={`Order #${order._id.slice(-6)}`}
        breadcrumbs={[
          { label: 'Orders', href: '/orders' },
          { label: `#${order._id.slice(-6)}` },
        ]}
      />

      <SimpleGrid columns={{ base: 1, lg: 3 }} spacing={5}>
        <VStack spacing={5} align="stretch" gridColumn={{ lg: '1 / 3' }}>
          <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
            <Heading size="sm" mb={4}>Order Items</Heading>
            <Table variant="simple" size="sm">
              <Thead>
                <Tr><Th>Product</Th><Th>Qty</Th><Th isNumeric>Price</Th></Tr>
              </Thead>
              <Tbody>
                {(order.orderItems ?? []).map((item, i) => (
                  <Tr key={`${item.product ?? 'unknown'}-${item.name ?? ''}-${i}`}>
                    <Td>
                      <HStack>
                        {item.image && (
                          <Image src={item.image} boxSize="30px" objectFit="cover" rounded="md" />
                        )}
                        <Text>{item.name || 'Product'}</Text>
                      </HStack>
                    </Td>
                    <Td>{item.quantity}</Td>
                    <Td isNumeric>{formatPrice(item.price)}</Td>
                  </Tr>
                ))}
              </Tbody>
            </Table>
          </Box>
        </VStack>

        <VStack spacing={5} align="stretch">
          <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
            <Heading size="sm" mb={4}>Status</Heading>
            <VStack align="stretch" spacing={3}>
              <HStack justify="space-between">
                <Text fontSize="sm" color="text.muted">Status</Text>
                <Badge colorScheme={getStatusColor(order.status)}>{order.status}</Badge>
              </HStack>
              <HStack justify="space-between">
                <Text fontSize="sm" color="text.muted">Paid</Text>
                <Badge colorScheme={order.isPaid ? 'green' : 'yellow'}>
                  {order.isPaid ? 'Yes' : 'No'}
                </Badge>
              </HStack>
              <HStack justify="space-between">
                <Text fontSize="sm" color="text.muted">Method</Text>
                <Text fontSize="sm">{order.paymentMethod || '-'}</Text>
              </HStack>
              <HStack justify="space-between">
                <Text fontSize="sm" color="text.muted">Date</Text>
                <Text fontSize="sm">{formatDate(order.createdAt)}</Text>
              </HStack>
              <Text fontSize="sm" fontWeight="medium" mt={2}>Update Status</Text>
              <Select
                value={order.status}
                onChange={(e) => handleStatusSelect(e.target.value)}
                size="sm"
                isDisabled={updateStatus.isPending}
              >
                {statusOptions.map((s) => (
                  <option key={s} value={s}>{s.charAt(0).toUpperCase() + s.slice(1)}</option>
                ))}
              </Select>
            </VStack>
          </Box>

          <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
            <Heading size="sm" mb={4}>Summary</Heading>
            <VStack align="stretch" spacing={2}>
              <HStack justify="space-between"><Text fontSize="sm">Subtotal</Text><Text fontSize="sm">{formatPrice(order.itemsPrice)}</Text></HStack>
              <HStack justify="space-between"><Text fontSize="sm">Shipping</Text><Text fontSize="sm">{formatPrice(order.shippingPrice)}</Text></HStack>
              <HStack justify="space-between"><Text fontSize="sm">Tax</Text><Text fontSize="sm">{formatPrice(order.taxPrice)}</Text></HStack>
              <HStack justify="space-between" fontWeight="bold"><Text>Total</Text><Text>{formatPrice(order.totalPrice)}</Text></HStack>
            </VStack>
          </Box>

          {order.user && (
            <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
              <Heading size="sm" mb={4}>Customer</Heading>
              <Text fontSize="sm">{order.user.name}</Text>
              <Text fontSize="xs" color="text.faint">{order.user.email}</Text>
            </Box>
          )}

          {order.shippingAddress && (
            <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
              <Heading size="sm" mb={4}>Shipping Address</Heading>
              <Text fontSize="sm">
                {[
                  order.shippingAddress.fullName,
                  order.shippingAddress.address,
                  order.shippingAddress.city,
                  order.shippingAddress.postalCode,
                  order.shippingAddress.phone,
                ].filter(Boolean).join(', ')}
              </Text>
            </Box>
          )}

          <Button leftIcon={<FiArrowLeft />} variant="ghost" onClick={() => navigate('/orders')}>
            Back to Orders
          </Button>
        </VStack>
      </SimpleGrid>

      <ConfirmDialog
        isOpen={isOpen}
        onClose={() => { setPendingStatus(null); onClose(); }}
        onConfirm={confirmStatusChange}
        title="Update Order Status"
        message={`Change order status to "${pendingStatus}"?`}
        confirmLabel="Update"
        confirmColorScheme="blue"
        isLoading={updateStatus.isPending}
      />
    </>
  );
}
