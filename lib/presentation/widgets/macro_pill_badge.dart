import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// MacroPillBadge — small colored macro badge (carbs/protein/fat/fiber)
/// with staggered pop-in support (M14-style) via [delay].
class MacroPillBadge extends StatefulWidget {
  final String macro; // protein | carbs | fat | fiber
  final String label;
  final String value;
  final Duration delay;

  const MacroPillBadge({
    super.key,
    required this.macro,
    required this.label,
    required this.value,
    this.delay = Duration.zero,
  });

  @override
  State<MacroPillBadge> createState() => _MacroPillBadgeState();
}

class _MacroPillBadgeState extends State<MacroPillBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final Animation<double> _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.badgeColor(widget.macro);
    final bg = AppColors.badgeBgColor(widget.macro);
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Column(
          children: [
            Text(widget.value, style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(widget.label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
