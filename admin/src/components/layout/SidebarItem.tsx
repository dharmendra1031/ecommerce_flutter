import { HStack, Icon, Text } from '@chakra-ui/react';
import { Link } from 'react-router-dom';
import { type IconType } from 'react-icons';

interface SidebarItemProps {
  icon: IconType;
  label: string;
  path: string;
  isActive: boolean;
  onClick?: () => void;
}

export default function SidebarItem({ icon, label, path, isActive, onClick }: SidebarItemProps) {
  return (
    <Link to={path} onClick={onClick}>
      <HStack
        px={3}
        py={2.5}
        borderRadius="lg"
        bg={isActive ? 'active.brand' : 'transparent'}
        color={isActive ? 'brand.600' : 'text.subtle'}
        _hover={{
          bg: isActive ? 'active.brand' : 'hover.subtle',
          color: isActive ? 'brand.600' : 'text.default',
        }}
        transition="all 0.2s"
        cursor="pointer"
        fontWeight={isActive ? 'semibold' : 'normal'}
      >
        <Icon as={icon} boxSize={5} />
        <Text fontSize="sm">{label}</Text>
      </HStack>
    </Link>
  );
}
