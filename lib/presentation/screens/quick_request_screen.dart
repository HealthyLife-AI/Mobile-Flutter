import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failure.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../l10n/l10n.dart';
import '../widgets/unsaved_changes_guard.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/spec_ui.dart';
import 'my_requests_screen.dart';

/// The label, hint and icon of each quick-request reason.
String quickRequestReasonLabel(AppLocalizations l10n, QuickRequestReason r) =>
    switch (r) {
      QuickRequestReason.specialOccasion => l10n.reasonSpecialOccasion,
      QuickRequestReason.foodUnavailable => l10n.reasonFoodUnavailable,
      QuickRequestReason.craving => l10n.reasonCraving,
      QuickRequestReason.cannotContinue => l10n.reasonCannotContinue,
      QuickRequestReason.other => l10n.reasonOther,
      QuickRequestReason.unknown => l10n.reasonUnknown,
    };

String? _reasonHint(AppLocalizations l10n, QuickRequestReason r) => switch (r) {
      QuickRequestReason.specialOccasion => l10n.reasonSpecialOccasionHint,
      QuickRequestReason.foodUnavailable => l10n.reasonFoodUnavailableHint,
      QuickRequestReason.craving => l10n.reasonCravingHint,
      QuickRequestReason.cannotContinue => l10n.reasonCannotContinueHint,
      QuickRequestReason.other => l10n.reasonOtherHint,
      QuickRequestReason.unknown => null,
    };

IconData quickRequestReasonIcon(QuickRequestReason r) => switch (r) {
      QuickRequestReason.specialOccasion => Icons.card_giftcard_rounded,
      QuickRequestReason.foodUnavailable => Icons.shopping_basket_outlined,
      QuickRequestReason.craving => Icons.restaurant_rounded,
      QuickRequestReason.cannotContinue => Icons.error_outline_rounded,
      QuickRequestReason.other ||
      QuickRequestReason.unknown =>
        Icons.chat_bubble_outline_rounded,
    };

/// "تواصل سريع" — `POST /me/quick-requests`. One reason (required), a date
/// only for a special occasion (no past date), and an optional note of up to
/// 280 characters with a live counter.
class QuickRequestScreen extends StatefulWidget {
  const QuickRequestScreen({super.key});

  @override
  State<QuickRequestScreen> createState() => _QuickRequestScreenState();
}

class _QuickRequestScreenState extends State<QuickRequestScreen> {
  final TextEditingController _note = TextEditingController();
  QuickRequestReason? _reason;
  DateTime? _occasionDate;
  bool _sending = false;

  /// Set after a send failed for lack of a connection: the button stays off
  /// until the patient retries.
  bool _offline = false;
  String? _banner;
  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _occasionDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null && mounted) {
      setState(() {
        _occasionDate = picked;
        _fieldErrors = {..._fieldErrors}..remove('occasion_date');
      });
    }
  }

  Future<void> _send() async {
    final reason = _reason;
    if (reason == null || _sending) return;
    setState(() {
      _sending = true;
      _banner = null;
      _fieldErrors = const {};
    });
    final cubit = context.read<QuickRequestsCubit>();
    final result = await cubit.repository.send(QuickRequestDraft(
      reason: reason,
      note: _note.text,
      occasionDate:
          reason == QuickRequestReason.specialOccasion ? _occasionDate : null,
    ));
    if (!mounted) return;
    final l10n = context.l10n;
    result.when(
      success: (request) {
        cubit.added(request);
        showSpecSnack(context, l10n.quickRequestSent);
        Navigator.of(context).pushReplacement(
            AppPageRoute(builder: (_) => const MyRequestsScreen()));
      },
      failure: (failure) => setState(() {
        _sending = false;
        switch (failure) {
          case NetworkFailure():
            _offline = true;
            _banner = l10n.quickRequestOffline;
          case ApiFailure(:final code, :final statusCode)
              when code == 'quick_request_limit' || statusCode == 429:
            _banner = l10n.quickRequestLimit;
          case ApiFailure(:final fieldErrors) when fieldErrors.isNotEmpty:
            _fieldErrors = fieldErrors;
          default:
            _banner = l10n.commonErrorBody;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasChanges: () => _reason != null || _note.text.trim().isNotEmpty,
      child: _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    final occasion = _reason == QuickRequestReason.specialOccasion;
    final count = _note.text.characters.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.quickRequestTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(l10n.quickRequestQuestion,
                style: AppTextStyles.sectionHeading.copyWith(fontSize: 18)),
            const SizedBox(height: 2),
            Text(l10n.quickRequestIntro,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            for (final reason in QuickRequestReason.choices) ...[
              ChoiceTile(
                label: quickRequestReasonLabel(l10n, reason),
                hint: _reasonHint(l10n, reason),
                icon: quickRequestReasonIcon(reason),
                selected: _reason == reason,
                onTap: () => setState(() {
                  _reason = reason;
                  _fieldErrors = {..._fieldErrors}..remove('reason');
                }),
              ),
              const SizedBox(height: 10),
            ],
            _FieldError(_fieldErrors['reason']),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              alignment: Alignment.topCenter,
              child: occasion
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 4),
                      child: _DateField(
                        label: l10n.quickRequestOccasionDate,
                        value: _occasionDate == null
                            ? null
                            : fullDayLabel(context, _occasionDate!),
                        placeholder: l10n.quickRequestPickDate,
                        error: _fieldErrors['occasion_date'],
                        onTap: _pickDate,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 12),
            Text(l10n.quickRequestNote, style: AppTextStyles.cardTitle),
            const SizedBox(height: 6),
            TextField(
              controller: _note,
              maxLength: QuickRequestDraft.noteMaxLength,
              minLines: 3,
              maxLines: 6,
              decoration: specInputDecoration(l10n.quickRequestNoteHint)
                  .copyWith(counterText: ''),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                    l10n.commonCharCount(
                        context.localizeDigits(count),
                        context
                            .localizeDigits(QuickRequestDraft.noteMaxLength)),
                    style: AppTextStyles.tiny),
              ),
            ),
            _FieldError(_fieldErrors['note']),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.schedule_rounded,
                      size: 16, color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.quickRequestResponseTime,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
            if (_banner != null) ...[
              const SizedBox(height: 14),
              _Banner(
                text: _banner!,
                actionLabel: _offline ? l10n.commonRetry : null,
                onAction: () => setState(() {
                  _offline = false;
                  _banner = null;
                }),
              ),
            ],
            const SizedBox(height: 18),
            SpecPrimaryButton(
              label: l10n.quickRequestSend,
              loading: _sending,
              onPressed: _reason == null || _offline ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.error,
  });

  final String label;
  final String? value;
  final String placeholder;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.panel),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.panel),
                border: Border.all(
                    color: error == null ? AppColors.border : AppColors.danger),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(value ?? placeholder,
                        style: value == null
                            ? AppTextStyles.secondary
                                .copyWith(color: AppColors.textMuted)
                            : AppTextStyles.body),
                  ),
                  const Icon(Icons.calendar_month_rounded,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ),
        _FieldError(error),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(text,
          style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(AppRadius.panel),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: AppColors.danger, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: AppTextStyles.secondary
                      .copyWith(color: AppColors.danger)),
            ),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
