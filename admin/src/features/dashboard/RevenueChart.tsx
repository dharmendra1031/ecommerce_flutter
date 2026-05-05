import { Box, Heading, useColorMode } from '@chakra-ui/react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';

interface RevenueChartProps {
  data: { name: string; revenue: number; orders: number }[];
}

export default function RevenueChart({ data }: RevenueChartProps) {
  const { colorMode } = useColorMode();
  const isDark = colorMode === 'dark';

  return (
    <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
      <Heading size="sm" mb={4}>Revenue Overview</Heading>
      <ResponsiveContainer width="100%" height={250}>
        <AreaChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke={isDark ? '#4A5568' : '#E2E8F0'} />
          <XAxis dataKey="name" fontSize={12} stroke={isDark ? '#A0AEC0' : '#718096'} />
          <YAxis
            yAxisId="left"
            fontSize={12}
            stroke={isDark ? '#A0AEC0' : '#718096'}
            tickFormatter={(v: number) => `$${v >= 1000 ? `${(v / 1000).toFixed(0)}k` : v}`}
          />
          <YAxis
            yAxisId="right"
            orientation="right"
            fontSize={12}
            stroke={isDark ? '#A0AEC0' : '#718096'}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: isDark ? '#2D3748' : '#FFFFFF',
              borderColor: isDark ? '#4A5568' : '#E2E8F0',
              color: isDark ? '#E2E8F0' : '#1A202C',
              borderRadius: '8px',
            }}
          />
          <Legend />
          <Area
            yAxisId="left"
            type="monotone"
            dataKey="revenue"
            name="Revenue"
            stroke="#0066ff"
            fill={isDark ? '#003d99' : '#e6f0ff'}
            strokeWidth={2}
          />
          <Area
            yAxisId="right"
            type="monotone"
            dataKey="orders"
            name="Orders"
            stroke="#38a169"
            fill={isDark ? '#22543d' : '#c6f6d5'}
            strokeWidth={2}
          />
        </AreaChart>
      </ResponsiveContainer>
    </Box>
  );
}
