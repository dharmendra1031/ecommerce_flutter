import { Center, VStack, Icon, Text, Button } from '@chakra-ui/react';
import { FiInbox } from 'react-icons/fi';

interface EmptyStateProps {
  title?: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
}

export default function EmptyState({
  title = 'No data found',
  description = 'There is nothing to display here yet.',
  actionLabel,
  onAction,
}: EmptyStateProps) {
  return (
    <Center py={20}>
      <VStack spacing={3}>
        <Icon as={FiInbox} boxSize={12} color="icon.muted" />
        <Text fontWeight="semibold" color="text.subtle">{title}</Text>
        <Text fontSize="sm" color="text.faint">{description}</Text>
        {actionLabel && onAction && (
          <Button size="sm" colorScheme="brand" onClick={onAction}>{actionLabel}</Button>
        )}
      </VStack>
    </Center>
  );
}
