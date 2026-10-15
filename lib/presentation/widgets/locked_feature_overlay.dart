import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

import '../../l10n/l10n.dart';

/// LockedFeatureOverlay — unified lockedOverlay layer over any plan-gated
/// feature, with a message and a link to contact the nutritionist.
class LockedFeatureOverlay extends StatelessWidget {
  final Widget child;
  final bool locked;

  /// Defaults to the localized "upgrade required" message.
  final String? message;
  final VoidCallback? onContact;

  const LockedFeatureOverlay({
    super.key,
    required this.child,
    required this.locked,
    this.message,
    this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.6, child: child)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.lockedOverlay,
                borderRadius: BorderRadius.circular(AppRadius.card)),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.textSecondary, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                Text(message ?? context.l10n.profileUpgradeRequired,
                    textAlign: TextAlign.center, style: AppTextStyles.caption),
                if (onContact != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: onContact,
                      child: Text(context.l10n.lockedContactSpecialist,
                          style: AppTextStyles.pillLabel)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
