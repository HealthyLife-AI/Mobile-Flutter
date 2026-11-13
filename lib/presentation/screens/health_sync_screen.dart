import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/spec_ui.dart';

import '../../l10n/l10n.dart';

/// "ربط التطبيق بالصحة" — what linking to Apple Health / Health Connect will
/// bring, and what it never does.
///
/// The link itself is not available yet: it needs the platform health
/// permissions and a server endpoint for the data. Until then the screen says
/// so plainly and offers no button that only pretends to connect.
class HealthSyncScreen extends StatelessWidget {
  const HealthSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final apple = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.healthSyncTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Badge(
                          icon: Icons.favorite_rounded,
                          color: AppColors.danger),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.sync_alt_rounded,
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const _Badge(
                          icon: Icons.eco_rounded, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                      apple
                          ? l10n.healthSyncHeroApple
                          : l10n.healthSyncHeroAndroid,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.sectionHeading
                          .copyWith(color: Colors.white, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(l10n.healthSyncHeroBody,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.secondary.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5)),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(l10n.healthSyncComingSoon,
                        style: AppTextStyles.pillLabel
                            .copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SpecSectionTitle(l10n.healthSyncWhatTitle,
                icon: Icons.auto_awesome_outlined),
            const SizedBox(height: 10),
            _Benefit(
              icon: Icons.directions_walk_rounded,
              color: AppColors.success,
              title: l10n.healthSyncSteps,
              body: l10n.healthSyncStepsBody,
            ),
            _Benefit(
              icon: Icons.bedtime_outlined,
              color: const Color(0xFF6366F1),
              title: l10n.healthSyncSleep,
              body: l10n.healthSyncSleepBody,
            ),
            _Benefit(
              icon: Icons.monitor_weight_outlined,
              color: AppColors.primary,
              title: l10n.healthSyncWeight,
              body: l10n.healthSyncWeightBody,
            ),
            const SizedBox(height: 8),
            SpecCard(
              color: AppColors.successBg,
              child: SpecColumn(
                gap: 8,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.healthSyncPrivacyTitle,
                            style: AppTextStyles.cardTitle
                                .copyWith(color: AppColors.success)),
                      ),
                    ],
                  ),
                  BulletLine(l10n.healthSyncPrivacyRead),
                  BulletLine(l10n.healthSyncPrivacyChoice),
                  BulletLine(l10n.healthSyncPrivacyStop),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.healthSyncMeanwhile,
                textAlign: TextAlign.center, style: AppTextStyles.tiny),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SpecCard(
        child: SpecCardHeader(
          icon: icon,
          iconColor: color,
          title: title,
          subtitle: body,
        ),
      ),
    );
  }
}
