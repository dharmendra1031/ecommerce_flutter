import { body } from "express-validator";

export const createProductValidator = [
  body("name").trim().notEmpty().withMessage("Product name is required"),
  body("description").trim().notEmpty().withMessage("Description is required"),
  body("price").isFloat({ min: 0 }).withMessage("Valid price is required"),
  body("category").isMongoId().withMessage("Valid category ID is required"),
  body("stock")
    .optional()
    .isInt({ min: 0 })
    .withMessage("Stock must be non-negative"),
];

export const updateProductValidator = [
  body("name")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Product name cannot be empty"),
  body("price")
    .optional()
    .isFloat({ min: 0 })
    .withMessage("Price must be non-negative"),
  body("stock")
    .optional()
    .isInt({ min: 0 })
    .withMessage("Stock must be non-negative"),
];
