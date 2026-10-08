import 'package:flutter/material.dart';

/// Single source of truth for every color used across the app.
///
/// Brand palette: `#028090` (Primary Teal/Blue) is the dominant accent and is
/// referenced through `AppColors.primary` everywhere, so this one token
/// recolors the entire app — theme, painters, icons, tab indicators and CTAs.
///
/// 60-30-10 Soft Light structure:
///   * 60% — near-white canvas (`background`) and white card surfaces (`surface`)
///   * 30% — neutral greys for borders, tracks and secondary copy
///   * 10% — `#028090` accents, tints and primary actions
///
/// `primaryGradient` is kept as a two-stop gradient of the SAME color purely
/// so existing `gradient:` call sites keep compiling; it renders visually
/// identical to a flat fill. New screens should prefer `color:`.
class AppColors {
  AppColors._();

  // ---- Brand core tokens ----
  static const Color primary = Color(0xFF028090); // brand Primary Teal/Blue
  static const Color primaryTint = Color(0xFFE3F3F5); // light badge/icon backgrounds
  static const Color neutralTrack = Color(0xFFE7EDF1); // progress-bar UNFILLED track only
  static const Color background = Color(0xFFF8FAFC); // ultra-light clean canvas tint
  static const Color surface = Color(0xFFFFFFFF); // pure-white card canvas
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE8EDF2);
  static const Color iconMuted = Color(0xFFCBD5E1);
  static const Color danger = Color(0xFFEF4444); // standard extension, no error screenshots exist yet

  // Legacy aliases kept so earlier-built screens compile unchanged.
  static const Color textSecondaryLegacy = textSecondary;
  static const Color borderLight = border;
  static const Color chipInactiveBg = Color(0xFFF1F5F9);
  static const Color primaryDark = Color(0xFF016B77); // deeper shade of `primary` for gradient depth

  // ---- 2.2 Meal-type icon colors (confirmed) ----
  // Breakfast and lunch share the same "daytime" family, distinguished by
  // icon shape (sunrise vs. full sun) rather than color.
  static const Color mealBreakfastBg = Color(0xFFFDE6D2);
  static const Color mealBreakfastIcon = Color(0xFFEF7D3B);
  static const Color mealLunchBg = Color(0xFFFDE6D2);
  static const Color mealLunchIcon = Color(0xFFEF7D3B);
  static const Color mealSnackBg = Color(0xFFDFF3E4);
  static const Color mealSnackIcon = Color(0xFF3FA66B);
  static const Color mealDinnerBg = Color(0xFFE6E1F7);
  static const Color mealDinnerIcon = Color(0xFF6C5CE7);

  // ---- Macro / accent tokens (not redocumented in v2, kept from v1 —
  // used for macro pills and progress-chart lines, which v2 doesn't cover) ----
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentOrangeBg = Color(0xFFFFEDD5);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentBlueBg = Color(0xFFDBEAFE);
  static const Color accentGreen = Color(0xFF34D399);
  static const Color accentGreenBg = Color(0xFFD1FAE5);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentPurpleBg = Color(0xFFEDE9FE);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color accentPinkBg = Color(0xFFFCE7F3);
  static const Color accentIndigo = Color(0xFF6C5CE7);

  static const Color primarySoftBg = Color(0xFFEAF5F7);
  static const Color primarySoftBorder = Color(0xFFBFDEE4);

  // Soft-light neutrals used by the refreshed hero/splash surfaces.
  static const Color canvasSoft = Color(0xFFF8FAFC);
  static const Color hairline = Color(0xFFEFF3F7);

  static const Color ctaVoiceStart = Color(0xFFF472B6);
  static const Color ctaVoiceEnd = Color(0xFFFB923C);
  static const Color voiceModeBgStart = Color(0xFFFDF2F8);
  static const Color voiceModeBgEnd = Color(0xFFFCE7F3);
  static const Color liveCardBgStart = Color(0xFF0B1220);
  static const Color liveCardBgEnd = Color(0xFF111827);
  static const Color liveLineGlow = Color(0xFF34D399);
  static const Color breathingGradientStart = Color(0xFF1E3A8A);
  static const Color breathingGradientEnd = Color(0xFF4338CA);
  static const Color lockedOverlay = Color(0xBFFFFFFF); // rgba(255,255,255,.75) per v2 section 7.14

  // Flat "gradient" (both stops the same solid primary) — see class doc.
  static const LinearGradient primaryGradient = LinearGradient(colors: [primary, primary]);
  static const LinearGradient primaryDarkGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  /// Brand gradient for full-bleed surfaces (splash, hero cards): a rich but
  /// subtle `#028090` falloff, never a multi-hue rainbow.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF028090), Color(0xFF026C79), Color(0xFF014E58)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [Color(0xFF028C9C), Color(0xFF028090), Color(0xFF015F6B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient ctaVoiceGradient = LinearGradient(colors: [ctaVoiceStart, ctaVoiceEnd]);
  static const LinearGradient breathingGradient = LinearGradient(colors: [breathingGradientStart, breathingGradientEnd]);
  static const LinearGradient liveCardGradient = LinearGradient(
    colors: [liveCardBgStart, liveCardBgEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // The success-screen glow circle: primary to a lighter shade of itself
  // (section 3, M6) — a real (subtle) gradient, distinct from CTA buttons.
  static const LinearGradient successGlowGradient = LinearGradient(
    colors: [primary, Color(0xFF03A8BA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color badgeColor(String macro) {
    switch (macro) {
      case 'protein':
        return accentGreen;
      case 'carbs':
        return accentOrange;
      case 'fat':
        return accentPurple;
      case 'fiber':
        return accentBlue;
      default:
        return primary;
    }
  }

  static Color badgeBgColor(String macro) {
    switch (macro) {
      case 'protein':
        return accentGreenBg;
      case 'carbs':
        return accentOrangeBg;
      case 'fat':
        return accentPurpleBg;
      case 'fiber':
        return accentBlueBg;
      default:
        return chipInactiveBg;
    }
  }

  /// FoodTagColorMapper (2.3) — colors a search-result's circular icon by
  /// nutritional CATEGORY, never by the literal food name. Deliberately a
  /// separate system from mealType colors above (2.2) — do not conflate.
  static Color foodTagBg(String category) {
    switch (category) {
      case 'redFruit':
        return const Color(0xFFFCE4E4);
      case 'greenFruit':
        return accentPurpleBg;
      case 'naturalSugar':
        return accentGreenBg;
      case 'dairy':
        return const Color(0xFFE0F2FE);
      case 'cookedProtein':
        return const Color(0xFFEAE7F5);
      case 'carb':
        return accentBlueBg;
      case 'nuts':
        return const Color(0xFFE3F5E9);
      default:
        return chipInactiveBg;
    }
  }

  static Color foodTagIcon(String category) {
    switch (category) {
      case 'redFruit':
        return const Color(0xFFE0554E);
      case 'greenFruit':
        return accentPurple;
      case 'naturalSugar':
        return accentGreen;
      case 'dairy':
        return const Color(0xFF38BDF8);
      case 'cookedProtein':
        return const Color(0xFF6C5CE7);
      case 'carb':
        return const Color(0xFF60A5FA);
      case 'nuts':
        return const Color(0xFF3FA66B);
      default:
        return textSecondary;
    }
  }
}
