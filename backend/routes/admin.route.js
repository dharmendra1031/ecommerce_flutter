import { Router } from "express";
import {
  getDashboard,
  getUsers,
  updateUserRole,
  deleteUser,
} from "../controllers/admin.controller.js";
import { getAllReviews } from "../controllers/review.controller.js";
import { protect, authorize } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import { updateUserRoleValidator } from "../validators/admin.validator.js";
import validatePagination from "../middlewares/pagination.middleware.js";

const router = Router();

// All admin routes require authentication and admin role
router.use(protect, authorize("admin"));

router.get("/dashboard", getDashboard);
router.get("/users", validatePagination, getUsers);
router.get("/reviews", validatePagination, getAllReviews);
router.put("/users/:id", updateUserRoleValidator, validate, updateUserRole);
router.delete("/users/:id", deleteUser);

export default router;
