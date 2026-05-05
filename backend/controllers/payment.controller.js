import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";
import { validateCard } from "../utils/cardValidator.util.js";

// @desc    Validate credit card
// @route   POST /api/payments/validate-card
export const validateCardDetails = asyncHandler(async (req, res) => {
  const { cardNumber, expiry, cvv, cardholderName } = req.body;

  console.log("Validating card:", {
    cardNumber: cardNumber
      ? `${cardNumber.slice(0, 4)}...${cardNumber.slice(-4)}`
      : null,
    expiry,
    cvv: cvv ? "***" : null,
    cardholderName,
  });

  const result = validateCard(cardNumber, expiry, cvv, cardholderName);

  if (!result.valid) {
    console.log("Card validation failed:", result.errors);
    throw ApiError.badRequest("Card validation failed", result.errors);
  }

  res.json(new ApiResponse(200, { valid: true }, "Card is valid"));
});

// @desc    Process mock payment
// @route   POST /api/payments/process
export const processPayment = asyncHandler(async (req, res) => {
  const { cardNumber, expiry, cvv, cardholderName, amount } = req.body;

  // Validate card
  const result = validateCard(cardNumber, expiry, cvv, cardholderName);

  if (!result.valid) {
    throw ApiError.badRequest("Payment failed", result.errors);
  }

  if (!amount || amount <= 0) {
    throw ApiError.badRequest("Invalid amount");
  }

  // Simulate payment processing
  const paymentResult = {
    id: `pay_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
    status: "success",
    updateTime: new Date().toISOString(),
    cardLast4: cardNumber.slice(-4),
    amount,
  };

  res.json(
    new ApiResponse(200, { paymentResult }, "Payment processed successfully"),
  );
});
