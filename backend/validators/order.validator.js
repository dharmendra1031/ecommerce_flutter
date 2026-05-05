import { body } from "express-validator";

export const createOrderValidator = [
  body("shippingAddress.fullName")
    .trim()
    .notEmpty()
    .withMessage("Full name is required"),
  body("shippingAddress.phone")
    .trim()
    .notEmpty()
    .withMessage("Phone is required"),
  body("shippingAddress.address")
    .trim()
    .notEmpty()
    .withMessage("Address is required"),
  body("shippingAddress.city")
    .trim()
    .notEmpty()
    .withMessage("City is required"),
  body("paymentMethod")
    .isIn(["card", "cod"])
    .withMessage("Invalid payment method"),
];

export const cardPaymentValidator = [
  body("cardNumber").trim().notEmpty().withMessage("Card number is required"),
  body("expiry").trim().notEmpty().withMessage("Expiry is required"),
  body("cvv").trim().notEmpty().withMessage("CVV is required"),
  body("cardholderName")
    .trim()
    .notEmpty()
    .withMessage("Cardholder name is required"),
];
