import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/change_request_rules.dart';
import '../../domain/condition_codes.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../health_profile_labels.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/onboarding_reveal.dart';
import '../widgets/onboarding_step_header.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/spec_ui.dart';
import 'onboarding_notifications_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../../l10n/l10n.dart';

/// Onboarding step 2/3 — "البيانات الصحية": chronic conditions (at least one
/// choice, "none" included), optional food allergies and a medications list.
///
/// Nothing is chosen for the patient. On continue, each allergy and each
/// medication goes to the nutritionist as a change request (API guide 11.2);
/// they reach the profile once approved. A patient cannot propose a condition
/// through the API, so the conditions (the server's own codes, see
/// domain/condition_codes.dart) and the free notes go together as one
/// labelled quick request. That note is never cut: when it would not fit, the
/// screen says so and nothing is sent.
class OnboardingHealthScreen extends StatefulWidget {
  const OnboardingHealthScreen({super.key});

  @override
  State<OnboardingHealthScreen> createState() => _OnboardingHealthScreenState();
}

class _OnboardingHealthScreenState extends State<OnboardingHealthScreen> {
  final Set<String> _selectedConditions = {};

  /// API allergy groups (11.2), or `none`.
  final Set<String> _selectedAllergies = {};

  /// One `class` for every allergy chosen here; each can be changed later
  /// from the health record.
  String _allergyClass = allergyClasses.first;
  final List<String> _medications = [];
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _otherConditionController =
      TextEditingController();

  /// What already reached the server, so trying again after a failure does
  /// not send it twice.
  final Set<String> _sent = {};
  bool _sending = false;

  /// The groups offered here: all but `other`, which needs its own text and
  /// is added from the health record.
  static final List<String> _groups = [
    for (final group in allergyGroups)
      if (group != 'other') group,
  ];

  /// The coded conditions offered as cards; `other` has its own card with a
  /// text field.
  static final List<String> _conditions = [
    for (final code in conditionCodes)
      if (code != 'other') code,
  ];

  /// An upper bound for the notes field. The real limit is the whole note
  /// ([_note]), which also carries the conditions.
  static const int _notesMaxLength = 200;

  @override
  void dispose() {
    _medicationController.dispose();
    _notesController.dispose();
    _otherConditionController.dispose();
    super.dispose();
  }

  void _toggleCondition(String id) {
    setState(() {
      if (id == 'none') {
        _selectedConditions
          ..clear()
          ..add('none');
      } else {
        _selectedConditions.remove('none');
        _selectedConditions.contains(id)
            ? _selectedConditions.remove(id)
            : _selectedConditions.add(id);
      }
    });
  }

  void _toggleAllergy(String id) {
    setState(() {
      if (id == 'none') {
        _selectedAllergies
          ..clear()
          ..add('none');
      } else {
        _selectedAllergies.remove('none');
        _selectedAllergies.contains(id)
            ? _selectedAllergies.remove(id)
            : _selectedAllergies.add(id);
      }
    });
  }

