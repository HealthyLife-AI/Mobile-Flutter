import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/app_dependencies.dart';
import '../../l10n/l10n.dart';
import 'spec_ui.dart';

/// Opens a chat with the nutritionist on WhatsApp (API guide 9.1): the
/// profile's number, or the one kept on this device when there is no
/// connection. Without either, the patient is told.
Future<void> openNutritionistWhatsApp(BuildContext context) async {
  final deps = context.read<AppDependencies>();
  final whatsapp =
      (await deps.nutritionist.getProfile()).valueOrNull?.whatsappUri ??
          await deps.passwordHelp.whatsappUri();
  if (!context.mounted) return;
  if (whatsapp == null) {
    showSpecSnack(context, context.l10n.aboutSupportNoNumber, error: true);
    return;
  }
  await openExternalLink(context, whatsapp);
}

/// Opens [uri] in its own app (WhatsApp, the browser, a video call). When
/// nothing can open it, the patient is told.
Future<void> openExternalLink(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showSpecSnack(context, context.l10n.linkCouldNotOpen, error: true);
  }
}
