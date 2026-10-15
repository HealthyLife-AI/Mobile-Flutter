/// Section 2.5 (v2) — Shape & spacing tokens. Card corners ~16-18px per the
/// Master Build Prompt EN (was 24px in the earlier, less-precise spec).
class AppRadius {
  AppRadius._();

  static const double card = 18;
  static const double cardSmall = 16;
  static const double pill = 999;
  static const double sheet = 24;

  /// Material filled buttons (four of the five existing call sites use 14).
  static const double button = 14;
  // FullWidthActionBar (section 2.5 exception): a flow-completion CTA gets
  // noticeably LESS rounding than the usual pill, and no side margin.
  static const double actionBar = 10;
}

class AppSpacing {
  AppSpacing._();

  static const double cardPadding = 18;
  static const double sectionGap = 22;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}
