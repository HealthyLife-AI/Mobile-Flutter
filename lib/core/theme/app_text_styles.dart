import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Section 2.2 — Typography tokens. Rounded sans-serif family,
/// weights/sizes fixed centrally so no screen hardcodes a TextStyle.
///
<<<<<<< HEAD
/// Font: Cairo (SIL OFL), the family the design spec names, is bundled from
/// `assets/fonts/` at weights 400, 500, 600, 700 and 800. Sizes follow the
/// spec: headings 20 Bold, card titles 16 Bold, body 14-15, small 12,
/// smallest 11.
=======
/// Font: Tajawal (SIL OFL) is bundled from `assets/fonts/` and declared under
/// `flutter: fonts:` in pubspec.yaml at weights 400, 500, 700 and 800. Tajawal
/// has no 600 face, so the w600 styles use the Bold face (700), the next weight up.
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
class AppTextStyles {
  AppTextStyles._();

  /// Family used by every token and by the theme. Bundled, see the note above.
<<<<<<< HEAD
  static const String fontFamily = 'Cairo'; // covers Arabic and Latin
=======
  static const String fontFamily =
      'Tajawal'; // rounded, covers Arabic and Latin
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
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

  /// The smallest size in the spec (11), for hints and timestamps.
  static const TextStyle tiny = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textMuted,
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
    fontSize: 12,
    color: AppColors.primary,
  );

  static const TextStyle ctaText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.white,
  );
}
