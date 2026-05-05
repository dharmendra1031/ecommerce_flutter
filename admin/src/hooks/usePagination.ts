import { useState } from 'react';

export function usePagination(initialLimit = 10) {
  const [page, setPage] = useState(1);
  const [limit] = useState(initialLimit);
  const [search, setSearch] = useState('');

  const resetPage = () => setPage(1);

  return { page, limit, search, setPage, setSearch, resetPage };
}
