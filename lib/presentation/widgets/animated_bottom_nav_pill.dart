import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NavTab {
  final IconData icon;
  final String label;
  const NavTab({required this.icon, required this.label});
}

/// The action in the middle of the bar: the app's main action ("log a meal").
class NavCenterAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  const NavCenterAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

/// The app's bottom bar: the tabs, with the main action as a round button in
/// the middle (two tabs on each side for four tabs).
///
/// It is a solid bar under the content, not a pill floating over it, so the
/// shell does not extend its body behind it and nothing on a screen is ever
/// covered: neither by the bar nor by a floating button.
///
/// Every tab shows its label; the selected one sits in a tinted pill. The class
/// keeps its name so the shell and tests stay the same.
class AnimatedBottomNavPill extends StatelessWidget {
  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// The round button in the middle. Null for a bar of tabs only.
  final NavCenterAction? centerAction;

  static const double barHeight = 72;

  const AnimatedBottomNavPill({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.centerAction,
  });

  @override
  Widget build(BuildContext context) {
    final half = (tabs.length / 2).ceil();
    final items = <Widget>[
      for (var i = 0; i < tabs.length; i++) ...[
        if (centerAction != null && i == half)
          Expanded(child: _CenterButton(action: centerAction!)),
        Expanded(
          child: _TabItem(
            tab: tabs[i],
            active: i == selectedIndex,
            onTap: () => onChanged(i),
          ),
        ),
      ],
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(children: items),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem(
      {required this.tab, required this.active, required this.onTap});

  final NavTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryInk : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                color: active ? AppColors.primaryTint : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(tab.icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tab.label,
                maxLines: 1,
                softWrap: false,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.action});

  final NavCenterAction action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: action.tooltip,
        child: Semantics(
          button: true,
          label: action.tooltip,
          excludeSemantics: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: action.onPressed,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(action.icon, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
