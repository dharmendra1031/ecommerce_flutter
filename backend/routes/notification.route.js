import { Router } from "express";
import {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getUnreadCount,
} from "../controllers/notification.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import validatePagination from "../middlewares/pagination.middleware.js";

const router = Router();

router.use(protect);

router.get("/unread-count", getUnreadCount);
router.get("/", validatePagination, getNotifications);
router.patch("/read-all", markAllAsRead);
router.patch("/:id/read", markAsRead);
router.delete("/:id", deleteNotification);

export default router;
