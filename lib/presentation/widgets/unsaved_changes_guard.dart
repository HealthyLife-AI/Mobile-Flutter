import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Asks before leaving a form the patient has typed into: the system back, the
/// back swipe and the header's back arrow all go through it. A form with
/// nothing entered leaves at once, and a screen that closes itself after a
/// save (`Navigator.pop`) is not asked, so a saved form never nags.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasChanges,
    required this.child,
  });

  /// Read when the patient tries to leave, so it sees what is typed by then.
  final bool Function() hasChanges;
  final Widget child;

  Future<void> _onPop(BuildContext context, bool didPop) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    if (!hasChanges()) {
      navigator.pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.unsavedChangesTitle),
          content: Text(l10n.unsavedChangesBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.unsavedChangesStay),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.unsavedChangesDiscard),
            ),
          ],
        );
      },
    );
    if (leave == true && navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(context, didPop),
      child: child,
    );
  }
}
