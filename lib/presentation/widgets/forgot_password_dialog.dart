import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/app_dependencies.dart';
import '../../l10n/l10n.dart';
import 'spec_ui.dart';

/// "Forgot password" (API guide 3.6). There is no self-service reset: the
/// nutritionist resets it and sends new credentials on WhatsApp. The WhatsApp
/// button shows only when this device kept the nutritionist's number from an
/// earlier session.
Future<void> showForgotPasswordDialog(BuildContext context) async {
  final whatsapp =
      await context.read<AppDependencies>().passwordHelp.whatsappUri();
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.passwordForgot),
      content: Text(context.l10n.loginForgotBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.commonClose),
        ),
        if (whatsapp != null)
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              var opened = false;
              try {
                opened = await launchUrl(whatsapp,
                    mode: LaunchMode.externalApplication);
              } catch (_) {
                opened = false;
              }
              if (!opened && context.mounted) {
                showSpecSnack(context, context.l10n.linkCouldNotOpen,
                    error: true);
              }
            },
            child: Text(context.l10n.commonOpenWhatsApp),
          ),
      ],
    ),
  );
}
