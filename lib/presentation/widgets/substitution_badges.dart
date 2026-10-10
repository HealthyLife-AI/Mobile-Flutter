import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// CalorieDeltaBadge (2.4) — a small neutral-gray badge next to any
/// non-default alternative: "(+10 kcal)" / "(-5 kcal)". Tells the user the
/// difference BEFORE they choose, not after.
class CalorieDeltaBadge extends StatelessWidget {
  final int delta;
  const CalorieDeltaBadge({super.key, required this.delta});

  @override
  Widget build(BuildContext context) {
    if (delta == 0) return const SizedBox.shrink();
    final sign = delta > 0 ? '+' : '';
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.chipInactiveBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text('($sign$delta سعرة)', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
    );
  }
}

/// DefaultOptionBadge (2.4) — a small solid `primary` badge over the option
/// the nutritionist set as the default within any substitution group.
class DefaultOptionBadge extends StatelessWidget {
  const DefaultOptionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
      // NOTE: real copy is inconsistent in Figma between "Original item" and
      // "Original scheduled item" — flagged in section 1 as a team decision,
      // not picked here. Using the shorter phrasing as a placeholder.
      child: const Text('الصنف الأصلي', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

/// LockedCategoryBadge (2.4) — a lock icon + "Core item, no substitute" for
/// a group with exactly one item and no substitution allowed at all. Uses a
/// solid green "Fixed" badge instead of the normal DefaultOptionBadge.
class LockedCategoryBadge extends StatelessWidget {
  const LockedCategoryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: const Text('ثابت', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 6),
      const Icon(Icons.lock_rounded, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      const Text('صنف أساسي، بدون بديل', style: AppTextStyles.caption),
    ]);
  }
}
