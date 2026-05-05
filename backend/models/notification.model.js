import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    type: {
      type: String,
      enum: ["order", "promo", "system"],
      default: "system",
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    data: {
      orderId: { type: mongoose.Schema.Types.ObjectId, ref: "Order" },
      reviewId: { type: mongoose.Schema.Types.ObjectId, ref: "Review" },
      productId: { type: mongoose.Schema.Types.ObjectId, ref: "Product" },
      status: { type: String },
      promotionUrl: { type: String },
    },
  },
  { timestamps: true },
);

// Index for performance
notificationSchema.index({ user: 1, createdAt: -1 });

const Notification = mongoose.model("Notification", notificationSchema);

export default Notification;
