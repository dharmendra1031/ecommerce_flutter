import { SimpleGrid, Heading, VStack } from '@chakra-ui/react';
import { useQuery } from '@tanstack/react-query';
import { FiShoppingBag, FiShoppingCart, FiUsers, FiDollarSign } from 'react-icons/fi';
import StatCard from '@/components/common/StatCard';
import LoadingSpinner from '@/components/common/LoadingSpinner';
import RevenueChart from './RevenueChart';
import RecentOrders from './RecentOrders';
import { dashboardApi } from './dashboard.api';
import { formatPrice } from '@/lib/utils';

interface DashboardData {
  totalUsers: number;
  totalProducts: number;
  totalOrders: number;
  totalRevenue: number;
  recentOrders: Order[];
  revenueTrend: { date: string; revenue: number; orders: number }[];
}

interface Order {
  _id: string;
  user?: { name: string };
  totalPrice: number;
  status: string;
  createdAt: string;
}

export default function DashboardPage() {
  const { data: statsData, isLoading } = useQuery({
    queryKey: ['dashboard', 'stats'],
    queryFn: () => dashboardApi.getStats(),
  });

  const { data: ordersData } = useQuery({
    queryKey: ['dashboard', 'recent-orders'],
    queryFn: () => dashboardApi.getRecentOrders(),
  });

  if (isLoading) return <LoadingSpinner />;

  const stats: DashboardData = statsData?.data ?? {
    totalUsers: 0, totalProducts: 0, totalOrders: 0, totalRevenue: 0,
    recentOrders: [], revenueTrend: [],
  };
  const orders: Order[] = ordersData?.data?.orders ?? stats.recentOrders ?? [];

  const chartData = (stats.revenueTrend?.length > 0)
    ? stats.revenueTrend.slice(-14).map((d) => ({
        name: d.date.slice(5),
        revenue: d.revenue,
        orders: d.orders,
      }))
    : [
        { name: 'Jan', revenue: 0, orders: 0 },
        { name: 'Feb', revenue: 0, orders: 0 },
        { name: 'Mar', revenue: 0, orders: 0 },
      ];

  return (
    <VStack spacing={6} align="stretch">
      <Heading size="lg">Dashboard</Heading>

      <SimpleGrid columns={{ base: 1, md: 2, lg: 4 }} spacing={4}>
        <StatCard label="Total Revenue" value={formatPrice(stats.totalRevenue)} icon={FiDollarSign} colorScheme="green" />
        <StatCard label="Total Orders" value={stats.totalOrders} icon={FiShoppingCart} colorScheme="blue" />
        <StatCard label="Total Products" value={stats.totalProducts} icon={FiShoppingBag} colorScheme="purple" />
        <StatCard label="Total Users" value={stats.totalUsers} icon={FiUsers} colorScheme="orange" />
      </SimpleGrid>

      <RevenueChart data={chartData} />

      {orders.length > 0 && <RecentOrders orders={orders} />}
    </VStack>
  );
}
