import 'package:flutter/material.dart';

/// Shadow tokens. The design is flat-first: depth comes from soft, low-
/// contrast shadows rather than Material elevation.
abstract final class AppShadows {
  /// Soft, low-contrast card shadow per spec: blur 20-30, opacity 0.06-0.10.
  /// (`Color.from` is the const spelling of
  /// `Colors.black.withValues(alpha: 0.06)` — the exact same color.)
  static const List<BoxShadow> soft = [
    BoxShadow(
<<<<<<< HEAD
      // Design spec: 0 4 16 rgba(17,28,45,.07).
      color: Color(0x12111C2D),
      blurRadius: 16,
      offset: Offset(0, 4),
=======
      color: Color.from(alpha: 0.06, red: 0, green: 0, blue: 0),
      blurRadius: 24,
      offset: Offset(0, 8),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
    ),
  ];
}

/// Material elevation tokens, matching what the existing UI uses: surfaces,
/// app bars and buttons are flat; only the shell's floating action button
/// lifts off the page.
abstract final class AppElevation {
  static const double flat = 0;
  static const double fab = 4;
}
