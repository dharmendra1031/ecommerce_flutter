import { Router } from "express";
import {
  validateCardDetails,
  processPayment,
} from "../controllers/payment.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import { cardPaymentValidator } from "../validators/order.validator.js";

const router = Router();

router.use(protect);

router.post(
  "/validate-card",
  cardPaymentValidator,
  validate,
  validateCardDetails,
);
router.post("/process", cardPaymentValidator, validate, processPayment);

export default router;
