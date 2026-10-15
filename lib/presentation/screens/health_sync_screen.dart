import 'package:flutter/material.dart';
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
        ),
      ),
    );
  }
}
