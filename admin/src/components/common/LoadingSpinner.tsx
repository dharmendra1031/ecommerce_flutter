import { Center, Spinner, Text, VStack } from '@chakra-ui/react';

export default function LoadingSpinner() {
  return (
    <Center py={20}>
      <VStack spacing={3}>
        <Spinner size="xl" color="brand.500" thickness="3px" />
        <Text color="text.muted" fontSize="sm">Loading...</Text>
      </VStack>
    </Center>
  );
}
