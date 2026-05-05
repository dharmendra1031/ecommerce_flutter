import { Box, Flex, Stat, StatLabel, StatNumber, StatHelpText, Icon } from '@chakra-ui/react';
import { type IconType } from 'react-icons';

interface StatCardProps {
  label: string;
  value: string | number;
  helpText?: string;
  icon: IconType;
  colorScheme?: string;
}

export default function StatCard({ label, value, helpText, icon, colorScheme = 'brand' }: StatCardProps) {
  return (
    <Box bg="bg.card" p={5} rounded="lg" shadow="sm" border="1px" borderColor="border.default">
      <Flex justify="space-between" align="flex-start">
        <Stat>
          <StatLabel fontSize="sm" color="text.muted" fontWeight="medium">{label}</StatLabel>
          <StatNumber fontSize="2xl" fontWeight="bold" mt={1}>{value}</StatNumber>
          {helpText && (
            <StatHelpText fontSize="xs" mt={1}>{helpText}</StatHelpText>
          )}
        </Stat>
        <Flex
          w={10}
          h={10}
          rounded="lg"
          bg={`${colorScheme}.50`}
          color={`${colorScheme}.500`}
          align="center"
          justify="center"
          _dark={{
            bg: `${colorScheme}.900`,
          }}
        >
          <Icon as={icon} boxSize={5} />
        </Flex>
      </Flex>
    </Box>
  );
}
