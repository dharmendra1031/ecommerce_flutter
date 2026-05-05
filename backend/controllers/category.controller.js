import Category from "../models/category.model.js";
import Product from "../models/product.model.js";
import ApiError from "../utils/ApiError.js";
import ApiResponse from "../utils/ApiResponse.js";
import asyncHandler from "../utils/asyncHandler.js";
import {
  uploadToCloudinary,
  deleteFromCloudinary,
} from "../middlewares/upload.middleware.js";

// @desc    Get all categories (tree structure)
// @route   GET /api/categories
export const getCategories = asyncHandler(async (req, res) => {
  const { tree } = req.query;

  if (tree === "true") {
    // Return tree structure (root categories with subcategories)
    const categories = await Category.find({
      parent: null,
      isActive: true,
    }).populate({
      path: "subcategories",
      match: { isActive: true },
      populate: { path: "subcategories", match: { isActive: true } },
    });
    return res.json(new ApiResponse(200, { categories }));
  }

  const categories = await Category.find({ isActive: true }).populate(
    "parent",
    "name slug",
  );
  res.json(new ApiResponse(200, { categories }));
});

// @desc    Get single category
// @route   GET /api/categories/:id
export const getCategory = asyncHandler(async (req, res) => {
  const category = await Category.findById(req.params.id)
    .populate("parent", "name slug")
    .populate("subcategories");

  if (!category) {
    throw ApiError.notFound("Category not found");
  }

  res.json(new ApiResponse(200, { category }));
});

// @desc    Create category (Admin)
// @route   POST /api/categories
export const createCategory = asyncHandler(async (req, res) => {
  // Validate parent category if provided
  if (req.body.parent) {
    const parentCategory = await Category.findById(req.body.parent);
    if (!parentCategory) {
      throw ApiError.notFound("Parent category not found");
    }
  }

  const category = await Category.create(req.body);
  res.status(201).json(new ApiResponse(201, { category }, "Category created"));
});

// @desc    Update category (Admin)
// @route   PUT /api/categories/:id
export const updateCategory = asyncHandler(async (req, res) => {
  const allowedFields = ["name", "description", "image", "parent", "isActive"];

  const updateData = {};
  for (const field of allowedFields) {
    if (req.body[field] !== undefined) {
      updateData[field] = req.body[field];
    }
  }

  // Validate parent category if provided
  if (updateData.parent) {
    // Prevent self-reference
    if (updateData.parent === req.params.id) {
      throw ApiError.badRequest("Category cannot be its own parent");
    }
    const parentCategory = await Category.findById(updateData.parent);
    if (!parentCategory) {
      throw ApiError.notFound("Parent category not found");
    }
  }

  const category = await Category.findByIdAndUpdate(req.params.id, updateData, {
    new: true,
    runValidators: true,
  });

  if (!category) {
    throw ApiError.notFound("Category not found");
  }

  res.json(new ApiResponse(200, { category }, "Category updated"));
});

// @desc    Delete category (Admin)
// @route   DELETE /api/categories/:id
export const deleteCategory = asyncHandler(async (req, res) => {
  const category = await Category.findById(req.params.id);

  if (!category) {
    throw ApiError.notFound("Category not found");
  }

  // Check for subcategories
  const hasChildren = await Category.exists({ parent: req.params.id });
  if (hasChildren) {
    throw ApiError.badRequest("Cannot delete category with subcategories");
  }

  // Check for products using this category
  const hasProducts = await Product.exists({ category: req.params.id });
  if (hasProducts) {
    throw ApiError.badRequest("Cannot delete category that has products. Reassign or remove products first.");
  }

  // Delete image from Cloudinary
  if (category.image?.public_id) {
    await deleteFromCloudinary(category.image.public_id);
  }

  await category.deleteOne();
  res.json(new ApiResponse(200, null, "Category deleted"));
});

// @desc    Upload category image (Admin)
// @route   PUT /api/categories/:id/image
export const uploadCategoryImage = asyncHandler(async (req, res) => {
  const category = await Category.findById(req.params.id);

  if (!category) {
    throw ApiError.notFound("Category not found");
  }

  if (!req.file) {
    throw ApiError.badRequest("Please upload an image");
  }

  // Delete old image
  if (category.image?.public_id) {
    await deleteFromCloudinary(category.image.public_id);
  }

  const result = await uploadToCloudinary(
    req.file.buffer,
    "westore/categories",
  );
  category.image = result;
  await category.save();

  res.json(new ApiResponse(200, { image: category.image }, "Image uploaded"));
});
