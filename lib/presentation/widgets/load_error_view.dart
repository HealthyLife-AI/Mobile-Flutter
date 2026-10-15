import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';

/// The message for a screen that could not load: the offline text when there
/// is no connection, the generic one otherwise.
String loadFailureMessage(BuildContext context, Failure? failure) =>
    failure is NetworkFailure
        ? context.l10n.commonOfflineBody
        : context.l10n.commonErrorBody;

/// A screen with nothing to show because loading failed: the message and a
/// retry button.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.secondary),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
