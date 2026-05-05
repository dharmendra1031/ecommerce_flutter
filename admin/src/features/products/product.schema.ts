import { z } from 'zod';

export const productSchema = z.object({
  name: z.string().min(1, 'Name is required').max(200),
  description: z.string().min(10, 'Description must be at least 10 characters').max(2000),
  price: z.coerce.number().positive('Price must be positive'),
  category: z.string().min(1, 'Category is required'),
  stock: z.coerce.number().int().min(0, 'Stock cannot be negative'),
  brand: z.string().optional(),
  images: z.array(z.object({ public_id: z.string(), url: z.string() })).optional(),
});

export type ProductFormData = z.infer<typeof productSchema>;
