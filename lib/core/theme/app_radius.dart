/// Section 2.5 (v2) — Shape & spacing tokens. Card corners ~16-18px per the
/// Master Build Prompt EN (was 24px in the earlier, less-precise spec).
class AppRadius {
  AppRadius._();

  static const double card = 16; // design spec cards
  static const double cardSmall = 16;
  static const double pill = 999;
  static const double sheet = 24;

  /// Material filled buttons (four of the five existing call sites use 14).
  static const double button = 14;
<<<<<<< HEAD

  /// Inner panels inside a card, and the 40x40 icon tile (design spec).
  static const double panel = 12;
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  // FullWidthActionBar (section 2.5 exception): a flow-completion CTA gets
  // noticeably LESS rounding than the usual pill, and no side margin.
  static const double actionBar = 10;
}

class AppSpacing {
  AppSpacing._();

  static const double cardPadding = 16;
  static const double sectionGap = 16;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}
