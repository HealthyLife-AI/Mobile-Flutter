import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

/// SettingsRow — the recurring "icon + title/subtitle + chevron" row used
/// across Account, About App, and other settings screens. Centralized so
/// every settings row shares exactly the same padding/typography.
///
/// RTL is forced to `TextDirection.rtl` so titles/subtitles always align to
/// the right regardless of any parent Directionality ordering (a legacy issue
/// in several screens). The chevron sits on the START edge of the row in RTL
/// (the rightmost side) to match the app's Arabic reading direction.
class SettingsRow extends StatefulWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailingBadge;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.iconBg,
    this.trailingBadge,
    this.onTap,
  });

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: isInteractive ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: isInteractive ? () => setState(() => _pressed = false) : null,
        onTapUp: isInteractive ? (_) => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
              border: Border.all(color: _pressed ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.iconBg ?? AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor ?? AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.trailingBadge != null) ...[widget.trailingBadge!, const SizedBox(width: 8)],
                            Flexible(
                              child: Text(widget.title, textAlign: TextAlign.right, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(widget.subtitle!, style: AppTextStyles.caption, textAlign: TextAlign.right),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _pressed ? -0.02 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.chevron_left_rounded, color: AppColors.iconMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
