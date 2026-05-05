import { body } from "express-validator";

export const addAddressValidator = [
  body("label")
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage("Label cannot exceed 50 characters"),
  body("fullName")
    .trim()
    .notEmpty()
    .withMessage("Full name is required")
    .isLength({ max: 100 })
    .withMessage("Full name cannot exceed 100 characters"),
  body("phone")
    .trim()
    .notEmpty()
    .withMessage("Phone number is required")
    .matches(/^[0-9+\-\s()]{6,20}$/)
    .withMessage("Invalid phone number format"),
  body("address")
    .trim()
    .notEmpty()
    .withMessage("Address is required")
    .isLength({ max: 200 })
    .withMessage("Address cannot exceed 200 characters"),
  body("city")
    .trim()
    .notEmpty()
    .withMessage("City is required")
    .isLength({ max: 100 })
    .withMessage("City cannot exceed 100 characters"),
  body("postalCode")
    .optional()
    .trim()
    .isLength({ max: 20 })
    .withMessage("Postal code cannot exceed 20 characters"),
  body("country")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Country cannot exceed 100 characters"),
  body("isDefault")
    .optional()
    .isBoolean()
    .withMessage("isDefault must be a boolean"),
];

export const updateAddressValidator = [
  body("label")
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage("Label cannot exceed 50 characters"),
  body("fullName")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Full name cannot be empty")
    .isLength({ max: 100 })
    .withMessage("Full name cannot exceed 100 characters"),
  body("phone")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Phone cannot be empty")
    .matches(/^[0-9+\-\s()]{6,20}$/)
    .withMessage("Invalid phone number format"),
  body("address")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Address cannot be empty")
    .isLength({ max: 200 })
    .withMessage("Address cannot exceed 200 characters"),
  body("city")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("City cannot be empty")
    .isLength({ max: 100 })
    .withMessage("City cannot exceed 100 characters"),
  body("postalCode")
    .optional()
    .trim()
    .isLength({ max: 20 })
    .withMessage("Postal code cannot exceed 20 characters"),
  body("country")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Country cannot exceed 100 characters"),
  body("isDefault")
    .optional()
    .isBoolean()
    .withMessage("isDefault must be a boolean"),
];

export const updateProfileValidator = [
  body("name")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Name cannot be empty")
    .isLength({ max: 50 })
    .withMessage("Name cannot exceed 50 characters"),
  body("phone")
    .optional()
    .trim()
    .matches(/^[0-9+\-\s()]{6,20}$/)
    .withMessage("Invalid phone number format"),
];

export const saveCardValidator = [
  body("cardNumber")
    .trim()
    .notEmpty()
    .withMessage("Card number is required")
    .matches(/^\d[\d\s-]{12,22}\d$/)
    .withMessage("Invalid card number format"),
  body("cardholderName")
    .trim()
    .notEmpty()
    .withMessage("Cardholder name is required")
    .isLength({ max: 100 })
    .withMessage("Cardholder name cannot exceed 100 characters"),
  body("expiry")
    .trim()
    .notEmpty()
    .withMessage("Expiry is required")
    .matches(/^(0[1-9]|1[0-2])\/\d{2}$/)
    .withMessage("Expiry must be in MM/YY format"),
  body("cvv")
    .trim()
    .notEmpty()
    .withMessage("CVV is required")
    .matches(/^\d{3,4}$/)
    .withMessage("CVV must be 3-4 digits"),
  body("cardType")
    .optional()
    .isIn(["visa", "mastercard", "amex", "discover"])
    .withMessage("Invalid card type"),
];
