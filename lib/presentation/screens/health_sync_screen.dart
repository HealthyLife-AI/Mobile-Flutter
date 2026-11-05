import 'package:flutter/material.dart';
<<<<<<< HEAD

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
                      _Badge(
                          icon: Icons.favorite_rounded,
                          color: const Color(0xFFFF5A6E)),
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
              color: const Color(0xFF16A34A),
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
=======
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';

import '../widgets/directional_icon.dart';
import '../../l10n/l10n.dart';

/// Health Sync — rationale line + a single primary button, no added
/// visual complexity, per section 5 of the spec.
class HealthSyncScreen extends StatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  State<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends State<HealthSyncScreen> {
  bool _connected = false;
  bool _loading = false;

  void _connect() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _loading = false;
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.healthSyncTitle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                    color: AppColors.accentGreenBg, shape: BoxShape.circle),
                child: Icon(
                    _connected
                        ? Icons.check_circle_rounded
                        : Icons.favorite_rounded,
                    color: AppColors.accentGreen,
                    size: 52),
              ),
              const SizedBox(height: 28),
              Text(
                  _connected
                      ? context.l10n.healthSyncConnected
                      : context.l10n.healthSyncConnectPrompt,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text(
                context.l10n.healthSyncBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 28),
              if (!_connected)
                GradientCtaButton(
                    label: context.l10n.healthSyncConnectNow,
                    icon: Icons.link_rounded,
                    loading: _loading,
                    onPressed: _connect)
              else
                GradientCtaButton(
                    label: context.l10n.healthSyncBackToProgress,
                    icon: directionalIcon(context,
                        rtl: Icons.arrow_forward_rounded,
                        ltr: Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop()),
            ],
          ),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
        ),
      ),
    );
  }
}
