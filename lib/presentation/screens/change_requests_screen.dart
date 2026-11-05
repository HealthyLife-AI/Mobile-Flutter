import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/patient_health_profile_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/health_profile/health_profile_cubit.dart';
import '../health_profile_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/confirm_action_sheet.dart';
import 'change_request_forms.dart';

const _lav = Color(0xFFF6F8FE);

/// "طلب تعديل" — asks the nutritionist to change the goal, medications or
/// allergies, and shows the requests already sent (API guide 11.2, 11.3).
class ChangeRequestsScreen extends StatelessWidget {
  const ChangeRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: context.l10n.healthRequestsTitle),
      body: BlocBuilder<HealthProfileCubit, AsyncState<PatientHealthProfile>>(
        builder: (context, state) {
          final profile = state.dataOrNull;
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _RequestsList(profile: profile);
        },
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.profile});

  final PatientHealthProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = profile.proposals.where((p) => p.status == 'pending');
    bool isPending(String kind, int? id) =>
        id != null && pending.any((p) => p.kind == kind && p.targetId == id);
    // A goal has no id, so a pending goal request is matched by its kind alone.
    final goalPending = pending.any((p) => p.kind == 'goal');
    String dateText(DateTime date) => context.localizeDigits(numericDate(date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        Text(l10n.healthRequestIntro, style: AppTextStyles.secondary),
        const SizedBox(height: 16),
        _Section(
          title: l10n.healthRequestGoalSection,
          children: [
            Text(
              profile.goal == null
                  ? l10n.healthGoalNotSet
                  : goalTypeLabel(l10n, profile.goal!.goalType),
              style: AppTextStyles.body,
            ),
            if (goalPending) ...[
              const SizedBox(height: 4),
              Text(l10n.healthRequestPendingChip, style: AppTextStyles.caption),
            ],
            const SizedBox(height: 10),
            _ActionButton(
              icon: Icons.flag_outlined,
              label: l10n.healthRequestChangeGoal,
              // Off while a goal request waits for the nutritionist.
              onTap: goalPending
                  ? null
                  : () =>
                      _open(context, GoalRequestScreen(current: profile.goal)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Section(
          title: l10n.healthRequestMedicationsSection,
          children: [
            if (profile.medications.isEmpty)
              Text(l10n.healthNoMedications, style: AppTextStyles.caption),
            for (final medication in profile.medications)
              _ItemRow(
                title: medication.name,
                subtitle:
                    medicationDetails(l10n, medication, formatDate: dateText),
                pendingLabel: isPending('medication', medication.id)
                    ? l10n.healthRequestPendingChip
                    : null,
                onEdit: medication.id == null ||
                        isPending('medication', medication.id)
                    ? null
                    : () => _open(
                        context, MedicationRequestScreen(existing: medication)),
                onRemove: medication.id == null ||
                        isPending('medication', medication.id)
                    ? null
                    : () =>
                        _confirmRemove(context, 'medication', medication.id!),
              ),
            _ActionButton(
              icon: Icons.add_rounded,
              label: l10n.healthRequestAddMedication,
              onTap: () => _open(context, const MedicationRequestScreen()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Section(
          title: l10n.healthRequestAllergiesSection,
          children: [
            if (profile.allergies.isEmpty)
              Text(l10n.healthNoAllergies, style: AppTextStyles.caption),
            for (final allergy in profile.allergies)
              _ItemRow(
                title: allergy.label,
                subtitle: allergyClassLabel(l10n, allergy.allergyClass) ?? '',
                pendingLabel: isPending('allergy', allergy.id)
                    ? l10n.healthRequestPendingChip
                    : null,
                onEdit: allergy.id == null || isPending('allergy', allergy.id)
                    ? null
                    : () =>
                        _open(context, AllergyRequestScreen(existing: allergy)),
                onRemove: allergy.id == null || isPending('allergy', allergy.id)
                    ? null
                    : () => _confirmRemove(context, 'allergy', allergy.id!),
              ),
            _ActionButton(
              icon: Icons.add_rounded,
              label: l10n.healthRequestAddAllergy,
              onTap: () => _open(context, const AllergyRequestScreen()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Section(
          title: l10n.healthRequestMyRequestsSection,
          children: [
            if (profile.proposals.isEmpty)
              Text(l10n.healthRequestNoRequests, style: AppTextStyles.caption),
            for (final proposal in profile.proposals)
              _RequestRow(
                proposal: proposal,
                onWithdraw: proposal.status == 'pending' && proposal.id != null
                    ? () => _confirmWithdraw(context, proposal.id!)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    final cubit = context.read<HealthProfileCubit>();
    Navigator.of(context).push(AppPageRoute<void>(
      builder: (_) => BlocProvider.value(value: cubit, child: screen),
    ));
  }

  Future<void> _confirmRemove(BuildContext context, String kind, int id) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: l10n.healthRequestRemoveTitle,
      message: l10n.healthRequestRemoveBody,
      confirmLabel: l10n.healthRequestRemove,
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed != true || !context.mounted) return;
    final result = await context.read<HealthProfileCubit>().submit(
          ChangeRequestDraft(kind: kind, action: 'remove', targetId: id),
        );
    if (!context.mounted) return;
    _report(context, result, l10n.healthRequestSent);
  }

  Future<void> _confirmWithdraw(BuildContext context, int proposalId) async {
    final l10n = context.l10n;
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.undo_rounded,
      title: l10n.healthRequestWithdrawTitle,
      message: l10n.healthRequestWithdrawBody,
      confirmLabel: l10n.healthRequestWithdraw,
      cancelLabel: l10n.commonCancel,
      destructive: false,
    );
    if (confirmed != true || !context.mounted) return;
    final result =
        await context.read<HealthProfileCubit>().withdraw(proposalId);
    if (!context.mounted) return;
    _report(context, result, l10n.healthRequestWithdrawnSnack);
  }

  void _report(BuildContext context, Result<void> result, String successText) {
    final messenger = ScaffoldMessenger.of(context);
    final text = result.failureOrNull == null
        ? successText
        : requestFailureMessage(context.l10n, result.failureOrNull!);
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }
}

/// The item a request is about, as the server echoed it in the payload.
String? _requestedItem(AppLocalizations l10n, ChangeProposal proposal) {
  final data = proposal.payload;
  String? text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
  switch (proposal.kind) {
    case 'medication':
      return text(data['name']);
    case 'allergy':
      final group = text(data['group']);
      if (group == null) return text(data['other_text']);
      return group == 'other'
          ? text(data['other_text']) ?? allergyGroupLabel(l10n, group)
          : allergyGroupLabel(l10n, group);
    case 'goal':
      final goalType = text(data['goal_type']);
      return goalType == null ? null : goalTypeLabel(l10n, goalType);
    default:
      return null;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.sectionHeading),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.title,
    required this.subtitle,
    this.pendingLabel,
    this.onEdit,
    this.onRemove,
  });

  final String title;
  final String subtitle;
  final String? pendingLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
          color: _lav,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cardTitle),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: AppTextStyles.caption),
              if (pendingLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(pendingLabel!,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            tooltip: l10n.healthRequestActionEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: onEdit,
          ),
        if (onRemove != null)
          IconButton(
            tooltip: l10n.healthRequestRemove,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
            onPressed: onRemove,
          ),
      ]),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({required this.proposal, this.onWithdraw});

  final ChangeProposal proposal;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kind = requestKindLabel(l10n, proposal.kind);
    final action = requestActionLabel(l10n, proposal.action);
    final item = _requestedItem(l10n, proposal);
    final status = requestStatusLabel(l10n, proposal.status) ?? proposal.status;
    final note = proposal.decisionNote;
    final title = [kind, action].whereType<String>().join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _lav,
          borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          if (item != null) Text(item, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTextStyles.caption.copyWith(
              color: proposal.status == 'pending'
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (note != null)
            Text(l10n.healthRequestDecisionNote(note),
                style: AppTextStyles.caption),
          if (onWithdraw != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onWithdraw,
                child: Text(l10n.healthRequestWithdraw),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;

  /// Null turns the button off.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
