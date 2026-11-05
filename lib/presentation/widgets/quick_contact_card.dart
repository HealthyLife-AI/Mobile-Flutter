import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../screens/my_requests_screen.dart';
import '../screens/quick_request_screen.dart';
import 'spec_ui.dart';

void openQuickRequest(BuildContext context) => Navigator.of(context)
    .push(AppPageRoute(builder: (_) => const QuickRequestScreen()));

void openMyRequests(BuildContext context) => Navigator.of(context)
    .push(AppPageRoute(builder: (_) => const MyRequestsScreen()));

/// Home: "صار عندك ظرف؟". Always shown to a patient with a nutritionist (every
/// patient of this app). The "N بانتظار الرد" badge only while some requests
/// are open.
class QuickContactCard extends StatelessWidget {
  const QuickContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = context.select<QuickRequestsCubit, int>(
        (cubit) => QuickRequestsCubit.openCountOf(cubit.state));
    return SpecCard(
      highlighted: true,
      child: SpecColumn(
        children: [
          SpecCardHeader(
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.quickContactTitle,
            subtitle: l10n.quickContactSubtitle,
          ),
          Text(l10n.quickContactBody,
              style: AppTextStyles.secondary
                  .copyWith(color: AppColors.textSecondary, height: 1.5)),
          SpecPrimaryButton(
            label: l10n.quickContactButton,
            onPressed: () => openQuickRequest(context),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => openMyRequests(context),
                child: Text(l10n.myRequestsLink,
                    style: AppTextStyles.secondary.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              if (open > 0)
                StatusPill(l10n.requestsAwaiting(context.localizeDigits(open)),
                    tone: PillTone.warning),
            ],
          ),
        ],
      ),
    );
  }
}

/// A full-width "تواصل سريع مع أخصائيتك" button: replaces the WhatsApp
/// discussion button on the progress screen.
class QuickContactButton extends StatelessWidget {
  const QuickContactButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpecPrimaryButton(
      label: context.l10n.quickContactButton,
      icon: Icons.chat_bubble_outline_rounded,
      onPressed: () => openQuickRequest(context),
    );
  }
}
