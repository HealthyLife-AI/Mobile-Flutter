import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

/// Central ThemeData, built once per brightness from the design tokens.
/// Section 0 requirement: build tokens before building any screen.
///
/// [light] is the app's designed look: it is built from exactly the same
/// values as before the design-system pass, so existing screens render
/// unchanged. [dark] mirrors its structure with [AppDarkColors].
///
/// Component themes set only what the design language fixes AND every
/// existing call site already specifies (or what is invisible today), so
/// they change nothing on screen while becoming the default for new
/// widgets. Text buttons, icon buttons, text fields and snack bars keep
/// Material 3's ColorScheme-driven defaults on purpose: existing screens
/// rely on those defaults, and the dark ColorScheme already yields
/// correct dark variants of them.
abstract final class AppTheme {
  static final ThemeData light = _build(
    colors: AppThemeColors.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
  );

  static final ThemeData dark = _build(
    colors: AppThemeColors.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      onPrimary: AppDarkColors.onPrimary,
      inversePrimary: AppColors.primary,
      surface: AppDarkColors.surface,
      onSurface: AppDarkColors.textPrimary,
      onSurfaceVariant: AppDarkColors.textSecondary,
      // The seed's own dark neutrals are teal-tinted; these keep Material's
      // default containers (filled fields, menus, chips) on the slate scale.
      surfaceContainerLowest: AppDarkColors.background,
      surfaceContainerLow: AppDarkColors.surface,
      surfaceContainer: AppDarkColors.surface,
      surfaceContainerHigh: AppDarkColors.hairline,
      surfaceContainerHighest: AppDarkColors.chipInactiveBg,
      outline: AppDarkColors.iconMuted,
      outlineVariant: AppDarkColors.border,
      inverseSurface: AppDarkColors.textPrimary,
      onInverseSurface: AppDarkColors.background,
      error: AppDarkColors.danger,
    ),
  );

  /// Kept for existing call sites; see [AppShadows.soft].
  static const List<BoxShadow> softShadow = AppShadows.soft;

  static ThemeData _build({
    required AppThemeColors colors,
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        // Flat surface, zero elevation — no tinted Material overlay creeping
        // in on scroll. Keeps the header visually continuous with cards.
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.flat,
        scrolledUnderElevation: AppElevation.flat,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.cardTitle.copyWith(color: colors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : colors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.neutralTrack,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: AppElevation.flat,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      // Brand fills keep `#028090` with white text in both modes (4.7:1).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppElevation.flat,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppElevation.flat,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppElevation.fab,
      ),
      // Sheets and dialogs share the confirm sheet's language: canvas
      // background, 24px corners, no tint.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.background,
        modalBackgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        titleTextStyle:
            AppTextStyles.sectionHeading.copyWith(color: colors.textPrimary),
        contentTextStyle:
            AppTextStyles.secondary.copyWith(color: colors.textSecondary),
      ),
      textTheme: TextTheme(
        headlineMedium: AppTextStyles.h1.copyWith(color: colors.textPrimary),
        titleMedium:
            AppTextStyles.sectionHeading.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.body.copyWith(color: colors.textPrimary),
        bodySmall:
            AppTextStyles.secondary.copyWith(color: colors.textSecondary),
      ),
      dividerColor: colors.border,
    );
  }
}
