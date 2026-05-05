import { format } from 'date-fns';

export const formatPrice = (price: number): string =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(price);

export const formatDate = (date: string): string =>
  format(new Date(date), 'MMM dd, yyyy');

export const formatDateTime = (date: string): string =>
  format(new Date(date), 'MMM dd, yyyy HH:mm');

export const truncate = (str: string, length: number): string =>
  str.length > length ? `${str.slice(0, length)}...` : str;

export const capitalize = (str: string): string =>
  str.charAt(0).toUpperCase() + str.slice(1);

export type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled' | 'refunded' | 'completed';

export const getStatusColor = (status: OrderStatus | string): string => {
  const colors: Record<string, string> = {
    pending: 'yellow',
    processing: 'blue',
    shipped: 'cyan',
    delivered: 'green',
    cancelled: 'red',
    refunded: 'orange',
    completed: 'green',
  };
  return colors[status] || 'gray';
};

interface ApiErrorResponse {
  success?: boolean;
  message?: string;
  errors?: Array<{ msg?: string; message?: string }>;
}

export const getErrorMessage = (err: unknown, fallback = 'An unexpected error occurred'): string => {
  if (err && typeof err === 'object' && 'message' in err) {
    const apiErr = err as ApiErrorResponse;
    if (apiErr.errors?.length) {
      return apiErr.errors.map((e) => e.msg ?? e.message ?? 'Error').join(', ');
    }
    if (apiErr.message) return apiErr.message;
  }
  if (err instanceof Error) return err.message;
  return fallback;
};

export const exportToCsv = <T extends object>(data: T[], filename: string, columns?: { key: keyof T; label: string }[]) => {
  if (!data.length) return;
  const keys = columns ? columns.map((c) => c.key) : (Object.keys(data[0]!) as (keyof T)[]);
  const labels = columns ? columns.map((c) => c.label) : (keys as string[]);
  const escape = (val: unknown) => {
    const str = String(val ?? '');
    return str.includes(',') || str.includes('"') || str.includes('\n') ? `"${str.replace(/"/g, '""')}"` : str;
  };
  const rows = data.map((row) => keys.map((k) => escape(row[k])).join(','));
  const csv = [labels.map(escape).join(','), ...rows].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `${filename}.csv`;
  link.click();
  URL.revokeObjectURL(url);
};
