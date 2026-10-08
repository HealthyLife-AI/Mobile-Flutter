import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

/// A single macro stat box (e.g. "بروتين 34غ") used in the 3-up macro row.
class MetricStatBox extends StatelessWidget {
  final String label;
  final String value;
  const MetricStatBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.accentPurpleBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

/// TweenAnimationBuilder-backed counter (M8): animates old -> new value.
class AnimatedNumberCounter extends StatelessWidget {
  final num value;
  final TextStyle style;
  final String suffix;
  const AnimatedNumberCounter({super.key, required this.value, required this.style, this.suffix = ''});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}$suffix', style: style),
    );
  }
}
