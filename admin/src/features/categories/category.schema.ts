import { z } from 'zod';

export const categorySchema = z.object({
  name: z.string().min(1, 'Name is required').max(50),
  description: z.string().max(200).optional(),
  image: z.array(z.object({ public_id: z.string(), url: z.string() })).optional(),
  parent: z.string().optional(),
});

export type CategoryFormData = z.infer<typeof categorySchema>;
