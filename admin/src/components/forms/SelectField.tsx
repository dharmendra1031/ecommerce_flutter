import { Select, Text, Box } from '@chakra-ui/react';
import { Controller, type Control, type FieldValues, type Path } from 'react-hook-form';

interface SelectFieldProps<T extends FieldValues> {
  name: Path<T>;
  control: Control<T>;
  label: string;
  options: { value: string; label: string }[];
  placeholder?: string;
  isRequired?: boolean;
}

export default function SelectField<T extends FieldValues>({
  name,
  control,
  label,
  options,
  placeholder = 'Select...',
  isRequired,
}: SelectFieldProps<T>) {
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
          <Select {...field} isInvalid={!!fieldState.error}>
            <option value="">{placeholder}</option>
            {options.map((opt) => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </Select>
          {fieldState.error && (
            <Text color="red.500" fontSize="xs" mt={1}>{fieldState.error.message}</Text>
          )}
        </Box>
      )}
    />
  );
}
