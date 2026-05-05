import {
  Box,
  Heading,
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  Badge,
  Link as ChakraLink,
} from '@chakra-ui/react';
import { Link } from 'react-router-dom';
import { formatPrice, formatDate, getStatusColor } from '@/lib/utils';

interface Order {
  _id: string;
  user?: { name: string };
  totalPrice: number;
  status: string;
  createdAt: string;
}

interface RecentOrdersProps {
  orders: Order[];
}

export default function RecentOrders({ orders }: RecentOrdersProps) {
  return (
    <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
      <Heading size="sm" mb={4}>Recent Orders</Heading>
      <Table variant="simple" size="sm">
        <Thead>
          <Tr>
            <Th>Order</Th>
            <Th>Customer</Th>
            <Th>Total</Th>
            <Th>Status</Th>
            <Th>Date</Th>
          </Tr>
        </Thead>
        <Tbody>
          {orders.map((order) => (
            <Tr key={order._id}>
              <Td>
                <ChakraLink as={Link} to={`/orders/${order._id}`} color="brand.500" fontWeight="medium">
                  #{order._id.slice(-6)}
                </ChakraLink>
              </Td>
              <Td>{order.user?.name || 'N/A'}</Td>
              <Td>{formatPrice(order.totalPrice)}</Td>
              <Td>
                <Badge colorScheme={getStatusColor(order.status)}>
                  {order.status}
                </Badge>
              </Td>
              <Td>{formatDate(order.createdAt)}</Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </Box>
  );
}
