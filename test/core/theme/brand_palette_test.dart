import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/theme/app_text_styles.dart';

/// WCAG 2.x contrast ratio of two opaque colours.
double _contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The brand palette shared with the web dashboard, and the contrast it has
/// to keep: text 4.5:1, icons and other meaningful graphics 3:1.
void main() {
  group('brand palette', () {
    test('uses the brand colours', () {
      expect(AppColors.primary, const Color(0xFF028090));
      expect(AppColors.turquoise, const Color(0xFF45B8C2));
      expect(AppColors.primaryTint, const Color(0xFFD9F3F5));
      expect(AppColors.accentGreen, const Color(0xFF0D9488));
      expect(AppColors.success, const Color(0xFF006B54));
      expect(AppColors.deep, const Color(0xFF002022));
      expect(AppTextStyles.fontFamily, 'Cairo');
    });

    test('the dark theme is built on the deep brand background', () {
      expect(AppDarkColors.background, AppColors.deep);
      expect(AppDarkColors.primary, AppColors.turquoise);
    });
  });

  group('contrast', () {
    const surfaces = {
      'canvas': AppColors.background,
      'card': AppColors.surface,
      'tint': AppColors.primaryTint,
      'soft tint': AppColors.primarySoftBg,
    };

    test('text meets 4.5:1 on every light surface', () {
      const texts = {
        'primary text': AppColors.primaryInk,
        'ink': AppColors.textPrimary,
        'secondary': AppColors.textSecondary,
        'muted': AppColors.textMuted,
        'success': AppColors.success,
        'danger': AppColors.danger,
        'warning': AppColors.warning,
      };
      for (final MapEntry(key: textName, value: text) in texts.entries) {
        for (final MapEntry(key: surfaceName, value: surface)
            in surfaces.entries) {
          expect(_contrast(text, surface), greaterThanOrEqualTo(4.5),
              reason: '$textName on $surfaceName');
        }
      }
    });

    test('white text on the brand fills meets 4.5:1', () {
      expect(_contrast(Colors.white, AppColors.primary),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(Colors.white, AppColors.primaryDark),
          greaterThanOrEqualTo(4.5));
      expect(_contrast(Colors.white, AppColors.success),
          greaterThanOrEqualTo(4.5));
    });

    test('muted icons meet 3:1 on the card and on the canvas', () {
      expect(_contrast(AppColors.iconMuted, AppColors.surface),
          greaterThanOrEqualTo(3));
      expect(_contrast(AppColors.iconMuted, AppColors.background),
          greaterThanOrEqualTo(3));
      expect(_contrast(AppColors.iconMuted, AppColors.primaryTint),
          greaterThanOrEqualTo(3));
    });

    test('the plain brand teal is for fills and icons, not small text', () {
      // 4.43:1 on the canvas: fine for a 3:1 icon, short of the 4.5:1 text
      // minimum. Text uses AppColors.primaryInk. If this ever passes, the
      // two tokens can be merged.
      expect(_contrast(AppColors.primary, AppColors.background), lessThan(4.5));
      expect(_contrast(AppColors.primary, AppColors.background),
          greaterThanOrEqualTo(3));
    });

    test('turquoise is never text: it is 2.4:1 on white', () {
      expect(_contrast(AppColors.turquoise, AppColors.surface), lessThan(3));
    });

    test('pill labels use the text shade', () {
      expect(AppTextStyles.pillLabel.color, AppColors.primaryInk);
    });
  });
}
