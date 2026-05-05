import { validationResult } from "express-validator";
import ApiError from "../utils/ApiError.js";

/**
 * Middleware to check validation results
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const messages = errors.array().map((e) => e.msg);
    throw ApiError.badRequest("Validation failed", messages);
  }

  next();
};

export default validate;
