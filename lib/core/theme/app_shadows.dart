import 'package:flutter/material.dart';

/// Shadow tokens. The design is flat-first: depth comes from soft, low-
/// contrast shadows rather than Material elevation.
abstract final class AppShadows {
  /// Soft, low-contrast card shadow per spec: blur 20-30, opacity 0.06-0.10.
  /// (`Color.from` is the const spelling of
  /// `Colors.black.withValues(alpha: 0.06)` — the exact same color.)
  static const List<BoxShadow> soft = [
    BoxShadow(
      // Design spec: 0 4 16 rgba(17,28,45,.07).
      color: Color(0x12111C2D),
      blurRadius: 16,
      offset: Offset(0, 4),
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
