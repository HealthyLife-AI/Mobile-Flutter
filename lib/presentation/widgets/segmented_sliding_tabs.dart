import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

/// SegmentedSlidingTabs — M4/M5: filled pill slides between 2+ tabs
/// instead of an abrupt swap. 250-300ms, easeOutCubic.
class SegmentedSlidingTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedSlidingTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double segWidth = constraints.maxWidth / tabs.length;
      return Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.chipInactiveBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: segWidth * selectedIndex,
              width: segWidth,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              children: List.generate(tabs.length, (i) {
                final bool active = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.caption.copyWith(
                          color:
                              active ? Colors.white : AppColors.textSecondary,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                        child: Text(tabs[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
