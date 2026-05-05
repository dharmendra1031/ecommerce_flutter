import { Router } from "express";
import {
  register,
  login,
  logout,
  refreshToken,
  getMe,
  forgotPassword,
  resetPassword,
  updatePassword,
  sendVerificationEmail,
  verifyEmail,
  devVerifyUser,
} from "../controllers/auth.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  registerValidator,
  loginValidator,
  forgotPasswordValidator,
  resetPasswordValidator,
  updatePasswordValidator,
} from "../validators/auth.validator.js";

const router = Router();

router.post("/register", registerValidator, validate, register);
router.post("/login", loginValidator, validate, login);
router.post("/logout", protect, logout);
router.post("/refresh-token", refreshToken);
router.get("/me", protect, getMe);
router.post(
  "/forgot-password",
  forgotPasswordValidator,
  validate,
  forgotPassword,
);
router.put(
  "/reset-password/:token",
  resetPasswordValidator,
  validate,
  resetPassword,
);
router.put(
  "/update-password",
  protect,
  updatePasswordValidator,
  validate,
  updatePassword,
);
router.post("/send-verification", protect, sendVerificationEmail);
router.get("/verify-email/:token", verifyEmail);
router.get("/dev-verify/:userId", devVerifyUser);

export default router;
