import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// The one header every pushed screen in the app uses.
///
/// Layout (Arabic/RTL — the product language):
///
/// ```
/// [‹back]   [ title / subtitle ]   [ · action · action ]
///   (start)          (centred)          (end edge)
/// ```
///
/// The repeated generic "account avatar" that used to sit in every AppBar is
/// gone: it was decorative on ~20 screens and meant nothing on any of them.
/// A header is now title-first and only carries an affordance when the screen
/// actually has something to do — a back control, or a contextual action such
/// as search / notifications / settings passed via [actions].
///
/// Both edges are fixed-width slots so the title stays optically centred
/// regardless of how many actions are supplied.
class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  /// Contextual trailing affordances (search, notifications, settings…).
  /// Keep it to two or fewer — the row is a fixed slot, not a toolbar.
  final List<Widget> actions;

  /// False only for a root tab destination (nothing to go back to).
  final bool showBack;

  /// In RTL the "back" affordance sits on the START edge (the right) and points
  /// forward, because forward in RTL reading order is leftward.
  final IconData backIcon;
  final VoidCallback? onBack;

  /// Hairline under the header. Off by default: the background and the surface
  /// are already near-identical, so a divider only adds noise.
  final bool showDivider;

  static const double _edgeSlot = 44;

  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = true,
    this.backIcon = Icons.arrow_forward_rounded,
    this.onBack,
    this.showDivider = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    // Both edge slots take the SAME width so the title stays optically
    // centred, and the slot grows with the action count so 2+ actions can
    // never overflow the 44px default.
    final edgeWidth = math.max(_edgeSlot, actions.length * 40.0);

    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      centerTitle: true,
      titleSpacing: 0,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.hairline),
            )
          : null,
      title: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              SizedBox(
                width: edgeWidth,
                child: showBack
                    ? _EdgeButton(
                        icon: backIcon,
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: edgeWidth,
                child: actions.isEmpty
                    ? null
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A header edge affordance. Renders a plain tappable icon when [onTap] is
/// given, and an inert glyph otherwise — so a decorative slot never swallows
/// taps. No filled circle: the header is already flat white.
class _EdgeButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;

  const _EdgeButton({this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Icon(icon, color: AppColors.textSecondary, size: 20);
    if (onTap == null) return Center(child: content);
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.scale(scale: value, child: child),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(width: 40, height: 40, child: Center(child: content)),
          ),
        ),
      ),
    );
  }
}

/// The app's official logo inside a soft rounded tile — the contextual stand-in
/// for the generic account icon on brand-forward surfaces (About, Splash,
/// welcome screens). Uses `assets/images/logo_icon.png`.
class BrandMark extends StatelessWidget {
  final double size;
  final double iconScale;

  const BrandMark({super.key, this.size = 40, this.iconScale = 0.62});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Image.asset(
        'assets/images/logo_icon.png',
        width: size * iconScale,
        height: size * iconScale,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Standard header action glyph (search, notifications, settings, …).
class HeaderActionIcon extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;

  const HeaderActionIcon({super.key, required this.icon, this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final button = _EdgeButton(
      icon: icon,
      onTap: onTap ?? () {},
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
