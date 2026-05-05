import { Switch, Text, Box, HStack } from '@chakra-ui/react';
import { Controller, type Control, type FieldValues, type Path } from 'react-hook-form';

interface SwitchFieldProps<T extends FieldValues> {
  name: Path<T>;
  control: Control<T>;
  label: string;
}

export default function SwitchField<T extends FieldValues>({
  name,
  control,
  label,
}: SwitchFieldProps<T>) {
  return (
    <Controller
      name={name}
      control={control}
      render={({ field }) => (
        <Box>
          <HStack justify="space-between">
            <Text fontSize="sm" fontWeight="medium">{label}</Text>
            <Switch
              isChecked={field.value as boolean}
              onChange={field.onChange}
              colorScheme="brand"
            />
          </HStack>
        </Box>
      )}
    />
  );
}
