import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

/// LiveUpdateBadge — "Live update" text + a continuously pulsing green dot,
/// shown at the top of the Meal Logged Successfully screen (5.6) for as
/// long as the screen is visible.
class LiveUpdateBadge extends StatefulWidget {
  final String label;
  const LiveUpdateBadge({super.key, this.label = 'تحديث فوري'});

  @override
  State<LiveUpdateBadge> createState() => _LiveUpdateBadgeState();
}

class _LiveUpdateBadgeState extends State<LiveUpdateBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: AppColors.accentGreen.withValues(alpha: 0.5 + 0.5 * _c.value), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Text(widget.label, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
