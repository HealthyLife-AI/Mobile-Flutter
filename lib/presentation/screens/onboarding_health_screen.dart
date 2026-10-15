import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/health_profile_entities.dart';
import '../../data/mock/health_profile_mock_data.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/onboarding_reveal.dart';
import '../widgets/onboarding_step_header.dart';
import '../widgets/clinical_trust_footer.dart';
import 'onboarding_notifications_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../../l10n/l10n.dart';

/// Onboarding step 2/3 — "البيانات الصحية": chronic conditions (single
/// clinical multi-select, at least one required), optional food allergies
/// that auto-exclude ingredients from the generated meal plan, and a
/// medications/supplements list reviewed by the specialist for interactions.
class OnboardingHealthScreen extends StatefulWidget {
  const OnboardingHealthScreen({super.key});

  @override
  State<OnboardingHealthScreen> createState() => _OnboardingHealthScreenState();
}

class _OnboardingHealthScreenState extends State<OnboardingHealthScreen> {
  final Set<String> _selectedConditions = {'pcos', 'ibs'};
  final Set<String> _selectedAllergies = {'lactose'};
  final List<MedicationEntry> _medications =
      List.of(HealthProfileMockData.defaultMedications);
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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
      _medications.add(MedicationEntry(
          name: text, frequency: context.l10n.onboardingHealthAsPrescribed));
      _medicationController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _removeMedication(int index) =>
      setState(() => _medications.removeAt(index));

  void _continue() {
    Navigator.of(context).push(
        AppPageRoute(builder: (_) => const OnboardingNotificationsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedConditions.isNotEmpty;
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
                    for (final a in HealthProfileMockData.allergies)
                      _SelectableCard(
                        title: a.title,
                        subtitle: a.subtitle,
                        icon: a.icon,
                        selected: _selectedAllergies.contains(a.id),
                        onTap: () => _toggleAllergy(a.id),
                      ),
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
                              _medications[i].name,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_medications[i].frequency,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.pillLabel),
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
                        maxLength: 200,
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
                    onPressed: canContinue ? _continue : null),
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
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
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
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
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
