import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';

/// A gentle, dismiss-free reminder shown while `user.password_is_temporary` is
/// true (API guide 3.4). It never blocks the app. Tapping it opens the password
/// settings. The card disappears on its own once the password change succeeds,
/// because the cubit then holds a user whose flag is false.
class PasswordReminderCard extends StatelessWidget {
  const PasswordReminderCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.primaryTint,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.key_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.passwordTemporaryTitle,
                      style: AppTextStyles.cardTitle),
                  const SizedBox(height: 2),
                  Text(l10n.passwordTemporaryBody,
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 18,
                textDirection: TextDirection.ltr),
          ]),
        ),
      ),
    );
  }
}
