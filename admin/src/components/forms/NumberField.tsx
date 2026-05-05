import {
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  Text,
  Box,
} from '@chakra-ui/react';
import { Controller, type Control, type FieldValues, type Path } from 'react-hook-form';

interface NumberFieldProps<T extends FieldValues> {
  name: Path<T>;
  control: Control<T>;
  label: string;
  min?: number;
  max?: number;
  precision?: number;
  isRequired?: boolean;
}

export default function NumberField<T extends FieldValues>({
  name,
  control,
  label,
  min,
  max,
  precision,
  isRequired,
}: NumberFieldProps<T>) {
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
          <NumberInput
            value={field.value ?? ''}
            onChange={(val) => field.onChange(val === '' ? undefined : Number(val))}
            min={min}
            max={max}
            precision={precision}
          >
            <NumberInputField borderColor={fieldState.error ? 'red.500' : undefined} />
            <NumberInputStepper>
              <NumberIncrementStepper />
              <NumberDecrementStepper />
            </NumberInputStepper>
          </NumberInput>
          {fieldState.error && (
            <Text color="red.500" fontSize="xs" mt={1}>{fieldState.error.message}</Text>
          )}
        </Box>
      )}
    />
  );
}
