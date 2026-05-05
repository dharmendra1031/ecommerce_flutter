import jwt from "jsonwebtoken";
import crypto from "crypto";
import User from "../models/user.model.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";
import sendEmail from "../utils/email.util.js";

// Generate tokens
const generateTokens = (userId) => {
  const accessToken = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE,
  });
  const refreshToken = jwt.sign(
    { id: userId },
    process.env.JWT_REFRESH_SECRET,
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRE,
    },
  );
  return { accessToken, refreshToken };
};

// @desc    Register user
// @route   POST /api/auth/register
export const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw ApiError.badRequest("Email already registered");
  }

  const user = await User.create({ name, email, password });
  const { accessToken, refreshToken } = generateTokens(user._id);

  user.refreshToken = refreshToken;

  // DEV_AUTO_VERIFY: Auto-verify in development mode
  if (process.env.DEV_AUTO_VERIFY === 'true') {
    user.isEmailVerified = true;
    await user.save();
  } else {
    // Production: Send verification email
    const verificationToken = user.generateEmailVerificationToken();
    await user.save();

    const verificationUrl = `${process.env.CLIENT_URL}/verify-email/${verificationToken}`;

    try {
      await sendEmail({
        to: user.email,
        subject: "WeStore - Verify Your Email",
        html: `
          <h1>Email Verification</h1>
          <p>Thank you for registering. Please click the link below to verify your email:</p>
          <a href="${verificationUrl}">${verificationUrl}</a>
          <p>This link expires in 24 hours.</p>
        `,
      });
    } catch (error) {
      console.error("Failed to send verification email:", error.message);
    }
  }

  res.status(201).json(
    new ApiResponse(
      201,
      {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          isEmailVerified: user.isEmailVerified,
        },
        accessToken,
        refreshToken,
      },
      process.env.DEV_AUTO_VERIFY === 'true' 
        ? "Registration successful"
        : "Registration successful. Check your email to verify your account.",
    ),
  );
});

// @desc    Login user
// @route   POST /api/auth/login
export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select("+password");
  if (!user || !(await user.comparePassword(password))) {
    throw ApiError.unauthorized("Invalid email or password");
  }

  const { accessToken, refreshToken } = generateTokens(user._id);

  user.refreshToken = refreshToken;
  await user.save();

  res.json(
    new ApiResponse(
      200,
      {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          avatar: user.avatar,
          isEmailVerified: user.isEmailVerified,
        },
        accessToken,
        refreshToken,
      },
      "Login successful",
    ),
  );
});

// @desc    Logout user
// @route   POST /api/auth/logout
export const logout = asyncHandler(async (req, res) => {
  await User.findByIdAndUpdate(req.user._id, { refreshToken: null });
  res.json(new ApiResponse(200, null, "Logout successful"));
});

// @desc    Refresh access token
// @route   POST /api/auth/refresh-token
export const refreshToken = asyncHandler(async (req, res) => {
  const { refreshToken: token } = req.body;

  if (!token) {
    throw ApiError.badRequest("Refresh token required");
  }

  const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
  const user = await User.findById(decoded.id).select("+refreshToken");

  if (!user || user.refreshToken !== token) {
    throw ApiError.unauthorized("Invalid refresh token");
  }

  const { accessToken, refreshToken: newRefreshToken } = generateTokens(
    user._id,
  );

  user.refreshToken = newRefreshToken;
  await user.save();

  res.json(
    new ApiResponse(200, { accessToken, refreshToken: newRefreshToken }),
  );
});

// @desc    Get current user
// @route   GET /api/auth/me
export const getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);

  const sanitized = user.toObject();
  if (sanitized.savedCard?.cardNumber) {
    delete sanitized.savedCard.cardNumber;
  }

  res.json(new ApiResponse(200, { user: sanitized }));
});

