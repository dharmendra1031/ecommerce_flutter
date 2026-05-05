import { Component, type ErrorInfo, type ReactNode } from 'react';
import { Center, VStack, Heading, Text, Button, Icon } from '@chakra-ui/react';
import { FiAlertTriangle } from 'react-icons/fi';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export default class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <Center minH="100vh" bg="bg.canvas">
          <VStack spacing={4} textAlign="center" p={8}>
            <Icon as={FiAlertTriangle} boxSize={12} color="red.400" />
            <Heading size="md">Something went wrong</Heading>
            <Text color="text.muted" maxW="md">
              {this.state.error?.message ?? 'An unexpected error occurred.'}
            </Text>
            <Button onClick={() => this.setState({ hasError: false, error: null })}>
              Try Again
            </Button>
          </VStack>
        </Center>
      );
    }

    return this.props.children;
  }
}
