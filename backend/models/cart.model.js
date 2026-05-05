import mongoose from "mongoose";

const cartItemSchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Product",
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
    min: [1, "Quantity must be at least 1"],
    default: 1,
  },
  variant: {
    name: String,
    value: String,
    priceModifier: { type: Number, default: 0 },
  },
});

const cartSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },
    items: [cartItemSchema],
  },
  { timestamps: true },
);

// Calculate cart total (virtual)
cartSchema.virtual("total").get(function () {
  return this.items.reduce((sum, item) => {
    const price = item.product?.price || 0;
    const modifier = item.variant?.priceModifier || 0;
    return sum + (price + modifier) * item.quantity;
  }, 0);
});

cartSchema.set("toJSON", { virtuals: true });
cartSchema.set("toObject", { virtuals: true });

// Note: user field already has unique: true which creates an index automatically

const Cart = mongoose.model("Cart", cartSchema);

export default Cart;