// @desc    Forgot password
// @route   POST /api/auth/forgot-password
export const forgotPassword = asyncHandler(async (req, res) => {
  const user = await User.findOne({ email: req.body.email });

  if (!user) {
    return res.json(
      new ApiResponse(200, null, "If that email exists, a reset link has been sent"),
    );
  }

  const resetToken = user.generateResetToken();
  await user.save();

  const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;

  try {
    await sendEmail({
      to: user.email,
      subject: "WeStore - Password Reset",
      html: `
        <h1>Password Reset</h1>
        <p>Click the link below to reset your password:</p>
        <a href="${resetUrl}">${resetUrl}</a>
        <p>This link expires in 15 minutes.</p>
      `,
    });

    res.json(new ApiResponse(200, null, "Reset email sent"));
  } catch (error) {
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();
    throw ApiError.internal("Email could not be sent");
  }
});

// @desc    Reset password
// @route   PUT /api/auth/reset-password/:token
export const resetPassword = asyncHandler(async (req, res) => {
  const hashedToken = crypto
    .createHash("sha256")
    .update(req.params.token)
    .digest("hex");

  const user = await User.findOne({
    resetPasswordToken: hashedToken,
    resetPasswordExpire: { $gt: Date.now() },
  });

  if (!user) {
    throw ApiError.badRequest("Invalid or expired token");
  }

  user.password = req.body.password;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpire = undefined;
  await user.save();

  res.json(new ApiResponse(200, null, "Password reset successful"));
});

// @desc    Update password
// @route   PUT /api/auth/update-password
export const updatePassword = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).select("+password +refreshToken");

  if (!(await user.comparePassword(req.body.currentPassword))) {
    throw ApiError.badRequest("Current password is incorrect");
  }

  user.password = req.body.newPassword;
  user.refreshToken = null;
  await user.save();

  res.json(new ApiResponse(200, null, "Password updated. Please login again."));
});

// @desc    Send verification email
// @route   POST /api/auth/send-verification
export const sendVerificationEmail = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);

  if (user.isEmailVerified) {
    throw ApiError.badRequest("Email already verified");
  }

  // DEV_AUTO_VERIFY: Auto-verify in development mode
  if (process.env.DEV_AUTO_VERIFY === 'true') {
    user.isEmailVerified = true;
    await user.save();
    return res.json(
      new ApiResponse(200, null, "Auto-verified (dev mode)")
    );
  }

  // Check if token was sent recently (rate limit: 3 per hour)
  if (user.emailVerificationExpire && 
      user.emailVerificationExpire > Date.now() - 55 * 60 * 1000) {
    throw ApiError.badRequest("Please wait before requesting another verification email");
  }

  const verificationToken = user.generateEmailVerificationToken();
  await user.save();

  const verificationUrl = `${process.env.CLIENT_URL}/verify-email/${verificationToken}`;

  try {
    await sendEmail({
      to: user.email,
      subject: "WeStore - Verify Your Email",
      html: `
        <h1>Email Verification</h1>
        <p>Please click the link below to verify your email:</p>
        <a href="${verificationUrl}">${verificationUrl}</a>
        <p>This link expires in 24 hours.</p>
      `,
    });

    res.json(new ApiResponse(200, null, "Verification email sent"));
  } catch (error) {
    throw ApiError.internal("Email could not be sent");
  }
});

// @desc    Verify email
// @route   GET /api/auth/verify-email/:token
export const verifyEmail = asyncHandler(async (req, res) => {
  const hashedToken = crypto
    .createHash("sha256")
    .update(req.params.token)
    .digest("hex");

  const user = await User.findOne({
    emailVerificationToken: hashedToken,
    emailVerificationExpire: { $gt: Date.now() },
  });

  if (!user) {
    throw ApiError.badRequest("Invalid or expired verification token");
  }

  user.isEmailVerified = true;
  user.emailVerificationToken = undefined;
  user.emailVerificationExpire = undefined;
  await user.save();

  res.json(new ApiResponse(200, null, "Email verified successfully"));
});

// @desc    Dev verify user (development only)
// @route   GET /api/auth/dev-verify/:userId
export const devVerifyUser = asyncHandler(async (req, res) => {
  // Only available in development
  if (process.env.NODE_ENV !== 'development') {
    return res.status(404).json({ success: false, message: 'Not found' });
  }

  const user = await User.findById(req.params.userId);

  if (!user) {
    throw ApiError.notFound("User not found");
  }

  user.isEmailVerified = true;
  await user.save();

  res.json(new ApiResponse(200, null, "User verified (dev mode)"));
});
