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
///
/// These constants are the LIGHT palette. Dark counterparts live in
/// [AppDarkColors]; widgets that should follow the active theme read
/// `context.appColors` (see `app_theme_colors.dart`) instead of these
/// constants directly.
class AppColors {
  AppColors._();

  // ---- Brand core tokens ----
  static const Color primary = Color(0xFF028090);

  /// Brand teal for TEXT and small icons on light surfaces. [primary] is
  /// 4.43:1 on the canvas and 4.03:1 on [primaryTint], under the 4.5:1 text
  /// minimum; this shade is 5.3:1 and 5.1:1. Fills keep [primary]: white on
  /// it is 4.67:1.
  static const Color primaryInk = Color(0xFF026E7C);

  /// Brand turquoise, for fills, rings and chart marks. Never for text, and
  /// never under white text (2.4:1).
  static const Color turquoise = Color(0xFF45B8C2);

  /// Brand deep background (cards on the dark surface, the live card).
  static const Color deep = Color(0xFF002022); // design spec Primary
  static const Color primaryTint =
      Color(0xFFD9F3F5); // spec "Selected": badge, icon and selected backgrounds
  static const Color neutralTrack =
      Color(0xFFD5E6E6); // progress-bar UNFILLED track only
  static const Color background = Color(0xFFF5FAF9); // spec Background
  static const Color surface = Color(0xFFFFFFFF); // pure-white card canvas
  static const Color textPrimary = Color(0xFF0B2E30); // spec Ink
  static const Color textSecondary = Color(0xFF2F4F51); // spec Body

  /// Spec "Muted": hints, timestamps and the smallest text.
  static const Color textMuted = Color(0xFF4E6D70);
  static const Color border = Color(0xFFE1ECEC); // spec Border
  static const Color iconMuted = Color(0xFF6F8B8E);
  static const Color danger = Color(0xFFB91C1C); // spec Danger

  // ---- Status pairs from the design spec: text/icon on its own tint ----
  static const Color dangerBg = Color(0xFFFDECEC);
  static const Color success = Color(0xFF006B54);
  static const Color successBg = Color(0xFFE0F5F1);
  static const Color warning = Color(0xFF92400E);
  static const Color warningBg = Color(0xFFFEF3C7);

  /// The due-reminder card: a warm wash with an amber outline.
  static const Color warningCardBg = Color(0xFFFFF7E6);
  static const Color warningCardBorder = Color(0xFFF5C26B);

  /// Spec "Panel": inner panels inside a card, used at 60-70% opacity.
  static const Color panel = Color(0xFFEEF6F5);

  // Legacy aliases kept so earlier-built screens compile unchanged.
  static const Color textSecondaryLegacy = textSecondary;
  static const Color borderLight = border;
  static const Color chipInactiveBg = Color(0xFFE8F1F0); // spec Neutral chip
  static const Color primaryDark =
      Color(0xFF026E7C); // deeper shade of `primary` for gradient depth

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
  static const Color accentGreen = Color(0xFF0D9488);
  static const Color accentGreenBg = Color(0xFFD5F2EE);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentPurpleBg = Color(0xFFEDE9FE);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color accentPinkBg = Color(0xFFFCE7F3);
  static const Color accentIndigo = Color(0xFF6C5CE7);

  static const Color primarySoftBg = Color(0xFFEAF7F8);
  static const Color primarySoftBorder = Color(0xFFA8DCE1);

  // Soft-light neutrals used by the refreshed hero/splash surfaces.
  static const Color canvasSoft = Color(0xFFF5FAF9);
  static const Color hairline = Color(0xFFEAF3F2);

  static const Color ctaVoiceStart = Color(0xFFF472B6);
  static const Color ctaVoiceEnd = Color(0xFFFB923C);
  static const Color voiceModeBgStart = Color(0xFFFDF2F8);
  static const Color voiceModeBgEnd = Color(0xFFFCE7F3);
  static const Color liveCardBgStart = Color(0xFF002022);
  static const Color liveCardBgEnd = Color(0xFF03363A);
  static const Color liveLineGlow = Color(0xFF45B8C2);
  static const Color breathingGradientStart = Color(0xFF026E7C);
  static const Color breathingGradientEnd = Color(0xFF028090);
  static const Color lockedOverlay =
      Color(0xBFFFFFFF); // rgba(255,255,255,.75) per v2 section 7.14

  // Flat "gradient" (both stops the same solid primary) — see class doc.
  static const LinearGradient primaryGradient =
      LinearGradient(colors: [primary, primary]);
  static const LinearGradient primaryDarkGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Brand gradient for full-bleed surfaces (splash, hero cards): a rich but
  /// subtle `#028090` falloff, never a multi-hue rainbow.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF0391A2), Color(0xFF028090), Color(0xFF026E7C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [Color(0xFF02899A), Color(0xFF028090), Color(0xFF026E7C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient ctaVoiceGradient =
      LinearGradient(colors: [ctaVoiceStart, ctaVoiceEnd]);
  static const LinearGradient breathingGradient =
      LinearGradient(colors: [breathingGradientStart, breathingGradientEnd]);
  static const LinearGradient liveCardGradient = LinearGradient(
    colors: [liveCardBgStart, liveCardBgEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // The success-screen glow circle: primary to a lighter shade of itself
  // (section 3, M6) — a real (subtle) gradient, distinct from CTA buttons.
  static const LinearGradient successGlowGradient = LinearGradient(
    colors: [primary, Color(0xFF0D9488)],
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

/// Dark-mode counterparts of the semantic [AppColors] tokens.
///
/// Built from the brand palette: the deep background (`#002022`), the light
/// cyan family for text and the brand turquoise (`#45B8C2`) as the accent,
/// because `#028090` itself is too dark for text on dark surfaces. Contrast ratios
/// below are enforced by `test/app_theme_test.dart`.
///
/// Brand fills that carry white text (CTAs, filled buttons) keep
/// [AppColors.primary] in both modes — white on `#028090` is 4.7:1.
class AppDarkColors {
  AppDarkColors._();

  /// Accent for text, icons and outlines on dark surfaces (6.2:1 on
  /// [background], 5.1:1 on [surface]).
  static const Color primary = Color(0xFF45B8C2);

  /// Text/icons placed on a [primary] fill.
  static const Color onPrimary = Color(0xFF002022);

  /// Badge/icon backgrounds: [primary] at 18% over [surface].
  static const Color primaryTint = Color(0xFF0B3A40);

  /// Softer accent wash: [primary] at 12% over [surface].
  static const Color primarySoftBg = Color(0xFF0A3338);

  /// The light palette's text color, inverted into the canvas.
  static const Color background = Color(0xFF002022);
  static const Color canvasSoft = background;

  /// Raised card surfaces, one slate step above [background].
  static const Color surface = Color(0xFF04282B);

  /// The light palette's canvas, inverted into primary text.
  static const Color textPrimary = Color(0xFFE6F4F5);
  static const Color textSecondary = Color(0xFF9DBFC2);

  static const Color border = Color(0xFF12444A);
  static const Color hairline = Color(0xFF0E3A3F);

  /// The light palette's secondary text, reused for muted icons (3:1 on
  /// [surface], the non-text UI threshold).
  static const Color iconMuted = Color(0xFF5F9094);

  static const Color chipInactiveBg = Color(0xFF0F3F45);
  static const Color neutralTrack = Color(0xFF12444A);

  /// One step lighter than [AppColors.danger] so error text stays readable
  /// on [surface].
  static const Color danger = Color(0xFFF87171);
}
