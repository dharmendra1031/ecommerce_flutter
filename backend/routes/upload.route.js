import { Router } from "express";
import { protect, authorize } from "../middlewares/auth.middleware.js";
import { upload, uploadToCloudinary } from "../middlewares/upload.middleware.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";

const router = Router();

// @desc    Upload images to Cloudinary
// @route   POST /api/upload
router.post(
  "/",
  protect,
  authorize("admin"),
  upload.array("images", 5),
  asyncHandler(async (req, res) => {
    if (!req.files?.length) {
      throw ApiError.badRequest("Please upload at least one image");
    }

    const folder = req.body.folder || "westore";
    const uploadPromises = req.files.map((file) =>
      uploadToCloudinary(file.buffer, folder)
    );
    const results = await Promise.all(uploadPromises);

    res.json(new ApiResponse(200, { images: results }, "Images uploaded"));
  })
);

export default router;
