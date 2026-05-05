import { body } from "express-validator";

export const addToCartValidator = [
  body("productId")
    .notEmpty()
    .withMessage("Product ID is required")
    .isMongoId()
    .withMessage("Invalid product ID"),
  body("quantity")
    .notEmpty()
    .withMessage("Quantity is required")
    .isInt({ min: 1, max: 999 })
    .withMessage("Quantity must be between 1 and 999"),
  body("variant")
    .optional()
    .isObject()
    .withMessage("Variant must be an object"),
  body("variant.name")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Variant name cannot be empty"),
  body("variant.value")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Variant value cannot be empty"),
];

export const updateCartItemValidator = [
  body("quantity")
    .notEmpty()
    .withMessage("Quantity is required")
    .isInt({ min: 1, max: 999 })
    .withMessage("Quantity must be between 1 and 999"),
];
