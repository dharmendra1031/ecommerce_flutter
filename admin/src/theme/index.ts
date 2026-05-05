import { extendTheme, type ThemeConfig } from '@chakra-ui/react';

const config: ThemeConfig = {
  initialColorMode: 'light',
  useSystemColorMode: false,
};

const colors = {
  brand: {
    50: '#e6f0ff',
    100: '#b3d1ff',
    200: '#80b3ff',
    300: '#4d94ff',
    400: '#1a75ff',
    500: '#0066ff',
    600: '#0052cc',
    700: '#003d99',
    800: '#002966',
    900: '#001433',
  },
};

const semanticTokens = {
  colors: {
    'bg.card': {
      default: 'white',
      _dark: 'gray.800',
    },
    'bg.canvas': {
      default: 'gray.50',
      _dark: 'gray.900',
    },
    'bg.surface': {
      default: 'white',
      _dark: 'gray.700',
    },
    'bg.subtle': {
      default: 'gray.50',
      _dark: 'gray.700',
    },
    'border.default': {
      default: 'gray.200',
      _dark: 'gray.600',
    },
    'border.subtle': {
      default: 'gray.100',
      _dark: 'gray.700',
    },
    'text.default': {
      default: 'gray.800',
      _dark: 'gray.100',
    },
    'text.muted': {
      default: 'gray.500',
      _dark: 'gray.400',
    },
    'text.subtle': {
      default: 'gray.600',
      _dark: 'gray.300',
    },
    'text.faint': {
      default: 'gray.400',
      _dark: 'gray.500',
    },
    'icon.muted': {
      default: 'gray.400',
      _dark: 'gray.500',
    },
    'hover.subtle': {
      default: 'gray.100',
      _dark: 'gray.700',
    },
    'active.brand': {
      default: 'brand.50',
      _dark: 'brand.900',
    },
  },
};

const theme = extendTheme({
  config,
  colors,
  semanticTokens,
  fonts: {
    heading: `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`,
    body: `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`,
  },
  styles: {
    global: (props: { colorMode: string }) => ({
      body: {
        bg: props.colorMode === 'dark' ? 'gray.900' : 'gray.50',
        color: props.colorMode === 'dark' ? 'gray.100' : 'gray.800',
      },
    }),
  },
  components: {
    Button: {
      defaultProps: {
        colorScheme: 'brand',
      },
    },
    Table: {
      variants: {
        simple: (props: { colorMode: string }) => ({
          th: {
            borderColor: props.colorMode === 'dark' ? 'gray.600' : 'gray.200',
          },
          td: {
            borderColor: props.colorMode === 'dark' ? 'gray.600' : 'gray.200',
          },
        }),
      },
    },
  },
});

export default theme;
