import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/nutritionist_entities.dart';
import '../bloc/nutritionist/nutritionist_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/load_error_view.dart';
import 'reviews_screen.dart';

import '../../l10n/l10n.dart';

const Color _whatsapp = Color(0xFF25D366);
const Color _mint = Color(0xFF7DF2D6);
const Color _lavender = Color(0xFFEEF1FC);

/// ملف الأخصائي: the patient's nutritionist from `GET /me/nutritionist` (API
/// guide 9.1). Each field is shown only when the server sent it.
class SpecialistProfileScreen extends StatelessWidget {
  const SpecialistProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NutritionistCubit>(
      create: (context) =>
          NutritionistCubit(context.read<AppDependencies>().nutritionist)
            ..load(),
      child: const _SpecialistProfileView(),
    );
  }
}

class _SpecialistProfileView extends StatelessWidget {
  const _SpecialistProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.specialistTitle),
      body: BlocBuilder<NutritionistCubit, AsyncState<NutritionistProfile>>(
        builder: (context, state) {
          final profile = state.dataOrNull;
          if (profile != null) return _ProfileContent(profile: profile);
          if (state is AsyncError<NutritionistProfile>) {
            return LoadErrorView(
              message: loadFailureMessage(context, state.failure),
              onRetry: () => context.read<NutritionistCubit>().load(),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final NutritionistProfile profile;

  Future<void> _openWhatsApp(BuildContext context, Uri uri) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final bio = profile.bio;
    final hours = profile.replyHours;
    final whatsapp = profile.whatsappUri;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        // Status bar. The wording is design copy, not data from the server.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.specialistProfileActive,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body
                    .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.verified_rounded,
                size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              l10n.specialistCertified,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ]),
        ),
        const SizedBox(height: 10),

        _ProfileCard(profile: profile),
        const SizedBox(height: 16),

        ReviewsEntryCard(
          onPressed: () => Navigator.of(context).push(
            AppPageRoute<void>(builder: (_) => const ReviewsScreen()),
          ),
        ),
        const SizedBox(height: 16),

        if (bio != null) ...[
          _InfoCard(
            icon: Icons.format_quote_rounded,
            title: l10n.specialistAboutTitle,
            body: bio,
          ),
          const SizedBox(height: 16),
        ],

        if (hours != null) ...[
          _InfoCard(
            icon: Icons.access_time_rounded,
            title: l10n.specialistHoursTitle,
            body: hours,
          ),
          const SizedBox(height: 16),
        ],

        if (whatsapp != null) ...[
          _QuickConsultCard(
            onPressed: () => _openWhatsApp(context, whatsapp),
          ),
          const SizedBox(height: 12),
        ],

        const ClinicalTrustFooter(),
      ],
    );
  }
}

/// The name, specialty and clinic, each shown only when present.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final NutritionistProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final specialty = profile.specialty;
    final clinic = profile.clinicName;

    return Container(
      decoration: _cardBox(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [AppColors.primary, _mint],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _SpecialistAvatar(initial: _initialOf(profile.name)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Flexible(
                                child: Text(
                                  profile.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionHeading
                                      .copyWith(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_user_outlined,
                                          size: 11, color: AppColors.primary),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n.specialistLicensed,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ]),
                              ),
                            ]),
                            if (specialty != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                specialty,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ],
                            if (clinic != null) ...[
                              const SizedBox(height: 5),
                              Row(children: [
                                const Icon(Icons.add_box_outlined,
                                    size: 14, color: AppColors.textPrimary),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    clinic,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.textPrimary),
                                  ),
                                ),
                              ]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(
                          icon: Icons.workspace_premium_outlined,
                          label: l10n.specialistLicensedByAuthority),
                      _Tag(
                          icon: Icons.badge_outlined,
                          label: l10n.specialistDirectCare),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled card with one block of text from the server.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _lavender,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            ),
            child: Text(
              body,
              textAlign: TextAlign.start,
              style: AppTextStyles.caption
                  .copyWith(height: 1.9, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickConsultCard extends StatelessWidget {
  const _QuickConsultCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration:
                  const BoxDecoration(color: _mint, shape: BoxShape.circle),
              child: const Icon(Icons.headset_mic_rounded,
                  color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.specialistQuickConsult,
              textAlign: TextAlign.center, style: AppTextStyles.cardTitle),
          const SizedBox(height: 4),
          Text(
            l10n.specialistQuickConsultBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _whatsapp,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              onPressed: onPressed,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.specialistContactWhatsApp),
                    const SizedBox(width: 8),
                    const Icon(Icons.chat_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.specialistContactNote,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The circle with the nutritionist's initial, and a verified mark. The
/// server has no photo, so the initial is the only picture.
class _SpecialistAvatar extends StatelessWidget {
  const _SpecialistAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: AppColors.primaryTint, shape: BoxShape.circle),
            child: Text(
              initial,
              style: AppTextStyles.h1
                  .copyWith(color: AppColors.primary, fontSize: 24),
            ),
          ),
          PositionedDirectional(
            bottom: -2,
            end: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 5),
        Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption)),
      ]),
    );
  }
}

BoxDecoration _cardBox() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.hairline),
    );

/// The avatar letter: the first letter after the title, so "د. أمل" gives "أ".
String _initialOf(String name) {
  final bare = name.replaceFirst(RegExp(r'^\S+\.\s*'), '').trim();
  final source = bare.isEmpty ? name : bare;
  return source.isEmpty ? '' : source.substring(0, 1);
}
