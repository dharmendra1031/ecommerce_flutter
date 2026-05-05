import { z } from 'zod';

export const userSchema = z.object({
  name: z.string().min(1, 'Name is required').max(50),
  email: z.string().email('Invalid email'),
  role: z.enum(['user', 'admin']),
});

export type UserFormData = z.infer<typeof userSchema>;
