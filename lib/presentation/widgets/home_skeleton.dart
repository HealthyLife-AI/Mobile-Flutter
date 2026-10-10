import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import 'shimmer_box.dart';

/// Shown for the first ~700ms after Home mounts, in the exact shape of the
/// real dashboard (header row → progress card with three ring stats →
/// meal-slot list), so the transition to real content never causes a
/// layout jump.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(children: [
          const ShimmerBox.circle(size: 44),
          const SizedBox(width: 10),
          const ShimmerBox.circle(size: 44),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ShimmerBox(width: 130, height: 18, borderRadius: BorderRadius.circular(6)),
            const SizedBox(height: 8),
            ShimmerBox(width: 90, height: 12, borderRadius: BorderRadius.circular(6)),
          ]),
        ]),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(children: [
            Row(children: [
              ShimmerBox(width: 90, height: 14, borderRadius: BorderRadius.circular(6)),
              const Spacer(),
              ShimmerBox(width: 140, height: 14, borderRadius: BorderRadius.circular(6)),
            ]),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(3, (i) {
              return Column(children: [
                const ShimmerBox.circle(size: 56),
                const SizedBox(height: 10),
                ShimmerBox(width: 46, height: 10, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 6),
                ShimmerBox(width: 30, height: 8, borderRadius: BorderRadius.circular(6)),
              ]);
            })),
          ]),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const ShimmerBox.circle(size: 22),
          const SizedBox(width: 10),
          ShimmerBox(width: 160, height: 14, borderRadius: BorderRadius.circular(6)),
        ]),
        const SizedBox(height: 14),
        for (int i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShimmerBox(width: 150, height: 14, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 10),
                  ShimmerBox(width: 200, height: 10, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 110, height: 10, borderRadius: BorderRadius.circular(6)),
                ]),
              ),
              const SizedBox(width: 12),
              ShimmerBox(width: 64, height: 64, borderRadius: BorderRadius.circular(14)),
            ]),
          ),
      ],
    );
  }
}
