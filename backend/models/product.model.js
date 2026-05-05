import mongoose from "mongoose";
import slugify from "slugify";

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Product name is required"],
      trim: true,
      maxlength: [200, "Name cannot exceed 200 characters"],
    },
    slug: {
      type: String,
      unique: true,
      lowercase: true,
    },
    description: {
      type: String,
      required: [true, "Description is required"],
    },
    price: {
      type: Number,
      required: [true, "Price is required"],
      min: [0, "Price cannot be negative"],
    },
    comparePrice: {
      type: Number,
      min: [0, "Compare price cannot be negative"],
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: [true, "Category is required"],
    },
    brand: {
      type: String,
      trim: true,
    },
    images: [
      {
        public_id: String,
        url: String,
      },
    ],
    stock: {
      type: Number,
      default: 0,
      min: [0, "Stock cannot be negative"],
    },
    sold: {
      type: Number,
      default: 0,
    },
    ratings: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    numReviews: {
      type: Number,
      default: 0,
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
    isFlashSale: {
      type: Boolean,
      default: false,
      index: true, // For fast flash sale queries
    },
    flashSaleEndTime: {
      type: Date,
      default: null,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    variants: [
      {
        name: String,
        options: [
          {
            value: String,
            priceModifier: { type: Number, default: 0 },
            stock: { type: Number, default: 0 },
          },
        ],
      },
    ],
    specifications: [
      {
        key: String,
        value: String,
      },
    ],
  },
  { timestamps: true },
);

// Generate slug before save
productSchema.pre("save", function () {
  if (this.isModified("name")) {
    this.slug = slugify(this.name, { lower: true, strict: true });
  }
});

// Index for search
productSchema.index({ name: "text", description: "text", brand: "text" });
productSchema.index({ isActive: 1, category: 1, price: 1, ratings: 1 });
productSchema.index({ isActive: 1 }); // For filtering active products

const Product = mongoose.model("Product", productSchema);

export default Product;
