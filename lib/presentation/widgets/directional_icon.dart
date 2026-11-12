import 'package:flutter/widgets.dart';

/// 1 in RTL, -1 in LTR. A horizontal nudge, offset or rotation written for
/// the Arabic layout mirrors in English when multiplied by this.
///
/// Arrows and chevrons need no helper: Material's `arrow_back`,
/// `arrow_forward` and the chevrons mirror themselves in RTL, so the same
/// icon is the standard one in both languages.
double rtlDesignSign(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl ? 1 : -1;
