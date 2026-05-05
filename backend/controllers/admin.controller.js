import User from "../models/user.model.js";
import Product from "../models/product.model.js";
import Order from "../models/order.model.js";
import Address from "../models/address.model.js";
import Cart from "../models/cart.model.js";
import Review from "../models/review.model.js";
import Notification from "../models/notification.model.js";
import { cloudinary } from "../config/cloudinary.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard
export const getDashboard = asyncHandler(async (req, res) => {
  const { period = "30d" } = req.query;

  // Calculate date ranges
  const now = new Date();
  const currentPeriodStart = new Date();
  const previousPeriodStart = new Date();
  const previousPeriodEnd = new Date();

  switch (period) {
    case "7d":
      currentPeriodStart.setDate(now.getDate() - 7);
      previousPeriodStart.setDate(now.getDate() - 14);
      previousPeriodEnd.setDate(now.getDate() - 7);
      break;
    case "30d":
      currentPeriodStart.setDate(now.getDate() - 30);
      previousPeriodStart.setDate(now.getDate() - 60);
      previousPeriodEnd.setDate(now.getDate() - 30);
      break;
    case "90d":
      currentPeriodStart.setDate(now.getDate() - 90);
      previousPeriodStart.setDate(now.getDate() - 180);
      previousPeriodEnd.setDate(now.getDate() - 90);
      break;
    default:
      currentPeriodStart.setDate(now.getDate() - 30);
      previousPeriodStart.setDate(now.getDate() - 60);
      previousPeriodEnd.setDate(now.getDate() - 30);
  }

  const [
    totalUsers,
    totalProducts,
    totalOrders,
    recentOrders,
    orderStats,
    // Period comparison data
    currentPeriodStats,
    previousPeriodStats,
    // Revenue trend (daily for the selected period)
    revenueTrend,
    // User growth trend
    userGrowth,
    // Top selling products
    topProducts,
    // Low stock products
    lowStockProducts,
  ] = await Promise.all([
    User.countDocuments({ role: "user" }),
    Product.countDocuments({ isActive: true }),
    Order.countDocuments(),
    Order.find()
      .sort({ createdAt: -1 })
      .limit(10)
      .populate("user", "name email")
      .populate("orderItems.product", "name images"),
    Order.aggregate([
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: "$totalPrice" },
          paidOrders: { $sum: { $cond: ["$isPaid", 1, 0] } },
        },
      },
    ]),
    // Current period stats
    Order.aggregate([
      { $match: { createdAt: { $gte: currentPeriodStart } } },
      {
        $group: {
          _id: null,
          revenue: { $sum: "$totalPrice" },
          orders: { $sum: 1 },
        },
      },
    ]),
    // Previous period stats
    Order.aggregate([
      {
        $match: {
          createdAt: { $gte: previousPeriodStart, $lt: previousPeriodEnd },
        },
      },
      {
        $group: {
          _id: null,
          revenue: { $sum: "$totalPrice" },
          orders: { $sum: 1 },
        },
      },
    ]),
    // Revenue trend (grouped by day)
    Order.aggregate([
      { $match: { createdAt: { $gte: currentPeriodStart }, isPaid: true } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          revenue: { $sum: "$totalPrice" },
          orders: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]),
    // User growth trend
    User.aggregate([
      { $match: { role: "user", createdAt: { $gte: currentPeriodStart } } },
      {
        $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]),
    // Top selling products
    Order.aggregate([
      { $match: { createdAt: { $gte: currentPeriodStart } } },
      { $unwind: "$orderItems" },
      {
        $group: {
          _id: "$orderItems.product",
          totalSold: { $sum: "$orderItems.quantity" },
          revenue: {
            $sum: { $multiply: ["$orderItems.price", "$orderItems.quantity"] },
          },
        },
      },
      { $sort: { totalSold: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "products",
          localField: "_id",
          foreignField: "_id",
          as: "product",
        },
      },
      { $unwind: "$product" },
      {
        $project: {
          _id: 1,
          name: "$product.name",
          images: "$product.images",
          totalSold: 1,
          revenue: 1,
        },
      },
    ]),
    // Low stock products
    Product.find({ stock: { $lt: 10, $gt: 0 }, isActive: true })
      .sort({ stock: 1 })
      .limit(5)
      .select("name stock images"),
  ]);

  const stats = orderStats[0] || { totalRevenue: 0, paidOrders: 0 };
  const currentStats = currentPeriodStats[0] || { revenue: 0, orders: 0 };
  const previousStats = previousPeriodStats[0] || { revenue: 0, orders: 0 };

  // Calculate comparison percentages
  const calculateChange = (current, previous) => {
    if (!previous || previous === 0) return current > 0 ? 100 : 0;
    return Number((((current - previous) / previous) * 100).toFixed(1));
  };

  // Orders by status
  const ordersByStatus = await Order.aggregate([
    { $group: { _id: "$status", count: { $sum: 1 } } },
  ]);

  // Fill in missing dates for revenue trend (for periods with no orders)
  const filledRevenueTrend = [];
  const dateMap = new Map(revenueTrend.map((d) => [d._id, d]));
  const daysDiff = Math.ceil(
    (now - currentPeriodStart) / (1000 * 60 * 60 * 24),
  );

  for (let i = 0; i < daysDiff; i++) {
    const date = new Date(currentPeriodStart);
    date.setDate(date.getDate() + i);
    const dateStr = date.toISOString().split("T")[0];
    filledRevenueTrend.push({
      date: dateStr,
      revenue: dateMap.get(dateStr)?.revenue || 0,
      orders: dateMap.get(dateStr)?.orders || 0,
    });
  }

  // Fill in missing dates for user growth trend
  const filledUserGrowth = [];
  const userGrowthMap = new Map(userGrowth.map((d) => [d._id, d]));

  for (let i = 0; i < daysDiff; i++) {
    const date = new Date(currentPeriodStart);
    date.setDate(date.getDate() + i);
    const dateStr = date.toISOString().split("T")[0];
    filledUserGrowth.push({
      date: dateStr,
      count: userGrowthMap.get(dateStr)?.count || 0,
    });
  }

  res.json(
    new ApiResponse(200, {
      totalUsers,
      totalProducts,
      totalOrders,
      totalRevenue: stats.totalRevenue || 0,
      paidOrders: stats.paidOrders || 0,
      ordersByStatus: ordersByStatus.reduce((acc, item) => {
        acc[item._id] = item.count;
        return acc;
      }, {}),
      recentOrders,
      revenueTrend: filledRevenueTrend,
      userGrowth: filledUserGrowth,
      topProducts,
      lowStockProducts,
      periodComparison: {
        current: { revenue: currentStats.revenue, orders: currentStats.orders },
        previous: { revenue: previousStats.revenue, orders: previousStats.orders },
        change: {
          revenue: calculateChange(currentStats.revenue, previousStats.revenue),
          orders: calculateChange(currentStats.orders, previousStats.orders),
        },
      },
    }),
  );
});

