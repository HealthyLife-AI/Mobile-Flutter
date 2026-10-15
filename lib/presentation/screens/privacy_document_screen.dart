import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

import '../../l10n/l10n.dart';

class _DocSection {
  final String heading;
  final String body;
  const _DocSection(this.heading, this.body);
}

/// A single, real, read-only document screen shared by every "read the
/// full policy" link in the app (health-data consent, the account
/// settings footer, the follow-up-ended screen's terms link) — one source
/// of truth for the legal copy instead of three dead links to nowhere.
class PrivacyDocumentScreen extends StatelessWidget {
  const PrivacyDocumentScreen({super.key});

  static List<_DocSection> _sections(AppLocalizations l10n) => [
        _DocSection(
          l10n.privacyScopeTitle,
          l10n.privacyScopeBody,
        ),
        _DocSection(
          l10n.privacyEncryptionTitle,
          l10n.privacyEncryptionBody,
        ),
        _DocSection(
          l10n.privacyAccessTitle,
          l10n.privacyAccessBody,
        ),
        _DocSection(
          l10n.privacyRightsTitle,
          l10n.privacyRightsBody,
        ),
        _DocSection(
          l10n.privacyRetentionTitle,
          l10n.privacyRetentionBody,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.privacyTitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Row(children: [
              const Icon(Icons.verified_user_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(context.l10n.privacyLastUpdated,
                      style: AppTextStyles.caption)),
            ]),
          ),
          const SizedBox(height: 18),
          for (final s in _sections(context.l10n))
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.heading, style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 8),
                    Text(s.body,
                        style: AppTextStyles.body.copyWith(height: 1.7)),
                  ]),
            ),
        ],
      ),
    );
  }
}
