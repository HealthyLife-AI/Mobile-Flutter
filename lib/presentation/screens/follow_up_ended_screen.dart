import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/navigation/logout_flow.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/auth_entities.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';
import 'privacy_document_screen.dart';

import '../../l10n/l10n.dart';

/// Shown when the nutritionist has ended follow-up (API guide 2.4). Every value
/// comes from the `403 follow_up_ended` body. A missing field is hidden, never
/// replaced by sample text.
class FollowUpEndedScreen extends StatelessWidget {
  const FollowUpEndedScreen({super.key, required this.followUp});

  final FollowUpEnded followUp;

  Future<void> _openWhatsApp(BuildContext context, String number) async {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse('https://wa.me/$digits'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.linkCouldNotOpen)),
      );
    }
  }

  static String _percent(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weeks = followUp.weeksFollowed;
    final adherence = followUp.adherencePercent;
    final whatsapp = followUp.whatsappNumber;
    final name = followUp.nutritionistName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.followUpEndedTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Center(
              child: Stack(alignment: Alignment.center, children: [
                Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                        color: AppColors.primaryTint, shape: BoxShape.circle)),
                const Icon(Icons.event_available_rounded,
                    color: AppColors.primary, size: 44),
                PositionedDirectional(
                    bottom: 4,
                    start: 4,
                    child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16))),
              ]),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.accentGreenBg,
                    borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.verified_rounded,
                      size: 13, color: AppColors.accentGreen),
                  const SizedBox(width: 6),
                  Text(l10n.followUpPlanCompleted,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            Text(l10n.followUpPeriodEnded,
                textAlign: TextAlign.center, style: AppTextStyles.h1),
            const SizedBox(height: 10),
            Text(
              l10n.followUpEndedMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
            if (weeks != null || adherence != null) ...[
              const SizedBox(height: 22),
              Row(children: [
                if (weeks != null)
                  Expanded(
                    child: _StatTile(
                      icon: Icons.calendar_month_outlined,
                      value: l10n.followUpWeeksValue(weeks),
                      label: l10n.followUpWeeksLabel,
                    ),
                  ),
                if (weeks != null && adherence != null)
                  const SizedBox(width: 8),
                if (adherence != null)
                  Expanded(
                    child: _StatTile(
                      icon: Icons.pie_chart_outline_rounded,
                      value: l10n.followUpAdherenceValue(_percent(adherence)),
                      label: l10n.followUpMealAdherence,
                    ),
                  ),
              ]),
            ],
            if (name != null) ...[
              const SizedBox(height: 18),
              _SpecialistCard(
                name: name,
                tag: l10n.followUpSupervisor,
                caption: l10n.followUpSupervisingSpecialist,
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Row(children: [
                const Icon(Icons.shield_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(l10n.followUpRecordsSafe,
                        style: AppTextStyles.caption)),
              ]),
            ),
            const SizedBox(height: 22),
            if (whatsapp != null) ...[
              GradientCtaButton(
                label: l10n.followUpContactWhatsApp,
                gradient: CtaGradientType.voice,
                icon: Icons.chat_rounded,
                onPressed: () => _openWhatsApp(context, whatsapp),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => performLogoutFlow(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                icon: const Icon(Icons.logout_rounded,
                    size: 18, color: AppColors.danger),
                label: Text(l10n.logoutConfirmTitle,
                    style: const TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(AppPageRoute(
                    builder: (_) => const PrivacyDocumentScreen())),
                child: Text(l10n.followUpTerms, style: AppTextStyles.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.cardTitle),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ]),
      );
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.name,
    required this.tag,
    required this.caption,
  });

  final String name;
  final String tag;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Row(children: [
          Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                  color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.primary, size: 22)),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(name,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.primary))),
              ]),
              const SizedBox(height: 2),
              Text(caption, style: AppTextStyles.caption),
            ]),
          ),
        ]),
      );
}
