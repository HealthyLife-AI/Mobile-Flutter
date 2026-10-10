import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// StickyBottomBar — fixed bottom bar with customizable left/right content (M12).
/// Static, no entrance/exit animation except when the screen itself is entered.
class StickyBottomBar extends StatelessWidget {
  final Widget left;
  final Widget right;

  const StickyBottomBar({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [Expanded(child: right), const SizedBox(width: 16), left]),
      ),
    );
  }
}
