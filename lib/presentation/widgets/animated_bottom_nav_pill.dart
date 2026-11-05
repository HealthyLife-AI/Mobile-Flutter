import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NavTab {
  final IconData icon;
  final String label;
  const NavTab({required this.icon, required this.label});
}

/// AnimatedBottomNavPill — floating glassmorphic nav bar with a pill
/// indicator that slides between tabs (M4), 250-300ms easeOutCubic.
class AnimatedBottomNavPill extends StatelessWidget {
  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AnimatedBottomNavPill({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: SafeArea(
        top: false,
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: List.generate(tabs.length, (index) {
              final active = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.fromLTRB(
                      active ? 7 : 9,
                      6,
                      active ? 7 : 9,
                      6,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: active
                        ? BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[index].icon,
                          color:
                              active ? Colors.white : AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: active
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    tabs[index].label,
                                    key:
                                        ValueKey('active-${tabs[index].label}'),
                                    maxLines: 1,
                                    softWrap: false,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('inactive')),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
