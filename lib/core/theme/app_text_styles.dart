import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Section 2.2 — Typography tokens. Rounded sans-serif family,
/// weights/sizes fixed centrally so no screen hardcodes a TextStyle.
///
/// Font: Tajawal (SIL OFL) is bundled from `assets/fonts/` and declared under
/// `flutter: fonts:` in pubspec.yaml at weights 400, 500, 700 and 800. Tajawal
/// has no 600 face, so the w600 styles use the Bold face (700), the next weight up.
class AppTextStyles {
  AppTextStyles._();

  /// Family used by every token and by the theme. Bundled, see the note above.
  static const String fontFamily =
      'Tajawal'; // rounded, covers Arabic and Latin

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 28,
    color: AppColors.textPrimary,
  );

  static const TextStyle metricMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w800,
    fontSize: 22,
    color: AppColors.textPrimary,
  );

  static const TextStyle pillLabel = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    color: AppColors.primary,
  );

  static const TextStyle ctaText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.white,
  );
}