// @desc    Get all users
// @route   GET /api/admin/users
export const getUsers = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, role } = req.query;

  const query = {};
  if (role) query.role = role;

  const users = await User.find(query)
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(Number(limit));

  const total = await User.countDocuments(query);

  res.json(
    new ApiResponse(200, {
      users,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    }),
  );
});

// @desc    Update user role
// @route   PUT /api/admin/users/:id
export const updateUserRole = asyncHandler(async (req, res) => {
  const { role } = req.body;

  if (!["user", "admin"].includes(role)) {
    throw ApiError.badRequest("Invalid role");
  }

  // Prevent admin from demoting themselves
  if (req.params.id === req.user._id.toString() && role !== "admin") {
    throw ApiError.badRequest("Cannot change your own role");
  }

  const user = await User.findByIdAndUpdate(
    req.params.id,
    { role },
    { new: true },
  ).select("-password -refreshToken");

  if (!user) {
    throw ApiError.notFound("User not found");
  }

  res.json(new ApiResponse(200, { user }, "User role updated"));
});

// @desc    Delete user
// @route   DELETE /api/admin/users/:id
export const deleteUser = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    throw ApiError.notFound("User not found");
  }

  if (user.role === "admin") {
    throw ApiError.badRequest("Cannot delete admin user");
  }

  // Delete avatar from Cloudinary if exists
  if (user.avatar?.public_id) {
    try {
      await cloudinary.uploader.destroy(user.avatar.public_id);
    } catch {
      // Continue with deletion even if Cloudinary fails
    }
  }

  // Cascade delete all related data
  await Promise.all([
    Address.deleteMany({ user: user._id }),
    Cart.deleteOne({ user: user._id }),
    Order.deleteMany({ user: user._id }),
    Review.deleteMany({ user: user._id }),
    Notification.deleteMany({ user: user._id }),
  ]);

  await user.deleteOne();

  res.json(new ApiResponse(200, null, "User and related data deleted"));
});
