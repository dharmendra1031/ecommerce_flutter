import { Router } from "express";
import {
  getProfile,
  updateProfile,
  uploadAvatar,
  deleteAvatar,
  getAddresses,
  addAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress,
  getWishlist,
  addToWishlist,
  removeFromWishlist,
  checkWishlist,
  deleteAccount,
  getSavedCard,
  getSavedCardForCheckout,
  saveCard,
  deleteCard,
} from "../controllers/user.controller.js";
import { protect } from "../middlewares/auth.middleware.js";
import { upload } from "../middlewares/upload.middleware.js";
import validate from "../middlewares/validate.middleware.js";
import {
  addAddressValidator,
  updateAddressValidator,
  updateProfileValidator,
  saveCardValidator,
} from "../validators/user.validator.js";

const router = Router();

router.use(protect);

router
  .route("/profile")
  .get(getProfile)
  .put(updateProfileValidator, validate, updateProfile)
  .delete(deleteAccount);

router
  .route("/avatar")
  .put(upload.single("avatar"), uploadAvatar)
  .delete(deleteAvatar);

router
  .route("/addresses")
  .get(getAddresses)
  .post(addAddressValidator, validate, addAddress);

router
  .route("/addresses/:id")
  .put(updateAddressValidator, validate, updateAddress)
  .delete(deleteAddress);

router.patch("/addresses/:id/default", setDefaultAddress);

router.get("/wishlist", getWishlist);
router.get("/wishlist/check/:productId", checkWishlist);
router.post("/wishlist/:productId", addToWishlist);
router.delete("/wishlist/:productId", removeFromWishlist);

router.get("/card", getSavedCard);
router.get("/card/checkout", getSavedCardForCheckout);
router.put("/card", saveCardValidator, validate, saveCard);
router.delete("/card", deleteCard);

export default router;
