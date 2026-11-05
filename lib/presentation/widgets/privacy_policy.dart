import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/app_config.dart';
import '../../core/di/app_dependencies.dart';
import '../../data/repositories/privacy_policy_link.dart';
import '../../l10n/l10n.dart';
import '../bloc/auth/auth_cubit.dart';
import 'external_link.dart';

/// Opens the privacy policy published on the website (API guide 4). Every
/// "privacy policy" link in the app goes through here; the app carries no
/// policy text of its own.
///
/// The address is, in order: the `policy_url` of this session's consent
/// status; the last one the server sent (kept after sign-out); a fresh
/// `GET /me/consent` when there is a session; the website set at build time.
/// With none, the patient is told the policy is on the website.
Future<void> openPrivacyPolicy(BuildContext context) async {
  final deps = context.read<AppDependencies>();
  final auth = context.read<AuthCubit>().state;
  final language = Localizations.localeOf(context).languageCode;

  var uri = PrivacyPolicyLink.usable(auth.consent?.policyUrl) ??
      await deps.privacyPolicy.last();
  if (uri == null && _hasSession(auth.status)) {
    final fresh = await deps.auth.getConsent();
    uri = PrivacyPolicyLink.usable(fresh.valueOrNull?.policyUrl);
  }
  uri ??= AppConfig.websitePrivacyUrl(language);
  if (!context.mounted) return;

  if (uri != null) {
    await openExternalLink(context, uri);
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(context.l10n.privacyOnWebsite),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.commonClose),
        ),
      ],
    ),
  );
}

bool _hasSession(AuthStatus status) => switch (status) {
      AuthStatus.consentRequired ||
      AuthStatus.onboarding ||
      AuthStatus.ready =>
        true,
      AuthStatus.unknown ||
      AuthStatus.signedOut ||
      AuthStatus.followUpEnded =>
        false,
    };
