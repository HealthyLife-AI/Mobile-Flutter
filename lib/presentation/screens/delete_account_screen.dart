import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../bloc/auth/auth_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/confirm_action_sheet.dart';

import '../../l10n/l10n.dart';

/// «ملفي ← حذف الحساب» (API guide 13). Deletion cannot be undone, so the patient
/// types the current password and confirms once more.
///
/// On success the cubit moves the app to sign-in and the router replaces this
/// screen, so this screen never navigates itself. A `403 follow_up_ended` is also
/// handled by the router (it shows the follow-up screen), so it is not mapped here.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_busy || _password.text.isEmpty) return;
    final l10n = context.l10n;
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.delete_forever_rounded,
      title: l10n.accountDeleteConfirmTitle,
      message: l10n.accountDeleteConfirmMessage,
      confirmLabel: l10n.accountDeleteCta,
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final result =
        await context.read<AuthCubit>().deleteAccount(password: _password.text);
    if (!mounted) return;

    final failure = result.failureOrNull;
    if (failure == null) return; // Signed out; the router takes over.

    setState(() {
      _busy = false;
      _error = _messageFor(l10n, failure);
    });
  }

  static String _messageFor(AppLocalizations l10n, Failure failure) =>
      switch (failure) {
        NetworkFailure() => l10n.commonOfflineBody,
        ApiFailure(statusCode: 422) => l10n.accountDeleteWrongPassword,
        ApiFailure(statusCode: 429) => l10n.loginErrorRateLimited,
        _ => l10n.commonErrorBody,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canSubmit = !_busy && _password.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.accountDeleteTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.accountDeleteWarningTitle,
                            style: AppTextStyles.cardTitle),
                        const SizedBox(height: 4),
                        Text(l10n.accountDeleteWarningBody,
                            style: AppTextStyles.secondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(l10n.accountDeletePasswordLabel,
                style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              enabled: !_busy,
              obscureText: _obscure,
              onChanged: (_) => setState(() {
                _error = null;
              }),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit ? _delete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.accountDeleteCta,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
