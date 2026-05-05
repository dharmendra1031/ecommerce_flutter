import {
  Flex,
  HStack,
  IconButton,
  Avatar,
  Menu,
  MenuButton,
  MenuList,
  MenuItem,
  Text,
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  useColorMode,
} from '@chakra-ui/react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { FiMenu, FiMoon, FiSun, FiLogOut, FiUser } from 'react-icons/fi';
import { useSidebarStore } from '@/stores/sidebar-store';
import { useAuthStore } from '@/stores/auth-store';
import { capitalize } from '@/lib/utils';

const routeLabels: Record<string, string> = {
  dashboard: 'Dashboard',
  products: 'Products',
  orders: 'Orders',
  users: 'Users',
  categories: 'Categories',
  reviews: 'Reviews',
};

function Breadcrumbs() {
  const location = useLocation();
  const segments = location.pathname.split('/').filter(Boolean);
  if (segments.length === 0) {
    return (
      <Breadcrumb fontWeight="medium" fontSize="sm" color="text.muted">
        <BreadcrumbItem>
          <BreadcrumbLink as={Link} to="/dashboard">Dashboard</BreadcrumbLink>
        </BreadcrumbItem>
      </Breadcrumb>
    );
  }

  const currentLabel = routeLabels[segments[0]!] ?? capitalize(segments[0]!);
  const isOrderDetail = segments[0] === 'orders' && segments[1] && segments[1] !== 'new';
  const displayLabel = isOrderDetail ? `Order #${segments[1]!.slice(-6)}` : currentLabel;

  return (
    <Breadcrumb fontWeight="medium" fontSize="sm" color="text.muted">
      <BreadcrumbItem>
        <BreadcrumbLink as={Link} to="/dashboard">Home</BreadcrumbLink>
      </BreadcrumbItem>
      {segments.length > 0 && (
        <BreadcrumbItem isCurrentPage>
          <BreadcrumbLink href="#" color="text.default" fontWeight="semibold">
            {displayLabel}
          </BreadcrumbLink>
        </BreadcrumbItem>
      )}
    </Breadcrumb>
  );
}

export default function TopBar() {
  const toggle = useSidebarStore((s) => s.toggle);
  const { user, logout } = useAuthStore();
  const { colorMode, toggleColorMode } = useColorMode();
  const navigate = useNavigate();

  return (
    <Flex
      as="header"
      align="center"
      justify="space-between"
      px={6}
      py={3}
      bg="bg.card"
      borderBottom="1px"
      borderColor="border.default"
    >
      <HStack spacing={4}>
        <IconButton
          aria-label="Toggle sidebar"
          icon={<FiMenu />}
          variant="ghost"
          onClick={toggle}
        />
        <Breadcrumbs />
      </HStack>

      <HStack spacing={3}>
        <IconButton
          aria-label="Toggle color mode"
          icon={colorMode === 'light' ? <FiMoon /> : <FiSun />}
          variant="ghost"
          onClick={toggleColorMode}
        />
        <Menu>
          <MenuButton>
            <HStack spacing={2}>
              <Avatar size="sm" name={user?.name} src={user?.avatar?.url} />
              <Text fontSize="sm" fontWeight="medium" display={{ base: 'none', md: 'block' }}>
                {user?.name}
              </Text>
            </HStack>
          </MenuButton>
          <MenuList>
            <MenuItem icon={<FiUser />} onClick={() => navigate('/profile')}>Profile</MenuItem>
            <MenuItem icon={<FiLogOut />} onClick={logout} color="red.500">
              Logout
            </MenuItem>
          </MenuList>
        </Menu>
      </HStack>
    </Flex>
  );
}
