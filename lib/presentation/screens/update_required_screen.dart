import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/auth_entities.dart';
import '../../l10n/l10n.dart';
import '../widgets/gradient_cta_button.dart';

/// Shown when the server refuses this build with 426 `app_update_required`
/// (audit MO-06). It blocks the app: there is no way back, because every
/// request would be refused again. The session and the logs waiting to be
/// sent are kept, so they are all there after the update.
///
/// The button opens the store link from the 426 body, and is hidden until a
/// store listing exists.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, required this.update});

  final UpdateRequired update;

  Future<void> _open(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final url = update.storeUrl;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.system_update_rounded,
                    color: AppColors.primary, size: 64),
                const SizedBox(height: 20),
                Text(l10n.updateRequiredTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1),
                const SizedBox(height: 12),
                Text(l10n.updateRequiredBody,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body),
                if (url != null) ...[
                  const SizedBox(height: 28),
                  GradientCtaButton(
                    label: l10n.updateRequiredButton,
                    icon: Icons.open_in_new_rounded,
                    onPressed: () => _open(context, url),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
