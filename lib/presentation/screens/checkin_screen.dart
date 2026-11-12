import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/engagement_entities.dart';
import '../../domain/repositories/engagement_repository.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/load_error_view.dart';
import '../widgets/spec_ui.dart';
import '../widgets/state_views.dart';

/// "استبيان قصير" — the periodic check-in (`/me/checkins/current`).
///
/// One question per screen, drawn from the API (no question text lives in
/// the app). "التالي" stays off until a choice is made, except on a text
/// question. Nothing is sent before the last screen; the answers so far are
/// kept on the device, so leaving and coming back resumes.
class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

enum _Phase { loading, error, none, asking, submitted }

class _CheckinScreenState extends State<CheckinScreen> {
  late final CheckinRepository _repository =
      context.read<AppDependencies>().checkins;
  final TextEditingController _text = TextEditingController();

  _Phase _phase = _Phase.loading;
  Failure? _failure;
  Checkin? _checkin;
  int _step = 0;
  CheckinAnswers _answers = {};
  bool _sending = false;

  /// Set when a choice past the question's maximum was refused.
  bool _atLimit = false;

  /// From a refused send (422), shown under the question it names.
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _phase = _Phase.loading);
    final result = await _repository.getCurrent();
    if (!mounted) return;
    final checkin = result.valueOrNull;
    if (result.failureOrNull case final failure?) {
      setState(() {
        _phase = _Phase.error;
        _failure = failure;
      });
      return;
    }
    if (checkin == null) {
      setState(() => _phase = _Phase.none);
      return;
    }
    final draft = await _repository.readDraft(checkin.id);
    if (!mounted) return;
    setState(() {
      _checkin = checkin;
      _answers = {...?draft?.answers};
      _step = (draft?.step ?? 0).clamp(0, checkin.questions.length - 1);
      _phase = _Phase.asking;
      _syncText();
    });
  }

  CheckinQuestion get _question => _checkin!.questions[_step];

  void _syncText() {
    final q = _question;
    _text.text = q.isText ? (_answers[q.key] as String? ?? '') : '';
  }

  void _saveDraft() {
    final checkin = _checkin;
    if (checkin == null) return;
    _repository.saveDraft(
        CheckinDraft(checkinId: checkin.id, step: _step, answers: _answers));
  }

  bool get _answered {
    final q = _question;
    return switch (q.type) {
      CheckinQuestionType.text => true,
      CheckinQuestionType.multi =>
        (_answers[q.key] as List<String>? ?? const []).isNotEmpty,
      _ => _answers[q.key] is String,
    };
  }

  void _choose(CheckinOption option) {
    final q = _question;
    setState(() {
      _errors.remove(q.key);
      if (q.type == CheckinQuestionType.multi) {
        final current = (_answers[q.key] as List<String>?) ?? const <String>[];
        final next = toggleMultiChoice(current, option.value, max: q.max);
        if (next == null) {
          _atLimit = true;
          return;
        }
        _atLimit = false;
        _answers = {..._answers, q.key: next};
      } else {
        _answers = {..._answers, q.key: option.value};
      }
    });
    _saveDraft();
  }

  void _go(int step) {
    setState(() {
      _step = step;
      _atLimit = false;
      _syncText();
    });
    _saveDraft();
  }

  CheckinAnswers _payload() => {
        for (final entry in _answers.entries)
          if (entry.value is! String ||
              (entry.value as String).trim().isNotEmpty)
            entry.key: entry.value is String
                ? (entry.value as String).trim()
                : entry.value,
      };

  Future<void> _submit() async {
    final checkin = _checkin!;
    setState(() => _sending = true);
    final result = await _repository.submit(checkin.id, _payload());
    if (!mounted) return;
    final l10n = context.l10n;
    final failure = result.failureOrNull;
    if (failure == null) {
      context.read<TodayCubit>().load();
      setState(() {
        _sending = false;
        _phase = _Phase.submitted;
      });
      return;
    }
    setState(() => _sending = false);
    switch (failure) {
      case ApiFailure(code: 'checkin_already_submitted'):
        await _repository.clearDraft();
        if (mounted) setState(() => _phase = _Phase.submitted);
      case ApiFailure(code: 'checkin_expired'):
        await _repository.clearDraft();
        if (!mounted) return;
        context.read<TodayCubit>().load();
        showSpecSnack(context, l10n.checkinExpired);
        Navigator.of(context).popUntil((route) => route.isFirst);
      case ApiFailure(:final fieldErrors) when fieldErrors.isNotEmpty:
        // `answers.<key>`: back to that question, with its message.
        final errors = {
          for (final e in fieldErrors.entries)
            e.key.replaceFirst('answers.', '').split('.').first: e.value,
        };
        final index =
            checkin.questions.indexWhere((q) => errors.containsKey(q.key));
        setState(() {
          _errors
            ..clear()
            ..addAll(errors);
          if (index >= 0) {
            _step = index;
            _syncText();
          }
        });
      case NetworkFailure():
        showSpecSnack(context, l10n.commonOfflineBody, error: true);
      default:
        showSpecSnack(context, l10n.commonErrorBody, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.checkinTitle),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.loading => const ListSkeleton(),
          _Phase.error => LoadErrorView(
              failure: _failure, onRetry: _load),
          _Phase.none => Center(
              child: SpecEmptyState(
                  icon: Icons.assignment_turned_in_outlined,
                  title: l10n.checkinNone,
                  body: l10n.checkinNoneBody)),
          _Phase.submitted => Center(child: _Done(onHome: _home)),
          _Phase.asking => _asking(context),
        },
      ),
    );
  }

  void _home() => Navigator.of(context).popUntil((route) => route.isFirst);

  Widget _asking(BuildContext context) {
    final l10n = context.l10n;
    final q = _question;
    final total = _checkin!.questions.length;
    final last = _step == total - 1;
    final chosen = _answers[q.key];
    final error = _errors[q.key];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
            l10n.checkinProgress(context.localizeDigits(_step + 1),
                context.localizeDigits(total)),
            style: AppTextStyles.secondary
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: (_step + 1) / total,
            minHeight: 6,
            color: AppColors.primary,
            backgroundColor: AppColors.border,
          ),
        ),
        const SizedBox(height: 18),
        Text(q.label,
            style: AppTextStyles.sectionHeading.copyWith(height: 1.4)),
        if (q.type == CheckinQuestionType.multi)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _atLimit && q.max != null
                  ? l10n.checkinLimitReached(context.localizeDigits(q.max!))
                  : q.max == null
                      ? l10n.checkinChooseAny
                      : l10n.checkinChooseUpTo(context.localizeDigits(q.max!)),
              style: AppTextStyles.secondary.copyWith(
                  color:
                      _atLimit ? AppColors.warning : AppColors.textSecondary),
            ),
          ),
        if (q.isText)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l10n.commonOptional,
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary)),
          ),
        const SizedBox(height: 14),
        if (q.isText) ...[
          TextField(
            controller: _text,
            maxLength: q.max ?? 280,
            minLines: 4,
            maxLines: 8,
            decoration: specInputDecoration(l10n.checkinTextHint)
                .copyWith(counterText: ''),
            onChanged: (value) {
              _answers = {..._answers, q.key: value};
              _saveDraft();
              setState(() {});
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
                l10n.commonCharCount(
                    context.localizeDigits(_text.text.characters.length),
                    context.localizeDigits(q.max ?? 280)),
                style: AppTextStyles.tiny),
          ),
        ] else
          for (final option in q.options) ...[
            ChoiceTile(
              label: option.label,
              multi: q.type == CheckinQuestionType.multi,
              selected: q.type == CheckinQuestionType.multi
                  ? (chosen as List<String>? ?? const []).contains(option.value)
                  : chosen == option.value,
              onTap: () => _choose(option),
            ),
            const SizedBox(height: 10),
          ],
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error,
                style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (_step > 0) ...[
              SizedBox(
                width: 110,
                child: SpecSecondaryButton(
                    label: l10n.commonBack, onPressed: () => _go(_step - 1)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: SpecPrimaryButton(
                label: last ? l10n.checkinSubmit : l10n.commonNext,
                loading: _sending,
                onPressed: !_answered
                    ? null
                    : last
                        ? _submit
                        : () => _go(_step + 1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SpecCard(
        color: AppColors.successBg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 12),
            Text(l10n.checkinThanks,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.cardTitle.copyWith(color: AppColors.success)),
            const SizedBox(height: 16),
            SpecSecondaryButton(
                label: l10n.commonBackToHome, onPressed: onHome),
          ],
        ),
      ),
    );
  }
}
