class AppConstants {
  const AppConstants._();

  static const String appName = 'WeStore';
  static const String appVersion = '1.0.0';

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 500);

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;

  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;

  static const int maxProductImages = 5;
  static const int maxReviewLength = 1000;
  static const int maxAddressCount = 10;
}
