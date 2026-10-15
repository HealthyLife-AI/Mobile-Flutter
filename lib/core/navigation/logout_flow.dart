import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/l10n.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';
import '../../presentation/widgets/confirm_action_sheet.dart';

/// Confirms with the patient, then ends the session through [AuthCubit.signOut].
///
/// No screen navigates after this. The auth listener in `main.dart` moves the
/// app to the sign-in screen when the status becomes `signedOut`. Every logout
/// affordance in the app calls this one function, so the behavior cannot drift.
Future<void> performLogoutFlow(BuildContext context) async {
  final confirmed = await ConfirmActionSheet.show(
    context,
    icon: Icons.logout_rounded,
    title: context.l10n.logoutConfirmTitle,
    message: context.l10n.logoutConfirmMessage,
    confirmLabel: context.l10n.commonLogout,
  );
  if (confirmed != true || !context.mounted) return;
  await context.read<AuthCubit>().signOut();
}
