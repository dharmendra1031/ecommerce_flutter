import jwt from "jsonwebtoken";
import User from "../models/user.model.js";
import ApiError from "../utils/ApiError.js";
import asyncHandler from "../utils/asyncHandler.js";

/**
 * Protect routes - require authentication
 */
export const protect = asyncHandler(async (req, res, next) => {
  let token;

  if (req.headers.authorization?.startsWith("Bearer")) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    throw ApiError.unauthorized("Not authorized, no token");
  }

  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  const user = await User.findById(decoded.id);

  if (!user) {
    throw ApiError.unauthorized("User not found");
  }

  // Check email verification (except for specific routes)
  const allowedUnverifiedRoutes = [
    "/api/auth/send-verification",
    "/api/auth/logout",
  ];

  if (
    !user.isEmailVerified &&
    !allowedUnverifiedRoutes.includes(req.originalUrl)
  ) {
    throw ApiError.forbidden("Please verify your email");
  }

  req.user = user;
  next();
});

/**
 * Authorize specific roles
 */
export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      throw ApiError.unauthorized("Not authenticated");
    }
    if (!roles.includes(req.user.role)) {
      throw ApiError.forbidden("Not authorized for this action");
    }
    next();
  };
};

/**
 * Optional auth - attach user if token exists
 */
export const optionalAuth = asyncHandler(async (req, res, next) => {
  let token;

  if (req.headers.authorization?.startsWith("Bearer")) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = await User.findById(decoded.id);
    } catch {
      // Token invalid, continue without user
    }
  }

  next();
});
