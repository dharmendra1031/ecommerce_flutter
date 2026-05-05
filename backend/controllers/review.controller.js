import Review from "../models/review.model.js";
import Order from "../models/order.model.js";
import Product from "../models/product.model.js";
import User from "../models/user.model.js";
import Notification from "../models/notification.model.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";

// @desc    Get product reviews
// @route   GET /api/products/:productId/reviews
export const getProductReviews = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, sort = "newest" } = req.query;

  const sortOptions = {
    newest: { createdAt: -1 },
    oldest: { createdAt: 1 },
    highest: { rating: -1 },
    lowest: { rating: 1 },
  };

  const reviews = await Review.find({ product: req.params.productId })
    .populate("user", "name avatar")
    .sort(sortOptions[sort] || { createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(Number(limit));

  const total = await Review.countDocuments({ product: req.params.productId });

  res.json(
    new ApiResponse(200, {
      reviews,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    }),
  );
});

// @desc    Create review
// @route   POST /api/products/:productId/reviews
export const createReview = asyncHandler(async (req, res) => {
  const { rating, title, comment } = req.body;

  // Check if product exists
  const product = await Product.findById(req.params.productId);
  if (!product) {
    throw ApiError.notFound("Product not found");
  }

  // Check if already reviewed
  const existingReview = await Review.findOne({
    user: req.user._id,
    product: req.params.productId,
  });

  if (existingReview) {
    throw ApiError.badRequest("You have already reviewed this product");
  }

  // Check if user purchased this product
  const hasPurchased = await Order.exists({
    user: req.user._id,
    "orderItems.product": req.params.productId,
    status: "delivered",
  });

  const review = await Review.create({
    user: req.user._id,
    product: req.params.productId,
    rating,
    title,
    comment,
    isVerifiedPurchase: !!hasPurchased,
  });

  await review.populate("user", "name avatar");

  // Create notification
  await Notification.create({
    user: req.user._id,
    title: "Review Published",
    message: `Your review for this product has been published. Thank you for your feedback!`,
    type: "system",
    data: { reviewId: review._id, productId: req.params.productId },
  });

  // Create notifications for all admins
  const admins = await User.find({ role: "admin" });
  if (admins.length > 0) {
    const adminNotifications = admins.map((admin) => ({
      user: admin._id,
      title: "New Product Review",
      message: `${req.user.name} posted a ${rating}-star review for a product.`,
      type: "system",
      data: { reviewId: review._id, productId: req.params.productId },
    }));
    await Notification.insertMany(adminNotifications);
  }

  res.status(201).json(new ApiResponse(201, { review }, "Review added"));
});

// @desc    Update review
// @route   PUT /api/reviews/:id
export const updateReview = asyncHandler(async (req, res) => {
  const { rating, title, comment } = req.body;

  const review = await Review.findById(req.params.id);

  if (!review) {
    throw ApiError.notFound("Review not found");
  }

  if (review.user.toString() !== req.user._id.toString()) {
    throw ApiError.forbidden("Not authorized");
  }

  review.rating = rating ?? review.rating;
  review.title = title ?? review.title;
  review.comment = comment ?? review.comment;
  await review.save();

  await review.populate("user", "name avatar");

  res.json(new ApiResponse(200, { review }, "Review updated"));
});

// @desc    Delete review
// @route   DELETE /api/reviews/:id
export const deleteReview = asyncHandler(async (req, res) => {
  const review = await Review.findById(req.params.id);

  if (!review) {
    throw ApiError.notFound("Review not found");
  }

  if (
    review.user.toString() !== req.user._id.toString() &&
    req.user.role !== "admin"
  ) {
    throw ApiError.forbidden("Not authorized");
  }

  await review.deleteOne();

  res.json(new ApiResponse(200, null, "Review deleted"));
});

// @desc    Get all reviews (Admin)
// @route   GET /api/admin/reviews
export const getAllReviews = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;

  const reviews = await Review.find()
    .populate("user", "name email avatar")
    .populate("product", "name images")
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(Number(limit));

  const total = await Review.countDocuments();

  res.json(
    new ApiResponse(200, {
      reviews,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    }),
  );
});

// @desc    Get user's reviews
// @route   GET /api/reviews/my
export const getMyReviews = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10 } = req.query;

  const reviews = await Review.find({ user: req.user._id })
    .populate("product", "name images slug")
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(Number(limit));

  const total = await Review.countDocuments({ user: req.user._id });

  res.json(
    new ApiResponse(200, {
      reviews,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    }),
  );
});
