import multer from "multer";
import { cloudinary } from "../config/cloudinary.js";
import ApiError from "../utils/ApiError.js";

// Memory storage for Cloudinary upload
const storage = multer.memoryStorage();

// File filter for images only
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new ApiError(400, "Only image files are allowed"), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
});

/**
 * Upload buffer to Cloudinary
 */
const uploadToCloudinary = (buffer, folder = "westore") => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: "image" },
      (error, result) => {
        if (error) reject(error);
        else resolve({ public_id: result.public_id, url: result.secure_url });
      },
    );
    stream.end(buffer);
  });
};

/**
 * Delete image from Cloudinary
 */
const deleteFromCloudinary = async (publicId) => {
  await cloudinary.uploader.destroy(publicId);
};

export { upload, uploadToCloudinary, deleteFromCloudinary };
