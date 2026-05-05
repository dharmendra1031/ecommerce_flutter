import { Router } from "express";
import {
  getProducts,
  getProduct,
  getProductBySlug,
  getFeaturedProducts,
  getFlashSaleProducts,
  getProductsByCategory,
  createProduct,
  updateProduct,
  deleteProduct,
  uploadProductImages,
  deleteProductImage,
} from "../controllers/product.controller.js";
import {
  getProductReviews,
  createReview,
} from "../controllers/review.controller.js";
import { protect, authorize } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  createProductValidator,
  updateProductValidator,
} from "../validators/product.validator.js";
import { createReviewValidator } from "../validators/review.validator.js";
import validatePagination from "../middlewares/pagination.middleware.js";

const router = Router();

// Public routes
router.get("/", validatePagination, getProducts);
router.get("/featured", validatePagination, getFeaturedProducts);
router.get("/flash-sale", validatePagination, getFlashSaleProducts);
router.get("/slug/:slug", getProductBySlug);
router.get("/category/:categoryId", validatePagination, getProductsByCategory);

// Product reviews - MUST be before /:id route
router.get("/:productId/reviews", validatePagination, getProductReviews);
router.post("/:productId/reviews", protect, createReviewValidator, validate, createReview);

// Single product route - MUST be after more specific routes
router.get("/:id", getProduct);

// Admin routes
router.post(
  "/",
  protect,
  authorize("admin"),
  createProductValidator,
  validate,
  createProduct,
);
router.put(
  "/:id",
  protect,
  authorize("admin"),
  updateProductValidator,
  validate,
  updateProduct,
);
router.delete("/:id", protect, authorize("admin"), deleteProduct);
router.post(
  "/:id/images",
  protect,
  authorize("admin"),
  upload.array("images", 5),
  uploadProductImages,
);
router.delete(
  "/:id/images/:imageId",
  protect,
  authorize("admin"),
  deleteProductImage,
);

export default router;
