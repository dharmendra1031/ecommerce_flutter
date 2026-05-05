import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary brand color
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5C);
  static const Color primaryDark = Color(0xFFE55A2B);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Neutral colors - Light mode
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceVariantLight = Color(0xFF6C757D);
  static const Color outlineLight = Color(0xFFDEE2E6);

  // Neutral colors - Dark mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = Color(0xFFADB5BD);
  static const Color outlineDark = Color(0xFF495057);

  // Order status colors
  static const Color pending = Color(0xFFFFA726);
  static const Color processing = Color(0xFF42A5F5);
  static const Color shipped = Color(0xFFAB47BC);
  static const Color delivered = Color(0xFF66BB6A);
  static const Color cancelled = Color(0xFFEF5350);
}
