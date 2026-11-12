import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../l10n/l10n.dart';
import 'state_views.dart';

/// The message for a screen that could not load: the offline text when there
/// is no connection, the generic one otherwise.
String loadFailureMessage(BuildContext context, Failure? failure) =>
    failure is NetworkFailure
        ? context.l10n.commonOfflineBody
        : context.l10n.commonErrorBody;

/// A screen with nothing to show because loading failed: what happened, in
/// the offline or the generic wording, and a retry button.
///
/// Pass the [failure] and the view picks the wording and the icon. [message]
/// replaces the body text for a failure that needs its own.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    this.failure,
    this.message,
    required this.onRetry,
  });

  final Failure? failure;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = failure is NetworkFailure;
    return StateMessage(
      icon: offline ? Icons.cloud_off_rounded : Icons.error_outline_rounded,
      title: offline
          ? context.l10n.stateOfflineTitle
          : context.l10n.stateErrorTitle,
      message: message ?? loadFailureMessage(context, failure),
      actionLabel: context.l10n.commonRetry,
      onAction: onRetry,
      warning: true,
    );
  }
}
