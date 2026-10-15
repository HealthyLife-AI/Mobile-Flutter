import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app's semantic color roles, resolved for the active theme.
///
/// [ColorScheme] covers Material's own roles; these are the brand roles it
/// has no slot for (secondary text, hairlines, tints, tracks…). [light] is
/// exactly the existing [AppColors] palette and [dark] is [AppDarkColors], so
/// no value is defined twice.
///
/// Widgets that should follow light/dark mode read `context.appColors.x`
/// rather than `AppColors.x`. Existing screens still use the constants
/// directly — they are migrated screen by screen, not in this phase.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.primaryTint,
    required this.primarySoftBg,
    required this.background,
    required this.canvasSoft,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.hairline,
    required this.iconMuted,
    required this.chipInactiveBg,
    required this.neutralTrack,
    required this.danger,
  });

  /// Accent for text, icons and outlines.
  final Color primary;

  /// Badge / icon-tile backgrounds behind [primary] glyphs.
  final Color primaryTint;
  final Color primarySoftBg;

  /// Page canvas (scaffold) and the flat-sheet background.
  final Color background;
  final Color canvasSoft;

  /// Cards, app bars and other raised surfaces.
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color hairline;
  final Color iconMuted;
  final Color chipInactiveBg;

  /// Unfilled part of progress bars.
  final Color neutralTrack;
  final Color danger;

  static const AppThemeColors light = AppThemeColors(
    primary: AppColors.primary,
    primaryTint: AppColors.primaryTint,
    primarySoftBg: AppColors.primarySoftBg,
    background: AppColors.background,
    canvasSoft: AppColors.canvasSoft,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    hairline: AppColors.hairline,
    iconMuted: AppColors.iconMuted,
    chipInactiveBg: AppColors.chipInactiveBg,
    neutralTrack: AppColors.neutralTrack,
    danger: AppColors.danger,
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: AppDarkColors.primary,
    primaryTint: AppDarkColors.primaryTint,
    primarySoftBg: AppDarkColors.primarySoftBg,
    background: AppDarkColors.background,
    canvasSoft: AppDarkColors.canvasSoft,
    surface: AppDarkColors.surface,
    textPrimary: AppDarkColors.textPrimary,
    textSecondary: AppDarkColors.textSecondary,
    border: AppDarkColors.border,
    hairline: AppDarkColors.hairline,
    iconMuted: AppDarkColors.iconMuted,
    chipInactiveBg: AppDarkColors.chipInactiveBg,
    neutralTrack: AppDarkColors.neutralTrack,
    danger: AppDarkColors.danger,
  );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primaryTint,
    Color? primarySoftBg,
    Color? background,
    Color? canvasSoft,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? hairline,
    Color? iconMuted,
    Color? chipInactiveBg,
    Color? neutralTrack,
    Color? danger,
  }) =>
      AppThemeColors(
        primary: primary ?? this.primary,
        primaryTint: primaryTint ?? this.primaryTint,
        primarySoftBg: primarySoftBg ?? this.primarySoftBg,
        background: background ?? this.background,
        canvasSoft: canvasSoft ?? this.canvasSoft,
        surface: surface ?? this.surface,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        border: border ?? this.border,
        hairline: hairline ?? this.hairline,
        iconMuted: iconMuted ?? this.iconMuted,
        chipInactiveBg: chipInactiveBg ?? this.chipInactiveBg,
        neutralTrack: neutralTrack ?? this.neutralTrack,
        danger: danger ?? this.danger,
      );

  /// Interpolated so [AnimatedTheme] can cross-fade light ↔ dark.
  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppThemeColors(
      primary: mix(primary, other.primary),
      primaryTint: mix(primaryTint, other.primaryTint),
      primarySoftBg: mix(primarySoftBg, other.primarySoftBg),
      background: mix(background, other.background),
      canvasSoft: mix(canvasSoft, other.canvasSoft),
      surface: mix(surface, other.surface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      border: mix(border, other.border),
      hairline: mix(hairline, other.hairline),
      iconMuted: mix(iconMuted, other.iconMuted),
      chipInactiveBg: mix(chipInactiveBg, other.chipInactiveBg),
      neutralTrack: mix(neutralTrack, other.neutralTrack),
      danger: mix(danger, other.danger),
    );
  }
}

/// `context.appColors` — the active theme's [AppThemeColors]. Falls back to
/// the light palette under a bare [Theme] that never registered the
/// extension (e.g. an isolated widget test).
extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;
}
