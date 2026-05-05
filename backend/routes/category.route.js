import { Router } from "express";
import {
  getCategories,
  getCategory,
  createCategory,
  updateCategory,
  deleteCategory,
  uploadCategoryImage,
} from "../controllers/category.controller.js";
import { protect, authorize } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  createCategoryValidator,
  updateCategoryValidator,
} from "../validators/category.validator.js";

const router = Router();

// Public routes
router.get("/", getCategories);
router.get("/:id", getCategory);

// Admin routes
router.post(
  "/",
  protect,
  authorize("admin"),
  createCategoryValidator,
  validate,
  createCategory,
);
router.put(
  "/:id",
  protect,
  authorize("admin"),
  updateCategoryValidator,
  validate,
  updateCategory,
);
router.delete("/:id", protect, authorize("admin"), deleteCategory);
router.put(
  "/:id/image",
  protect,
  authorize("admin"),
  upload.single("image"),
  uploadCategoryImage,
);

export default router;
