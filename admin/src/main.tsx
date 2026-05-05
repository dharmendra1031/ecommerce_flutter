import React from 'react';
import ReactDOM from 'react-dom/client';
import { ChakraProvider, localStorageManager } from '@chakra-ui/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter, useNavigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { setNavigate } from '@/lib/navigation';
import theme from '@/theme';
import App from '@/App';
import '@/index.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000,
    },
  },
});

function Root() {
  const navigate = useNavigate();
  React.useEffect(() => {
    setNavigate((path, options) => navigate(path, options as any));
  }, [navigate]);

  return (
    <>
      <App />
      <Toaster position="top-right" />
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ChakraProvider theme={theme} colorModeManager={localStorageManager}>
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <Root />
        </BrowserRouter>
      </QueryClientProvider>
    </ChakraProvider>
  </React.StrictMode>
);
