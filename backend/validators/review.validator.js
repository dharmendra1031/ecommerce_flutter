import { body } from "express-validator";

export const createReviewValidator = [
  body("rating")
    .notEmpty()
    .withMessage("Rating is required")
    .isInt({ min: 1, max: 5 })
    .withMessage("Rating must be between 1 and 5"),
  body("title")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Title cannot exceed 100 characters"),
  body("comment")
    .trim()
    .notEmpty()
    .withMessage("Comment is required")
    .isLength({ min: 3, max: 1000 })
    .withMessage("Comment must be between 3 and 1000 characters"),
];

export const updateReviewValidator = [
  body("rating")
    .optional()
    .isInt({ min: 1, max: 5 })
    .withMessage("Rating must be between 1 and 5"),
  body("title")
    .optional()
    .trim()
    .isLength({ max: 100 })
    .withMessage("Title cannot exceed 100 characters"),
  body("comment")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Comment cannot be empty")
    .isLength({ min: 3, max: 1000 })
    .withMessage("Comment must be between 3 and 1000 characters"),
];
