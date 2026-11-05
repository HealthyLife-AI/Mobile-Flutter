import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../l10n/l10n.dart';

/// The building blocks of the patient-app design spec ("الألوان والقياسات"):
/// a white card (radius 16, padding 16, soft shadow), a 40x40 icon tile, an
/// inner panel, pill badges and the two button styles. Every screen added for
/// the spec phases is composed from these, so the sizes live in one place.

/// White card. [highlighted] adds the 1px primary outline at 25%.
class SpecCard extends StatelessWidget {
  const SpecCard({
    super.key,
    required this.child,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final bool highlighted;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ??
        (highlighted ? AppColors.primary.withValues(alpha: 0.25) : null);
    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: border == null ? null : Border.all(color: border),
      boxShadow: AppShadows.soft,
    );
    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }
    // Ink paints the card on the Material, so the ripple shows on top of it.
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A column with the spec's 12px gap between children.
class SpecColumn extends StatelessWidget {
  const SpecColumn({super.key, required this.children, this.gap = 12});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) SizedBox(height: gap),
          child,
        ],
      ],
    );
  }
}

/// 40x40 tile, radius 12, the icon on its color at 10%.
class SpecIconTile extends StatelessWidget {
  const SpecIconTile(
    this.icon, {
    super.key,
    this.color = AppColors.primary,
    this.background,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.panel),
        ),
        child: Icon(icon, color: color, size: size / 2),
      ),
    );
  }
}

/// Icon tile, title (16 Bold) and an optional subtitle, with [trailing] at
/// the end of the row.
class SpecCardHeader extends StatelessWidget {
  const SpecCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor = AppColors.primary,
    this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SpecIconTile(icon, color: iconColor, background: iconBackground),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title,
                    style: AppTextStyles.cardTitle.copyWith(height: 1.35)),
              ),
              if (subtitle != null)
                Text(subtitle!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// Inner panel: the spec Panel at 70%, radius 12, padding 12.
class SpecPanel extends StatelessWidget {
  const SpecPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.panel.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.panel),
      ),
      child: child,
    );
  }
}

/// The color pairs a [StatusPill] can take.
enum PillTone { primary, success, warning, danger, neutral, solid }

/// Pill badge: full radius, padding 10x4, 12 SemiBold.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label,
      {super.key, this.tone = PillTone.primary, this.icon});

  final String label;
  final PillTone tone;
  final IconData? icon;

  (Color, Color) get _colors => switch (tone) {
        PillTone.primary => (AppColors.primary, AppColors.panel),
        PillTone.success => (AppColors.success, AppColors.successBg),
        PillTone.warning => (AppColors.warning, AppColors.warningBg),
        PillTone.danger => (AppColors.danger, AppColors.dangerBg),
        PillTone.neutral => (AppColors.textMuted, AppColors.chipInactiveBg),
        PillTone.solid => (Colors.white, AppColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.pillLabel.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}

/// A line of text after a 6px primary dot. Never truncated.
class BulletLine extends StatelessWidget {
  const BulletLine(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: style ??
                  AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w400, height: 1.6)),
        ),
      ],
    );
  }
}

/// Primary button: height 52, radius 14, Cairo 16 SemiBold.
class SpecPrimaryButton extends StatelessWidget {
  const SpecPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center, style: AppTextStyles.ctaText),
              ),
            ],
          );
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
        child: child,
      ),
    );
  }
}

/// Secondary button: white, 40% primary outline, primary text.
class SpecSecondaryButton extends StatelessWidget {
  const SpecSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  /// A smaller button for inside a card (the spec's `.btn.sm`).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: compact ? 40 : 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  compact ? AppRadius.panel : AppRadius.button)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: (compact
                          ? AppTextStyles.pillLabel.copyWith(fontSize: 14)
                          : AppTextStyles.ctaText)
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable row: a radio dot (or a checkbox when [multi]), a label with
/// an optional hint, and an optional icon tile at the end.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint,
    this.icon,
    this.multi = false,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      selected: selected,
      checked: selected,
      inMutuallyExclusiveGroup: !multi,
      button: true,
      child: Material(
        color: selected ? AppColors.primaryTint : AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    shape: multi ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: multi ? BorderRadius.circular(6) : null,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.iconMuted,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTextStyles.body.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500)),
                      if (hint != null)
                        Text(hint!,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  SpecIconTile(icon!, size: 36),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A section title with a leading icon (e.g. "النشاط البدني").
class SpecSectionTitle extends StatelessWidget {
  const SpecSectionTitle(this.title, {super.key, this.icon, this.trailing});

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Icon, title, body and an optional action, centered.
class SpecEmptyState extends StatelessWidget {
  const SpecEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpecIconTile(icon, size: 64),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!,
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary)),
          ],
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

/// A floating snack bar with [message], the app's one way to confirm or
/// report the result of an action.
void showSpecSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.danger : null,
    ));
}

/// The spec's text-input look: white, radius 12, the border color, a
/// primary outline when focused.
InputDecoration specInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.secondary.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.panel),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );

/// "اقتصادي", "بدون طبخ" and "تحضير سهل" for a plan item (spec, phase 4).
/// Only on alternatives and the meal detail, never on home. An untagged item
/// (null on the wire, which is every item for now) gets none.
List<Widget> foodTagBadges(AppLocalizations l10n, PlanItem? item) => [
      if (item != null && item.isEconomical)
        StatusPill(l10n.tagEconomical, tone: PillTone.success),
      if (item?.prepLevel == FoodPrepLevel.noCook)
        StatusPill(l10n.tagNoCook)
      else if (item?.prepLevel == FoodPrepLevel.easy)
        StatusPill(l10n.tagEasyPrep),
    ];
