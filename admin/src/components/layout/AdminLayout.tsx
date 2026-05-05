import { Outlet } from 'react-router-dom';
import { Box, Flex } from '@chakra-ui/react';
import Sidebar from './Sidebar';
import TopBar from './TopBar';
import { useSidebarStore } from '@/stores/sidebar-store';

export default function AdminLayout() {
  const isOpen = useSidebarStore((s) => s.isOpen);

  return (
    <Flex h="100vh" overflow="hidden">
      <Sidebar />
      <Box
        flex="1"
        ml={isOpen ? '260px' : '0'}
        transition="margin-left 0.3s"
        overflow="hidden"
        display="flex"
        flexDirection="column"
      >
        <TopBar />
        <Box
          flex="1"
          overflowY="auto"
          p={6}
          bg="bg.canvas"
        >
          <Outlet />
        </Box>
      </Box>
    </Flex>
  );
}
