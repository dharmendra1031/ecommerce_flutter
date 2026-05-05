import { Input, Text, Box } from '@chakra-ui/react';
import { Controller, type Control, type FieldValues, type Path } from 'react-hook-form';

interface TextFieldProps<T extends FieldValues> {
  name: Path<T>;
  control: Control<T>;
  label: string;
  type?: string;
  placeholder?: string;
  isRequired?: boolean;
}

export default function TextField<T extends FieldValues>({
  name,
  control,
  label,
  type = 'text',
  placeholder,
  isRequired,
}: TextFieldProps<T>) {
  return (
    <Controller
      name={name}
      control={control}
      render={({ field, fieldState }) => (
        <Box>
          <Text fontSize="sm" fontWeight="medium" mb={1}>
            {label}
            {isRequired && <Text as="span" color="red.500"> *</Text>}
          </Text>
          <Input {...field} type={type} placeholder={placeholder} isInvalid={!!fieldState.error} />
          {fieldState.error && (
            <Text color="red.500" fontSize="xs" mt={1}>{fieldState.error.message}</Text>
          )}
        </Box>
      )}
    />
  );
}
