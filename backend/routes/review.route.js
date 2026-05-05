import { Router } from "express";
import {
  getProductReviews,
  createReview,
  updateReview,
  deleteReview,
  getMyReviews,
} from "../controllers/review.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  createReviewValidator,
  updateReviewValidator,
} from "../validators/review.validator.js";
import validatePagination from "../middlewares/pagination.middleware.js";

const router = Router();

// Mounted at /api/reviews
// Product reviews are accessed via /api/products/:productId/reviews

router.get("/my", protect, validatePagination, getMyReviews);

router.put("/:id", protect, updateReviewValidator, validate, updateReview);
router.delete("/:id", protect, deleteReview);

export default router;

// Export for product routes
export { getProductReviews, createReview };
