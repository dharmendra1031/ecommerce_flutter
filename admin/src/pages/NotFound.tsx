import { Center, VStack, Heading, Text, Button } from '@chakra-ui/react';
import { Link } from 'react-router-dom';

export default function NotFound() {
  return (
    <Center h="100vh">
      <VStack spacing={4}>
        <Heading size="4xl" color="text.faint">404</Heading>
        <Text fontSize="lg" color="text.muted">Page not found</Text>
        <Button as={Link} to="/dashboard" colorScheme="brand" size="sm">
          Go to Dashboard
        </Button>
      </VStack>
    </Center>
  );
}
