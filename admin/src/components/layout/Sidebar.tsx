import {
  Box,
  VStack,
  Text,
  Icon,
  Flex,
  Divider,
  Drawer,
  DrawerBody,
  DrawerOverlay,
  DrawerContent,
  DrawerCloseButton,
  useBreakpointValue,
} from '@chakra-ui/react';
import { useLocation } from 'react-router-dom';
import {
  FiHome,
  FiShoppingBag,
  FiShoppingCart,
  FiUsers,
  FiGrid,
  FiStar,
  FiSettings,
} from 'react-icons/fi';
import { useSidebarStore } from '@/stores/sidebar-store';
import SidebarItem from './SidebarItem';

const navItems = [
  { label: 'Dashboard', icon: FiHome, path: '/dashboard' },
  { label: 'Products', icon: FiShoppingBag, path: '/products' },
  { label: 'Orders', icon: FiShoppingCart, path: '/orders' },
  { label: 'Users', icon: FiUsers, path: '/users' },
  { label: 'Categories', icon: FiGrid, path: '/categories' },
  { label: 'Reviews', icon: FiStar, path: '/reviews' },
];

export default function Sidebar() {
  const { isOpen, onClose } = useSidebarStore();
  const location = useLocation();
  const isMobile = useBreakpointValue({ base: true, lg: false }) ?? false;

  const sidebarContent = (
    <VStack align="stretch" spacing={1}>
      <Flex align="center" px={4} py={5}>
        <Icon as={FiSettings} boxSize={6} color="brand.500" mr={2} />
        <Text fontSize="xl" fontWeight="bold" color="text.default">
          WeStore Admin
        </Text>
      </Flex>
      <Divider borderColor="border.default" />
      <Box px={3} py={3}>
        {navItems.map((item) => (
          <SidebarItem
            key={item.path}
            icon={item.icon}
            label={item.label}
            path={item.path}
            isActive={location.pathname === item.path || location.pathname.startsWith(item.path + '/')}
            onClick={isMobile ? onClose : undefined}
          />
        ))}
      </Box>
    </VStack>
  );

  if (isMobile) {
    return (
      <Drawer isOpen={isOpen} placement="left" onClose={onClose} size="xs">
        <DrawerOverlay />
        <DrawerContent bg="bg.card">
          <DrawerCloseButton />
          <DrawerBody p={0}>{sidebarContent}</DrawerBody>
        </DrawerContent>
      </Drawer>
    );
  }

  return (
    <Box
      as="nav"
      pos="fixed"
      top={0}
      left={0}
      w="260px"
      h="100vh"
      bg="bg.card"
      borderRight="1px"
      borderColor="border.default"
      zIndex={10}
      transform={isOpen ? 'translateX(0)' : 'translateX(-100%)'}
      transition="transform 0.3s"
    >
      {sidebarContent}
    </Box>
  );
}
