import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

/// Central ThemeData built once from the tokens above.
/// Section 0 requirement: build tokens before building any screen.
class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppTextStyles.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      // Flat white, zero elevation — no tinted Material overlay creeping in
      // on scroll. Keeps the header visually continuous with card surfaces.
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.cardTitle,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.neutralTrack,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: AppTextStyles.h1,
      titleMedium: AppTextStyles.sectionHeading,
      bodyLarge: AppTextStyles.body,
      bodySmall: AppTextStyles.secondary,
    ),
    dividerColor: AppColors.borderLight,
  );

  /// Soft, low-contrast shadow per spec: blur 20-30, opacity 0.06-0.10.
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
