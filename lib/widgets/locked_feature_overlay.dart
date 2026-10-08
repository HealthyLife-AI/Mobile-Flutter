import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';

/// LockedFeatureOverlay — unified lockedOverlay layer over any plan-gated
/// feature, with a message and a link to contact the nutritionist.
class LockedFeatureOverlay extends StatelessWidget {
  final Widget child;
  final bool locked;
  final String message;
  final VoidCallback? onContact;

  const LockedFeatureOverlay({
    super.key,
    required this.child,
    required this.locked,
    this.message = 'هذه الميزة تتطلب باقة أعلى — تواصلي مع أخصائيتك للترقية',
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
            decoration: BoxDecoration(color: AppColors.lockedOverlay, borderRadius: BorderRadius.circular(AppRadius.card)),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 10),
                Text(message, textAlign: TextAlign.center, style: AppTextStyles.caption),
                if (onContact != null) ...[
                  const SizedBox(height: 8),
                  TextButton(onPressed: onContact, child: const Text('تواصل مع أخصائيتك', style: AppTextStyles.pillLabel)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
