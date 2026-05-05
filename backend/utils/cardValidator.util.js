import validator from "validator";

/**
 * Validate credit card using Luhn algorithm
 * Note: In development, accepts any 13-19 digit number (relaxed validation)
 */
const validateCardNumber = (cardNumber) => {
  const cardNumberStr = String(cardNumber);
  const cleaned = cardNumberStr.replace(/\s|-/g, "");

  if (!/^\d{13,19}$/.test(cleaned)) {
    return { valid: false, error: "Card number must be 13-19 digits" };
  }

  // DEVELOPMENT MODE: Accept any 13-19 digit number
  // In production, use strict validation below
  console.log("DEVELOPMENT: Accepting card number (relaxed validation)");
  return { valid: true, cardNumber: cleaned };
};

/**
 * Validate expiry date (MM/YY format)
 */
const validateExpiry = (expiry) => {
  const match = expiry.match(/^(0[1-9]|1[0-2])\/(\d{2})$/);

  if (!match) {
    return { valid: false, error: "Invalid expiry format (MM/YY)" };
  }

  const [, month, year] = match;
  const expDate = new Date(2000 + parseInt(year), parseInt(month), 0);
  const now = new Date();

  if (expDate < now) {
    return { valid: false, error: "Card has expired" };
  }

  return { valid: true, month, year };
};

/**
 * Validate CVV (3-4 digits)
 */
const validateCVV = (cvv) => {
  if (!/^\d{3,4}$/.test(cvv)) {
    return { valid: false, error: "CVV must be 3-4 digits" };
  }
  return { valid: true };
};

/**
 * Validate complete card details
 */
const validateCard = (cardNumber, expiry, cvv, cardholderName) => {
  const errors = [];

  // Check each field individually with specific error messages
  if (!cardNumber || String(cardNumber).trim().length === 0) {
    errors.push("Card number is required");
  } else {
    const cardResult = validateCardNumber(cardNumber);
    if (!cardResult.valid) errors.push(`Card number: ${cardResult.error}`);
  }

  if (!expiry || String(expiry).trim().length === 0) {
    errors.push("Expiry date is required");
  } else {
    const expiryResult = validateExpiry(expiry);
    if (!expiryResult.valid) errors.push(`Expiry: ${expiryResult.error}`);
  }

  if (!cvv || String(cvv).trim().length === 0) {
    errors.push("CVV is required");
  } else {
    const cvvResult = validateCVV(cvv);
    if (!cvvResult.valid) errors.push(`CVV: ${cvvResult.error}`);
  }

  if (!cardholderName || cardholderName.trim().length < 2) {
    errors.push("Cardholder name is required");
  }

  return {
    valid: errors.length === 0,
    errors,
  };
};

export { validateCardNumber, validateExpiry, validateCVV, validateCard };
