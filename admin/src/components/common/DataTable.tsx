import {
  Box,
  Button,
  Flex,
  HStack,
  Icon,
  Table,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
  Text,
  IconButton,
  Spinner,
  Input,
  InputGroup,
  InputLeftElement,
} from '@chakra-ui/react';
import { FiChevronLeft, FiChevronRight, FiSearch, FiChevronUp, FiChevronDown } from 'react-icons/fi';
import { type ReactNode, useState, useEffect, useCallback } from 'react';
import { useDebounce } from '@/hooks/useDebounce';
import EmptyState from './EmptyState';

type SortDirection = 'asc' | 'desc' | null;

interface Column<T> {
  header: string;
  accessor?: keyof T | ((row: T) => ReactNode);
  render?: (row: T) => ReactNode;
  sortable?: boolean;
  sortKey?: string;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  isLoading?: boolean;
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  search?: string;
  onSearchChange?: (search: string) => void;
  keyExtractor: (row: T) => string;
  onSortChange?: (sortField: string | null, sortDirection: SortDirection) => void;
}

export default function DataTable<T>({
  columns,
  data,
  isLoading,
  page,
  totalPages,
  onPageChange,
  search,
  onSearchChange,
  keyExtractor,
  onSortChange,
}: DataTableProps<T>) {
  const [localSearch, setLocalSearch] = useState(search ?? '');
  const debouncedSearch = useDebounce(localSearch, 300);
  const [sortField, setSortField] = useState<string | null>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);

  useEffect(() => {
    if (debouncedSearch !== search) {
      onSearchChange?.(debouncedSearch);
    }
  }, [debouncedSearch]);

  useEffect(() => {
    setLocalSearch(search ?? '');
  }, [search]);

  const handleSort = useCallback((col: Column<T>) => {
    if (!col.sortable) return;
    const field = col.sortKey ?? (typeof col.accessor === 'string' ? col.accessor : null);
    if (!field) return;

    let nextDirection: SortDirection = 'asc';
    if (sortField === field) {
      if (sortDirection === 'asc') nextDirection = 'desc';
      else if (sortDirection === 'desc') nextDirection = null;
    }

    setSortField(nextDirection ? field : null);
    setSortDirection(nextDirection);
    onSortChange?.(nextDirection ? field : null, nextDirection);
  }, [sortField, sortDirection, onSortChange]);

  const getCellValue = (row: T, column: Column<T>): ReactNode => {
    if (column.render) return column.render(row);
    if (!column.accessor) return null;
    if (typeof column.accessor === 'function') return column.accessor(row);
    const value = row[column.accessor];
    return value as ReactNode;
  };

  return (
    <Box bg="bg.card" rounded="lg" shadow="sm" border="1px" borderColor="border.default">
      {onSearchChange && (
        <Box p={4} borderBottom="1px" borderColor="border.default">
          <InputGroup maxW="300px">
            <InputLeftElement pointerEvents="none">
              <Icon as={FiSearch} color="icon.muted" />
            </InputLeftElement>
            <Input
              placeholder="Search..."
              value={localSearch}
              onChange={(e) => setLocalSearch(e.target.value)}
              size="sm"
            />
          </InputGroup>
        </Box>
      )}

      {isLoading ? (
        <Flex justify="center" align="center" py={20}>
          <Spinner size="lg" color="brand.500" />
        </Flex>
      ) : data.length === 0 ? (
        <EmptyState />
      ) : (
        <Box overflowX="auto">
          <Table variant="simple" size="sm">
            <Thead bg="bg.subtle">
              <Tr>
                {columns.map((col) => (
                  <Th
                    key={col.header}
                    fontSize="xs"
                    textTransform="uppercase"
                    color="text.muted"
                    cursor={col.sortable ? 'pointer' : 'default'}
                    onClick={() => handleSort(col)}
                    _hover={col.sortable ? { color: 'text.default' } : undefined}
                    userSelect="none"
                  >
                    <HStack spacing={1}>
                      <Text>{col.header}</Text>
                      {col.sortable && sortField === (col.sortKey ?? (typeof col.accessor === 'string' ? col.accessor : null)) && (
                        <Icon as={sortDirection === 'asc' ? FiChevronUp : FiChevronDown} boxSize={3} />
                      )}
                    </HStack>
                  </Th>
                ))}
              </Tr>
            </Thead>
            <Tbody>
              {data.map((row) => (
                <Tr key={keyExtractor(row)} _hover={{ bg: 'hover.subtle' }}>
                  {columns.map((col) => (
                    <Td key={col.header}>{getCellValue(row, col)}</Td>
                  ))}
                </Tr>
              ))}
            </Tbody>
          </Table>
        </Box>
      )}

      {totalPages > 1 && (
        <Flex justify="space-between" align="center" px={4} py={3} borderTop="1px" borderColor="border.default">
          <Text fontSize="sm" color="text.muted">
            Page {page} of {totalPages}
          </Text>
          <HStack spacing={1}>
            <IconButton
              aria-label="Previous page"
              icon={<FiChevronLeft />}
              size="sm"
              variant="ghost"
              isDisabled={page <= 1}
              onClick={() => onPageChange(page - 1)}
            />
            {Array.from({ length: Math.min(totalPages, 5) }, (_, i) => {
              let pageNum: number;
              if (totalPages <= 5) {
                pageNum = i + 1;
              } else if (page <= 3) {
                pageNum = i + 1;
              } else if (page >= totalPages - 2) {
                pageNum = totalPages - 4 + i;
              } else {
                pageNum = page - 2 + i;
              }
              return (
                <Button
                  key={pageNum}
                  size="sm"
                  variant={page === pageNum ? 'solid' : 'ghost'}
                  colorScheme={page === pageNum ? 'brand' : 'gray'}
                  onClick={() => onPageChange(pageNum)}
                >
                  {pageNum}
                </Button>
              );
            })}
            <IconButton
              aria-label="Next page"
              icon={<FiChevronRight />}
              size="sm"
              variant="ghost"
              isDisabled={page >= totalPages}
              onClick={() => onPageChange(page + 1)}
            />
          </HStack>
        </Flex>
      )}
    </Box>
  );
}
