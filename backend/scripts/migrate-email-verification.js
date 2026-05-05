import mongoose from "mongoose";
import dotenv from "dotenv";
import User from "../models/user.model.js";

dotenv.config();

/**
 * Migration: Set isEmailVerified to true for all existing users
 * This prevents locking out existing accounts when email verification is enforced
 */
const migrateEmailVerification = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB");

    // Update all users without isEmailVerified field
    const result = await User.updateMany(
      { isEmailVerified: { $exists: false } },
      { $set: { isEmailVerified: true } }
    );

    console.log(`Migration complete:`);
    console.log(`- Matched: ${result.matchedCount} users`);
    console.log(`- Modified: ${result.modifiedCount} users`);

    // Also set isEmailVerified: true for any users with isEmailVerified: false
    // who were created before this feature (optional - remove if not needed)
    const existingUsers = await User.updateMany(
      { 
        isEmailVerified: false,
        createdAt: { $lt: new Date("2024-01-01") } // Adjust date as needed
      },
      { $set: { isEmailVerified: true } }
    );

    console.log(`\nLegacy users updated:`);
    console.log(`- Matched: ${existingUsers.matchedCount} users`);
    console.log(`- Modified: ${existingUsers.modifiedCount} users`);

    process.exit(0);
  } catch (error) {
    console.error("Migration failed:", error.message);
    process.exit(1);
  }
};

// Run migration if executed directly
if (process.argv[1].includes("migrate-email-verification.js")) {
  migrateEmailVerification();
}

export default migrateEmailVerification;
