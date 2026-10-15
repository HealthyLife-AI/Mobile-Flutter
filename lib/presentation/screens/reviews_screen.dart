import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/errors/result.dart';
import '../../core/state/async_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/review_entities.dart';
import '../../domain/review_focus.dart';
import '../../l10n/l10n.dart';
import '../bloc/reviews/reviews_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';

/// «ملاحظات الأخصائي»: the nutritionist's notes, with «فهمت» and the tasks in
/// them (API guide 9.2). Opened from the specialist profile, and from the push
/// for `review_new` and `review_updated`. A push passes the note it names as
/// [focusReviewId]; that note is shown first and marked.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, this.focusReviewId});

  /// The id of the note the push names, or null when opened from the profile.
  final String? focusReviewId;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return BlocProvider(
      create: (_) => ReviewsCubit(deps.reviews)..load(),
      child: _ReviewsView(focusReviewId: focusReviewId),
    );
  }
}

/// The card on the specialist profile that opens the notes.
class ReviewsEntryCard extends StatelessWidget {
  const ReviewsEntryCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.sticky_note_2_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reviewsTitle, style: AppTextStyles.cardTitle),
                    Text(l10n.reviewsEntrySubtitle,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewsView extends StatelessWidget {
  const _ReviewsView({this.focusReviewId});

  final String? focusReviewId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: l10n.reviewsTitle),
      body: BlocBuilder<ReviewsCubit, AsyncState<List<NutritionistReview>>>(
        builder: (context, state) {
          final reviews = state.dataOrNull;
          if (reviews == null) {
            if (state
                case AsyncError<List<NutritionistReview>>(:final failure)) {
              return LoadErrorView(
                message: loadFailureMessage(context, failure),
                onRetry: () => context.read<ReviewsCubit>().load(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          if (reviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.reviewsEmpty,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.secondary,
                ),
              ),
            );
          }
          final ordered = reviewsFocusedFirst(reviews, focusReviewId);
          return RefreshIndicator(
            onRefresh: () => context.read<ReviewsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
              itemCount: ordered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final review = ordered[index];
                return _ReviewCard(
                  review: review,
                  highlighted: review.id.toString() == focusReviewId,
                  onAcknowledge: () => _acknowledge(context, review),
                  onTaskChanged: (task, done) => _setTask(context, task, done),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _acknowledge(
      BuildContext context, NutritionistReview review) async {
    final result = await context.read<ReviewsCubit>().acknowledge(review.id);
    if (!context.mounted) return;
    _reportFailure(context, result);
  }

  Future<void> _setTask(
      BuildContext context, ReviewTask task, bool done) async {
    final result =
        await context.read<ReviewsCubit>().setTaskDone(task.id, done: done);
    if (!context.mounted) return;
    _reportFailure(context, result);
  }

  void _reportFailure(BuildContext context, Result<void> result) {
    final failure = result.failureOrNull;
    if (failure == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loadFailureMessage(context, failure))),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.onAcknowledge,
    required this.onTaskChanged,
    this.highlighted = false,
  });

  final NutritionistReview review;
  final VoidCallback onAcknowledge;
  final void Function(ReviewTask task, bool done) onTaskChanged;

  /// True for the note a push named, so it stands out at the top.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ratingText = reviewRatingLabel(l10n, review.rating);
    final date = review.createdAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (date != null)
                Text(context.localizeDigits(numericDate(date)),
                    style: AppTextStyles.caption),
              const Spacer(),
              if (ratingText != null)
                Text(
                  ratingText,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (review.editedAt != null)
            Text(l10n.reviewEdited, style: AppTextStyles.caption),
          if (review.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.note, style: AppTextStyles.body),
          ],
          if (review.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.reviewKeyPointsTitle,
                style: AppTextStyles.sectionHeading),
            for (final point in review.keyPoints)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('•  $point', style: AppTextStyles.body),
              ),
          ],
          if (review.tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.reviewTasksTitle, style: AppTextStyles.sectionHeading),
            for (final task in review.tasks)
              _TaskRow(
                task: task,
                onChanged: (done) => onTaskChanged(task, done),
              ),
          ],
          const SizedBox(height: 12),
          if (review.isAcknowledged)
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.reviewSeen,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          else
            GradientCtaButton(
              label: l10n.reviewAcknowledge,
              onPressed: onAcknowledge,
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onChanged});

  final ReviewTask task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      activeColor: AppColors.primary,
      title: Text(task.title, style: AppTextStyles.body),
      value: task.isDone,
      onChanged: (value) => onChanged(value ?? false),
    );
  }
}

/// The rating's label, or null when the note has none. Shared with the
/// progress screen's latest-note card.
String? reviewRatingLabel(AppLocalizations l10n, ReviewRating rating) =>
    switch (rating) {
      ReviewRating.onTrack => l10n.reviewRatingOnTrack,
      ReviewRating.smallAdjustment => l10n.reviewRatingSmallAdjustment,
      ReviewRating.reviewTogether => l10n.reviewRatingReviewTogether,
      ReviewRating.none => null,
    };
