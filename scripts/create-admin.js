import "dotenv/config";
import mongoose from "mongoose";
import User from "../backend/models/user.model.js";
import connectDB from "../backend/config/db.js";

const createAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("Connected to MongoDB...");

    const adminEmail = "admin@westore.com";
    const adminPassword = "password123";

    const existingAdmin = await User.findOne({ email: adminEmail });

    if (existingAdmin) {
      if (existingAdmin.role !== "admin") {
        existingAdmin.role = "admin";
        await existingAdmin.save();
        console.log("Existing user promoted to admin.");
      } else {
        console.log("Admin user already exists.");
      }
    } else {
      await User.create({
        name: "WeStore Admin",
        email: adminEmail,
        password: adminPassword,
        role: "admin",
      });
      console.log("Admin user created successfully.");
    }

    console.log(`Email: ${adminEmail}`);
    console.log(`Password: ${adminPassword}`);
  } catch (error) {
    console.error("Error creating admin:", error);
  } finally {
    await mongoose.disconnect();
    process.exit();
  }
};

createAdmin();
