import { Router } from "express";
import {
  createOrder,
  getMyOrders,
  getOrder,
  cancelOrder,
  getAllOrders,
  updateOrderStatus,
} from "../controllers/order.controller.js";
import { protect, authorize } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import { createOrderValidator } from "../validators/order.validator.js";
import { updateOrderStatusValidator } from "../validators/admin.validator.js";
import validatePagination from "../middlewares/pagination.middleware.js";

const router = Router();

// User routes
router.use(protect);

router
  .route("/")
  .get(validatePagination, getMyOrders)
  .post(createOrderValidator, validate, createOrder);

// Admin routes (must be before /:id to avoid matching "admin" as an ID)
router.get("/admin/all", authorize("admin"), validatePagination, getAllOrders);
router.put("/admin/:id/status", authorize("admin"), updateOrderStatusValidator, validate, updateOrderStatus);

router.get("/:id", getOrder);
router.put("/:id/cancel", cancelOrder);

export default router;
