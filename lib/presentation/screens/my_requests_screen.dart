import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/patient_care_entities.dart';
import '../../l10n/l10n.dart';
import '../bloc/patient_features_cubits.dart';
import '../date_labels.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/load_error_view.dart';
import '../widgets/spec_ui.dart';
import 'quick_request_screen.dart';

/// "طلباتي" — `GET /me/quick-requests`, newest first. Opening the screen reads
/// the list, which marks the replies read on the server. No edit, no delete.
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuickRequestsCubit>().load();
  }

  void _newRequest() => Navigator.of(context).pushReplacement(
      AppPageRoute(builder: (_) => const QuickRequestScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<QuickRequestsCubit>().state;
    final requests = state.dataOrNull;

    final Widget body;
    if (requests == null) {
      body = state is AsyncError<List<QuickRequest>>
          ? LoadErrorView(
              message: loadFailureMessage(context, state.failure),
              onRetry: () => context.read<QuickRequestsCubit>().load(),
            )
          : const Center(child: CircularProgressIndicator());
    } else if (requests.isEmpty) {
      body = Center(
        child: SpecEmptyState(
          icon: Icons.forum_outlined,
          title: l10n.myRequestsEmpty,
          body: l10n.myRequestsEmptyBody,
          action: SpecPrimaryButton(
              expand: false,
              label: l10n.quickRequestTitle,
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: _newRequest),
        ),
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<QuickRequestsCubit>().load(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) => _RequestCard(request: requests[i]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.myRequestsTitle),
      body: SafeArea(child: body),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final QuickRequest request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final note = request.note;
    final response = request.response;
    final occasion = request.occasionDate;
    final subtitle = [
      l10n.requestSentOn(dayAndTimeLabel(context, request.createdAt)),
      if (occasion != null)
        l10n.requestOccasionOn(shortDateLabel(context, occasion)),
    ].join(' • ');
    final (statusLabel, tone) = switch (request.status) {
      QuickRequestStatus.open => (l10n.requestStatusOpen, PillTone.warning),
      QuickRequestStatus.answered => (
          l10n.requestStatusAnswered,
          PillTone.success
        ),
      QuickRequestStatus.closed => (l10n.requestStatusClosed, PillTone.neutral),
      QuickRequestStatus.unknown => (null, PillTone.neutral),
    };
    final respondedAt = request.respondedAt;

    final card = SpecCard(
      child: SpecColumn(
        children: [
          SpecCardHeader(
            icon: quickRequestReasonIcon(request.reason),
            title: quickRequestReasonLabel(l10n, request.reason),
            subtitle: subtitle,
            trailing: statusLabel == null
                ? null
                : StatusPill(statusLabel, tone: tone),
          ),
          if (note != null)
            Text('«$note»',
                style: AppTextStyles.secondary
                    .copyWith(color: AppColors.textSecondary, height: 1.5)),
          if (response != null)
            SpecPanel(
              color: AppColors.primaryTint,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          respondedAt == null
                              ? l10n.requestReplyLabel
                              : l10n.requestReplyFrom(
                                  dayAndTimeLabel(context, respondedAt)),
                          style: AppTextStyles.pillLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(response,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w400, height: 1.6)),
                ],
              ),
            )
          else if (request.isOpen)
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 15, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(l10n.requestAwaitingReply,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning)),
              ],
            ),
        ],
      ),
    );
    return request.status == QuickRequestStatus.closed
        ? Opacity(opacity: 0.75, child: card)
        : card;
  }
}
