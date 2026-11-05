import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../bloc/auth/auth_cubit.dart';
import '../widgets/gradient_cta_button.dart';

import '../../l10n/l10n.dart';

/// Sign-in with the username and password the nutritionist sent (API guide
/// 3.1). The password is never checked against the strength policy here: an
/// existing password must always be accepted.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signIn(
          username: _username.text,
          password: _password.text,
        );
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.passwordForgot),
        content: Text(context.l10n.loginForgotBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.commonClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final l10n = context.l10n;
            final failure = state.failure;
            final message =
                failure == null ? null : _messageFor(context, failure);

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
              children: [
                Center(
                    child: Image.asset('assets/images/logo.png', height: 56)),
                const SizedBox(height: 18),
                Text(l10n.loginTitle,
                    style: AppTextStyles.h1, textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(l10n.loginSubtitle,
                    style: AppTextStyles.secondary,
                    textAlign: TextAlign.center),
                const SizedBox(height: 22),
                if (state.sessionEnded) ...[
                  _Notice(text: l10n.sessionEndedMessage),
                  const SizedBox(height: 14),
                ],
                if (message != null) ...[
                  _Notice(text: message, danger: true),
                  const SizedBox(height: 14),
                ],
                Text(l10n.loginUsername, style: AppTextStyles.body),
                const SizedBox(height: 8),
                _InputBox(
                  error: failure is ValidationFailure &&
                      failure.fieldErrors.containsKey('username'),
                  child: TextField(
                    controller: _username,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    // The username the nutritionist sends is Latin. This input
                    // type asks the keyboard for its ASCII layout (guide 3.1).
                    keyboardType: TextInputType.visiblePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: l10n.loginUsernameHint,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.loginPassword, style: AppTextStyles.body),
                const SizedBox(height: 8),
                _InputBox(
                  error: failure is ValidationFailure &&
                      failure.fieldErrors.containsKey('password'),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _password,
                        obscureText: _obscure,
                        autocorrect: false,
                        enableSuggestions: false,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 14),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _obscure ? l10n.commonShow : l10n.commonHide,
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                GradientCtaButton(
                  label: l10n.loginCta,
                  onPressed: state.busy ? null : _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: _showForgotPassword,
                    child: Text(l10n.passwordForgot,
                        style: AppTextStyles.pillLabel),
                  ),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(l10n.activationEncryptedNote,
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Maps a sign-in failure to a message. The API's own English text is never shown.
String _messageFor(BuildContext context, Failure failure) {
  final l10n = context.l10n;
  return switch (failure) {
    ValidationFailure() => l10n.loginErrorRequired,
    NetworkFailure() => l10n.commonOfflineBody,
    ApiFailure(statusCode: 423, :final body) => _lockedMessage(context, body),
    ApiFailure(statusCode: 429) => l10n.loginErrorRateLimited,
    ApiFailure(statusCode: 401) => l10n.loginErrorInvalid,
    _ => l10n.loginErrorGeneric,
  };
}

String _lockedMessage(BuildContext context, Map<String, dynamic> body) {
  final raw = body['locked_until'];
  final until = raw is String ? DateTime.tryParse(raw) : null;
  if (until == null) return context.l10n.loginErrorGeneric;
  final time = MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(until.toLocal()));
  return context.l10n.loginErrorLocked(time);
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child, this.error = false});

  final Widget child;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border:
              Border.all(color: error ? AppColors.danger : AppColors.border),
        ),
        child: child,
      );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, this.danger = false});

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: danger ? AppColors.surface : AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        border:
            Border.all(color: danger ? AppColors.danger : Colors.transparent),
      ),
      child: Row(children: [
        Icon(
          danger ? Icons.error_outline_rounded : Icons.info_outline_rounded,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.caption)),
      ]),
    );
  }
}
