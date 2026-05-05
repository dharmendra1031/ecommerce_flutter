import { z } from 'zod';

export const orderStatusSchema = z.object({
  status: z.enum(['pending', 'processing', 'shipped', 'delivered', 'cancelled']),
});

export type OrderStatusFormData = z.infer<typeof orderStatusSchema>;
