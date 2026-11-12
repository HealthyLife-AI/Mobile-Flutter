import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';
import 'shimmer_box.dart';

/// The one look for a screen that has nothing to list: an icon in a tinted
/// tile, a title, an optional explanation and an optional action. Empty,
/// error and offline screens all use it, so they read as one family.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.warning = false,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// The action button's label; both this and [onAction] make it appear.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Amber instead of teal: something is wrong (no connection, a failure).
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final tint = warning ? AppColors.warningBg : AppColors.primaryTint;
    final tone = warning ? AppColors.warning : AppColors.primaryInk;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: tint, borderRadius: BorderRadius.circular(20)),
                child:
                    ExcludeSemantics(child: Icon(icon, size: 30, color: tone)),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(message!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondary),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 16),
                // 48dp high: the touch-target minimum.
                OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 48),
                    foregroundColor: AppColors.primaryInk,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(actionLabel!, style: AppTextStyles.pillLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A screen or section with no entries yet. Say what will appear and how it
/// gets there, not just that it is empty.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => StateMessage(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      );
}

/// The loading state of a page: the shape of a list of cards in shimmer, not
/// a spinner. It keeps the layout from jumping when the data arrives, and
/// reads as "loading" to a screen reader.
///
/// It draws as many cards as fit the room it is given, so the same widget
/// serves a whole page and a short slot (a chart area).
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.items = 4, this.itemHeight = 88});

  /// The most cards drawn.
  final int items;
  final double itemHeight;

  static const double _gap = 12;
  static const double _padding = 16;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: context.l10n.commonLoading,
      child: ExcludeSemantics(
        child: LayoutBuilder(builder: (context, constraints) {
          var count = items;
          var height = itemHeight;
          if (constraints.maxHeight.isFinite) {
            final room = constraints.maxHeight - _padding;
            count =
                ((room + _gap) / (itemHeight + _gap)).floor().clamp(1, items);
            // Less room than one card: the card shrinks to it.
            if (room < itemHeight) height = room.clamp(0, itemHeight);
          }
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(_padding, _padding, _padding, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Full width: a ShimmerBox with no width would be 0 wide here.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) const SizedBox(height: _gap),
                    ShimmerBox(
                      height: height,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
