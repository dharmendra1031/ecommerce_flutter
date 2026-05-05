import { Router } from "express";
import {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart,
} from "../controllers/cart.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  addToCartValidator,
  updateCartItemValidator,
} from "../validators/cart.validator.js";

const router = Router();

// All routes require authentication
router.use(protect);

router
  .route("/")
  .get(getCart)
  .post(addToCartValidator, validate, addToCart)
  .delete(clearCart);

router
  .route("/:itemId")
  .put(updateCartItemValidator, validate, updateCartItem)
  .delete(removeFromCart);

export default router;
