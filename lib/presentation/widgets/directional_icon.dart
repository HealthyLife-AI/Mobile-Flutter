import 'package:flutter/widgets.dart';

/// Picks an arrow/chevron glyph for the current layout direction.
///
/// Material arrows and chevrons already mirror themselves in RTL, and most
/// screens rely on that. A few places in the Arabic design, though, show the
/// glyph that reads as an LTR arrow (the header back arrow points ←, the
/// settings-row chevrons point ›). Mirroring those into English would give
/// a → back arrow and ‹ chevrons, so those places pass both glyphs: [rtl]
/// keeps the Arabic design exactly, [ltr] is the conventional English one.
IconData directionalIcon(BuildContext context,
        {required IconData rtl, required IconData ltr}) =>
    Directionality.of(context) == TextDirection.rtl ? rtl : ltr;

/// 1 in RTL, -1 in LTR. A horizontal nudge, offset or rotation written for
/// the Arabic layout mirrors in English when multiplied by this.
double rtlDesignSign(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl ? 1 : -1;