  void _addMedication() {
    final text = _medicationController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      // A medication name is at most 100 characters (11.2).
      _medications.add(text.length > 100 ? text.substring(0, 100) : text);
      _medicationController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removeMedication(int index) =>
      setState(() => _medications.removeAt(index));

  Future<void> _continue() async {
    if (_sending) return;
    final note = _note(context.l10n);
    if (note != null && !note.fits) {
      // Never cut what the patient wrote: ask for a shorter text instead.
      showSpecSnack(
          context, context.l10n.onboardingHealthNoteTooLong(note.excess),
          error: true);
      return;
    }
    setState(() => _sending = true);
    final failure = await _sendHealthDetails();
    if (!mounted) return;
    setState(() => _sending = false);
    if (failure != null) {
      showSpecSnack(context, requestFailureMessage(context.l10n, failure),
          error: true);
      return;
    }
    Navigator.of(context).push(
        AppPageRoute(builder: (_) => const OnboardingNotificationsScreen()));
  }

  /// Sends what the patient entered and returns the first failure, or null.
  /// An item the profile already has, or one already waiting for the
  /// nutritionist, counts as sent.
  Future<Failure?> _sendHealthDetails() async {
    final deps = context.read<AppDependencies>();
    final note = _note(context.l10n)?.text;
    final jobs = <String, Future<Failure?> Function()>{
      for (final group in _groups)
        if (_selectedAllergies.contains(group))
          'allergy:$group': () async =>
              (await deps.patientHealthProfile.propose(ChangeRequestDraft(
                kind: 'allergy',
                action: 'add',
                data: {'group': group, 'class': _allergyClass},
              )))
                  .failureOrNull,
      for (final name in _medications)
        'medication:$name': () async =>
            (await deps.patientHealthProfile.propose(ChangeRequestDraft(
              kind: 'medication',
              action: 'add',
              data: {'name': name},
            )))
                .failureOrNull,
      if (note != null)
        'note:$note': () async {
          final failure = (await deps.quickRequests.send(QuickRequestDraft(
                  reason: QuickRequestReason.other, note: note)))
              .failureOrNull;
          if (failure == null) deps.requestChanges.notify();
          return failure;
        },
    };
    for (final MapEntry(:key, value: send) in jobs.entries) {
      if (_sent.contains(key)) continue;
      final failure = await send();
      final settled = failure == null ||
          (failure is ApiFailure &&
              (failure.code == 'already_recorded' ||
                  failure.code == 'proposal_exists'));
      if (!settled) return failure;
      _sent.add(key);
    }
    return null;
  }

  /// The conditions and the notes, as one labelled quick request to the
  /// nutritionist. Null when there is neither.
  OnboardingHealthNote? _note(AppLocalizations l10n) =>
      OnboardingHealthNote.compose(
        conditions: [
          for (final code in _conditions)
            if (_selectedConditions.contains(code))
              conditionLabel(l10n, code) ?? code,
        ],
        other: _selectedConditions.contains('other')
            ? conditionLabel(l10n, 'other')
            : null,
        otherText: _otherConditionController.text,
        notes: _notesController.text,
        separator: l10n.commonListSeparator,
        conditionsLine: l10n.onboardingHealthRequestConditions,
        notesLine: l10n.onboardingHealthRequestNotes,
        maxLength: QuickRequestDraft.noteMaxLength,
      );

  static IconData _groupIcon(String group) => switch (group) {
        'milk_lactose' => Icons.local_drink_outlined,
        'egg' => Icons.egg_outlined,
        'wheat_gluten' => Icons.grass_outlined,
        'fish' || 'shellfish' => Icons.set_meal_outlined,
        'sesame' || 'soy' => Icons.spa_outlined,
        _ => Icons.eco_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final otherChosen = _selectedConditions.contains('other');
    // "Other" needs its text: the choice alone tells the nutritionist nothing.
    final bool canContinue = _selectedConditions.isNotEmpty &&
        (!otherChosen || _otherConditionController.text.trim().isNotEmpty) &&
        !_sending;
    final note = _note(context.l10n);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingReveal(
              dy: -0.08,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: OnboardingStepHeader(
                    title: context.l10n.onboardingHealthTitle, step: 2),
              ),
            ),
            Expanded(
              child: OnboardingReveal(
                delay: const Duration(milliseconds: 120),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(context.l10n.onboardingHealthConditions,
                          style: AppTextStyles.sectionHeading),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        context.l10n.onboardingHealthConditionsNote,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.card)),
                      child: Row(children: [
                        Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.verified_user_rounded,
                                color: Colors.white, size: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              context.l10n.onboardingHealthConfidentialNote,
                              style: AppTextStyles.caption),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    for (final code in _conditions)
                      _SelectableCard(
                        title: conditionLabel(context.l10n, code) ?? code,
                        icon: Icons.medical_information_outlined,
                        selected: _selectedConditions.contains(code),
                        onTap: () => _toggleCondition(code),
                      ),
                    _SelectableCard(
                      title: context.l10n.conditionOther,
                      icon: Icons.edit_note_rounded,
                      selected: otherChosen,
                      onTap: () => _toggleCondition('other'),
                    ),
                    if (otherChosen)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cardSmall),
                            border: Border.all(color: AppColors.border)),
                        child: TextField(
                          key: const Key('other-condition'),
                          controller: _otherConditionController,
                          maxLength: OnboardingHealthNote.otherMaxLength,
                          textAlign: TextAlign.start,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            hintText:
                                context.l10n.onboardingHealthOtherConditionHint,
                            hintStyle: AppTextStyles.caption,
                          ),
                        ),
                      ),
                    _SelectableCard(
                      title: context.l10n.onboardingHealthNoConditions,
                      icon: Icons.shield_outlined,
                      selected: _selectedConditions.contains('none'),
                      onTap: () => _toggleCondition('none'),
                    ),
                    const SizedBox(height: 22),
                    Row(children: [
                      const Text('🍽', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(context.l10n.onboardingHealthAllergies,
                              style: AppTextStyles.sectionHeading)),
                      Text(context.l10n.commonOptional,
                          style: AppTextStyles.caption),
                    ]),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(context.l10n.onboardingHealthAllergiesNote,
                          style: AppTextStyles.caption),
                    ),
                    const SizedBox(height: 14),
                    for (final group in _groups)
                      _SelectableCard(
                        title: allergyGroupLabel(context.l10n, group) ?? group,
                        icon: _groupIcon(group),
                        selected: _selectedAllergies.contains(group),
                        onTap: () => _toggleAllergy(group),
                      ),
                    _SelectableCard(
                      title: context.l10n.onboardingHealthNoAllergies,
                      icon: Icons.star_border_rounded,
                      selected: _selectedAllergies.contains('none'),
                      onTap: () => _toggleAllergy('none'),
                    ),
                    if (_selectedAllergies.any((g) => g != 'none')) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(context.l10n.onboardingHealthAllergyClass,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final allergyClass in allergyClasses)
                            ChoiceChip(
                              label: Text(allergyClassLabel(
                                      context.l10n, allergyClass) ??
                                  allergyClass),
                              selected: allergyClass == _allergyClass,
                              selectedColor: AppColors.primaryTint,
                              onSelected: (_) =>
                                  setState(() => _allergyClass = allergyClass),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(children: [
                      const Icon(Icons.medication_outlined,
                          size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(context.l10n.onboardingHealthMedications,
                              style: AppTextStyles.sectionHeading)),
                      _MiniBadge(
                          label: context.l10n.onboardingHealthDoseAccuracy),
                    ]),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(context.l10n.onboardingHealthMedicationsNote,
                          style: AppTextStyles.caption),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < _medications.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.cardSmall)),
                        child: Row(children: [
                          const Icon(Icons.medication_liquid_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              _medications[i],
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeMedication(i),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textSecondary),
                          ),
                        ]),
                      ),
                    Row(children: [
                      TextButton.icon(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add_rounded,
                            size: 18, color: AppColors.primary),
                        label: Text(context.l10n.commonAdd,
                            style: AppTextStyles.pillLabel),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: AppColors.border)),
                          child: TextField(
                            controller: _medicationController,
                            textAlign: TextAlign.start,
                            onSubmitted: (_) => _addMedication(),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText:
                                  context.l10n.onboardingHealthMedicationHint,
                              hintStyle: AppTextStyles.caption,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius:
                              BorderRadius.circular(AppRadius.cardSmall)),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(context.l10n.onboardingHealthReviewNote,
                              style: AppTextStyles.caption),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(context.l10n.onboardingHealthOtherNotes,
                            style: AppTextStyles.sectionHeading)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border)),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        maxLength: _notesMaxLength,
                        textAlign: TextAlign.start,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          counterText: '',
                          hintText: context.l10n.onboardingHealthOtherNotesHint,
                          hintStyle: AppTextStyles.caption,
                        ),
                      ),
                    ),
                    if (note != null && !note.fits) ...[
                      const SizedBox(height: 8),
                      Text(
                        key: const Key('note-too-long'),
                        context.l10n.onboardingHealthNoteTooLong(note.excess),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.danger),
                      ),
                    ],
                    const ClinicalTrustFooter(),
                  ],
                ),
              ),
            ),
            OnboardingReveal(
              dy: 0.18,
              delay: const Duration(milliseconds: 260),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: GradientCtaButton(
                    label: context.l10n.onboardingHealthContinue,
                    onPressed: canContinue ? () => _continue() : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.primaryInk, fontWeight: FontWeight.w700)),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.chipInactiveBg,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon,
                color: selected ? Colors.white : AppColors.textSecondary,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.iconMuted,
                  width: 1.4),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                : null,
          ),
        ]),
      ),
    );
  }
}
