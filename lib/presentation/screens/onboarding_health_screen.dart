import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/health_profile_mock_data.dart';
import '../../domain/change_request_rules.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../health_profile_labels.dart';
=======
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/health_profile_entities.dart';
import '../../data/mock/health_profile_mock_data.dart';
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import '../widgets/gradient_cta_button.dart';
import '../widgets/onboarding_reveal.dart';
import '../widgets/onboarding_step_header.dart';
import '../widgets/clinical_trust_footer.dart';
<<<<<<< HEAD
import '../widgets/spec_ui.dart';
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
import 'onboarding_notifications_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../../l10n/l10n.dart';

<<<<<<< HEAD
/// Onboarding step 2/3 — "البيانات الصحية": chronic conditions (at least one
/// choice, "none" included), optional food allergies and a medications list.
///
/// Nothing is chosen for the patient. On continue, each allergy and each
/// medication goes to the nutritionist as a change request (API guide 11.2);
/// they reach the profile once approved. The API has no field for chronic
/// conditions or free notes, so those go together as one quick request.
=======
/// Onboarding step 2/3 — "البيانات الصحية": chronic conditions (single
/// clinical multi-select, at least one required), optional food allergies
/// that auto-exclude ingredients from the generated meal plan, and a
/// medications/supplements list reviewed by the specialist for interactions.
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
class OnboardingHealthScreen extends StatefulWidget {
  const OnboardingHealthScreen({super.key});

  @override
  State<OnboardingHealthScreen> createState() => _OnboardingHealthScreenState();
}

class _OnboardingHealthScreenState extends State<OnboardingHealthScreen> {
<<<<<<< HEAD
  final Set<String> _selectedConditions = {};

  /// API allergy groups (11.2), or `none`.
  final Set<String> _selectedAllergies = {};

  /// One `class` for every allergy chosen here; each can be changed later
  /// from the health record.
  String _allergyClass = allergyClasses.first;
  final List<String> _medications = [];
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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

  /// The notes field is short, so the conditions and the notes fit in one
  /// quick request.
  static const int _notesMaxLength = 100;

=======
  final Set<String> _selectedConditions = {'pcos', 'ibs'};
  final Set<String> _selectedAllergies = {'lactose'};
  final List<MedicationEntry> _medications =
      List.of(HealthProfileMockData.defaultMedications);
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  @override
  void dispose() {
    _medicationController.dispose();
    _notesController.dispose();
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
<<<<<<< HEAD
      // A medication name is at most 100 characters (11.2).
      _medications.add(text.length > 100 ? text.substring(0, 100) : text);
=======
      _medications.add(MedicationEntry(
          name: text, frequency: context.l10n.onboardingHealthAsPrescribed));
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      _medicationController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removeMedication(int index) =>
      setState(() => _medications.removeAt(index));

<<<<<<< HEAD
  Future<void> _continue() async {
    if (_sending) return;
    setState(() => _sending = true);
    final failure = await _sendHealthDetails();
    if (!mounted) return;
    setState(() => _sending = false);
    if (failure != null) {
      showSpecSnack(context, requestFailureMessage(context.l10n, failure),
          error: true);
      return;
    }
=======
  void _continue() {
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
    Navigator.of(context).push(
        AppPageRoute(builder: (_) => const OnboardingNotificationsScreen()));
  }

<<<<<<< HEAD
  /// Sends what the patient entered and returns the first failure, or null.
  /// An item the profile already has, or one already waiting for the
  /// nutritionist, counts as sent.
  Future<Failure?> _sendHealthDetails() async {
    final deps = context.read<AppDependencies>();
    final note = _conditionsNote(context.l10n);
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

  /// The chronic conditions and the notes, as one quick request to the
  /// nutritionist. Null when there is neither.
  String? _conditionsNote(AppLocalizations l10n) {
    final conditions = [
      for (final c in HealthProfileMockData.conditions)
        if (c.id != 'none' && _selectedConditions.contains(c.id)) c.title,
    ];
    final notes = _notesController.text.trim();
    if (conditions.isEmpty && notes.isEmpty) return null;
    final note = [
      if (conditions.isNotEmpty)
        l10n.onboardingHealthRequestConditions(conditions.join('، ')),
      if (notes.isNotEmpty) l10n.onboardingHealthRequestNotes(notes),
    ].join('\n');
    return note.length <= QuickRequestDraft.noteMaxLength
        ? note
        : note.substring(0, QuickRequestDraft.noteMaxLength);
  }

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
    final bool canContinue = _selectedConditions.isNotEmpty && !_sending;
    final noAllergy =
        HealthProfileMockData.allergies.firstWhere((a) => a.id == 'none');
=======
  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedConditions.isNotEmpty;
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
                    for (final c in HealthProfileMockData.conditions)
                      _SelectableCard(
                        title: c.title,
                        subtitle: c.subtitle,
                        icon: c.icon,
                        selected: _selectedConditions.contains(c.id),
                        onTap: () => _toggleCondition(c.id),
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
<<<<<<< HEAD
                    for (final group in _groups)
                      _SelectableCard(
                        title: allergyGroupLabel(context.l10n, group) ?? group,
                        icon: _groupIcon(group),
                        selected: _selectedAllergies.contains(group),
                        onTap: () => _toggleAllergy(group),
                      ),
                    _SelectableCard(
                      title: noAllergy.title,
                      subtitle: noAllergy.subtitle,
                      icon: noAllergy.icon,
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
=======
                    for (final a in HealthProfileMockData.allergies)
                      _SelectableCard(
                        title: a.title,
                        subtitle: a.subtitle,
                        icon: a.icon,
                        selected: _selectedAllergies.contains(a.id),
                        onTap: () => _toggleAllergy(a.id),
                      ),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
<<<<<<< HEAD
                              _medications[i],
=======
                              _medications[i].name,
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(width: 8),
<<<<<<< HEAD
=======
                          Text(_medications[i].frequency,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.pillLabel),
                          const SizedBox(width: 8),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
<<<<<<< HEAD
                        maxLength: _notesMaxLength,
=======
                        maxLength: 200,
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          counterText: '',
                          hintText: context.l10n.onboardingHealthOtherNotesHint,
                          hintStyle: AppTextStyles.caption,
                        ),
                      ),
                    ),
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
<<<<<<< HEAD
                    onPressed: canContinue ? () => _continue() : null),
=======
                    onPressed: canContinue ? _continue : null),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final String title;
<<<<<<< HEAD
  final String? subtitle;
=======
  final String subtitle;
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
<<<<<<< HEAD
    this.subtitle,
=======
    required this.subtitle,
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
<<<<<<< HEAD
                if (subtitle case final subtitle?) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
=======
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
