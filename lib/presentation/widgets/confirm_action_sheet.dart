import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';

/// A small, on-brand confirmation sheet for actions worth a second thought
/// (logging out, leaving an incomplete flow, revoking consent). Returns
/// `true` when the person confirms, `false`/`null` when they cancel or
/// dismiss — callers should treat anything but `true` as "do nothing".
class ConfirmActionSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// Defaults to the localized "Confirm" / "Cancel".
  final String? confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  const ConfirmActionSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.destructive = true,
  });

  static Future<bool?> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = true,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConfirmActionSheet(
        icon: icon,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = destructive ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill))),
          const SizedBox(height: 22),
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(icon, color: accent, size: 26)),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.h1, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message,
              style: AppTextStyles.secondary, textAlign: TextAlign.center),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                elevation: 0,
              ),
              child: Text(confirmLabel ?? context.l10n.commonConfirm,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel ?? context.l10n.commonCancel,
                  style: AppTextStyles.body),
            ),
          ),
        ]),
      ),
    );
  }
}
