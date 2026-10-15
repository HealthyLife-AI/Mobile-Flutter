import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/navigation/push_destination.dart';
import '../../core/navigation/push_navigation.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/notification_entities.dart';
import '../bloc/notifications/notifications_cubit.dart';
import '../notification_category_labels.dart';
import 'log_meal_intro_screen.dart';
import '../../core/navigation/app_page_route.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';

import '../widgets/directional_icon.dart';
import '../../l10n/l10n.dart';

/// "التنبيهات" — the notification feed/inbox (distinct from
/// [NotificationSettingsScreen], which configures *which* notifications get
/// sent). Filterable by category, grouped by day, each entry rendered with
/// the rich body its [NotificationVariant] calls for, plus a rotating
/// "tips" footer card.
///
/// The entries and their read state come from [NotificationsCubit], which the
/// app loads once the patient is signed in and which persists the read state,
/// so the inbox survives restarts and matches the home bell's unread badge.
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  NotificationCategory _filter = NotificationCategory.all;

  @override
  void initState() {
    super.initState();
    // Shown from a push tap or the profile before the app loaded it: read it.
    final cubit = context.read<NotificationsCubit>();
    if (cubit.state.status == NotificationsStatus.initial) {
      cubit.load();
    }
  }

  List<NotificationDateGroup> _visibleGroups(
      List<NotificationDateGroup> groups) {
    if (_filter == NotificationCategory.all) return groups;
    return groups
        .map((g) => NotificationDateGroup(
            label: g.label,
            day: g.day,
            items: g.items.where((n) => n.category == _filter).toList()))
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.notificationsTitle),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.status == NotificationsStatus.loading &&
                state.groups.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == NotificationsStatus.error &&
                state.groups.isEmpty) {
              return LoadErrorView(
                message: loadFailureMessage(context, state.failure),
                onRetry: () => context.read<NotificationsCubit>().load(),
              );
            }
            return _Body(
              state: state,
              filter: _filter,
              onFilter: (c) => setState(() => _filter = c),
              visibleGroups: _visibleGroups(state.groups),
            );
          },
        ),
      ),
    );
  }
}

/// "Today", "Yesterday", or the date, for a group of inbox rows.
String _dayLabel(BuildContext context, DateTime day) {
  final now = DateTime.now();
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(day.year, day.month, day.day))
      .inDays;
  if (days == 0) return context.l10n.commonToday;
  if (days == 1) return context.l10n.notificationsYesterday;
  return context
      .localizeDigits(MaterialLocalizations.of(context).formatMediumDate(day));
}

/// How long ago a row arrived: "just now", minutes, hours (same day), or the
/// time of day for an older row whose day the group header already gives.
String _timeLabel(BuildContext context, NotificationEntry entry) {
  final at = entry.createdAt;
  if (at == null) return entry.time;
  final now = DateTime.now();
  final age = now.difference(at);
  final l10n = context.l10n;
  if (age.inMinutes < 1) return l10n.notificationsJustNow;
  if (age.inHours < 1) {
    return l10n.notificationsMinutesAgo(
        age.inMinutes, context.localizeDigits(age.inMinutes));
  }
  if (isSameLocalDay(at, now)) {
    return l10n.notificationsHoursAgo(
        age.inHours, context.localizeDigits(age.inHours));
  }
  return context.localizeDigits(MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(at)));
}

/// Marks the row read and opens the screen its type points to (API guide
/// 10.3), like a tapped push. A row that would only open the inbox again
/// stays here.
void _openEntry(BuildContext context, NotificationEntry entry) {
  if (entry.unread) context.read<NotificationsCubit>().markRead(entry.id);
  final type = entry.type;
  if (type == null) return;
  final destination = destinationForType(type);
  if (destination == PushDestination.inbox) return;
  openPushDestination(destination, reviewId: entry.reviewId);
}

/// The loaded inbox: the mark-all row, the category filter, the grouped list,
/// and the empty/error states. Split from the stateful widget so the cubit's
/// state can be passed in without rebuilding the whole scaffold.
class _Body extends StatelessWidget {
  final NotificationsState state;
  final NotificationCategory filter;
  final ValueChanged<NotificationCategory> onFilter;
  final List<NotificationDateGroup> visibleGroups;

  const _Body({
    required this.state,
    required this.filter,
    required this.onFilter,
    required this.visibleGroups,
  });

  @override
  Widget build(BuildContext context) {
    final unread = state.unreadCount;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              if (unread > 0)
                TextButton(
                  onPressed: () =>
                      context.read<NotificationsCubit>().markAllRead(),
                  child: ButtonShine(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      child: Text(context.l10n.notificationsMarkAllRead,
                          style: AppTextStyles.pillLabel),
                    ),
                  ),
                ),
              const Spacer(),
              if (unread > 0)
                Row(children: [
                  Text(
                      context.l10n.notificationsNewCount(
                          unread, context.localizeDigits(unread)),
                      style: AppTextStyles.caption),
                  const SizedBox(width: 6),
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle)),
                ]),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                children: NotificationCategory.values.map((c) {
                  final bool active = c == filter;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: ButtonShine(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(c == NotificationCategory.all
                              ? context.l10n.notificationCategoryAll
                              : '${c.label(context.l10n)} ${_emojiFor(c)}'),
                        ),
                      ),
                      selected: active,
                      onSelected: (_) => onFilter(c),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.chipInactiveBg,
                      labelStyle: AppTextStyles.caption.copyWith(
                          color:
                              active ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          side: BorderSide.none),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            children: [
              const _NotificationsHero(),
              if (state.status == NotificationsStatus.empty ||
                  state.groups.isEmpty)
                const _EmptyInboxState()
              else ...[
                for (final group in visibleGroups) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                        group.day == null
                            ? group.label
                            : _dayLabel(context, group.day!),
                        style: AppTextStyles.sectionHeading),
                  ),
                  for (final n in group.items)
                    _NotificationReveal(
                      key: ValueKey(n.id),
                      child: _NotificationCard(
                        entry: n,
                        onTap: () => _openEntry(context, n),
                      ),
                    ),
                ],
                if (visibleGroups.isEmpty) const _EmptyFilterState(),
                // Older rows are read a page at a time (20 rows, 10.2).
                if (state.hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: state.loadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            )
                          : TextButton.icon(
                              onPressed: () =>
                                  context.read<NotificationsCubit>().loadMore(),
                              icon: const Icon(Icons.expand_more_rounded),
                              label: Text(context.l10n.notificationsLoadOlder),
                            ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              const _TipsFooterCard(),
            ],
          ),
        ),
      ],
    );
  }

  String _emojiFor(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.meals:
        return '🍽';
      case NotificationCategory.measurements:
        return '⚖';
      case NotificationCategory.planUpdates:
        return '📅';
      case NotificationCategory.nutritionist:
        return '🩺';
      case NotificationCategory.other:
      case NotificationCategory.all:
        return '';
    }
  }
}

class _NotificationReveal extends StatefulWidget {
  final Widget child;

  const _NotificationReveal({super.key, required this.child});

  @override
  State<_NotificationReveal> createState() => _NotificationRevealState();
}

class _NotificationRevealState extends State<_NotificationReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();
  late final Animation<double> _entrance =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entrance,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _entrance.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - _entrance.value)),
          child: child,
        ),
      ),
    );
  }
}

class _NotificationsHero extends StatefulWidget {
  const _NotificationsHero();

  @override
  State<_NotificationsHero> createState() => _NotificationsHeroState();
}

class _NotificationsHeroState extends State<_NotificationsHero>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bellScale =
        CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primaryTint.withValues(alpha: 0.8),
              AppColors.surface
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          AnimatedBuilder(
            animation: Listenable.merge([bellScale, _pulse]),
            builder: (context, _) => Transform.scale(
              scale: bellScale.value * (1 + _pulse.value * 0.035),
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  width: 58 + _pulse.value * 8,
                  height: 58 + _pulse.value * 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.15 + _pulse.value * 0.12)),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: Colors.white, size: 23),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.l10n.notificationsAllInOne,
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(context.l10n.notificationsSubtitle,
                  style: AppTextStyles.caption),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntry entry;

  /// Called when the person opens an unread entry, marking it read. Null when
  /// the entry is already read (nothing to do).
  final VoidCallback? onTap;
  const _NotificationCard({required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: entry.unread
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (entry.unread)
                Padding(
                    padding: const EdgeInsetsDirectional.only(top: 6, end: 6),
                    child: _PulsingDot()),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(entry.body, style: AppTextStyles.caption),
                    ]),
              ),
              const SizedBox(width: 10),
              _EntryAvatar(entry: entry),
            ]),
            const SizedBox(height: 12),
            _buildVariantBody(context),
            const SizedBox(height: 10),
            Row(children: [
              if (entry.variant == NotificationVariant.mealPreview)
                _LogNowButton()
              else if (entry.statusDone == true)
                Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(context.l10n.notificationsRead,
                      style: AppTextStyles.caption)
                ])
              else
                const SizedBox.shrink(),
              const Spacer(),
              Row(children: [
                Text(_timeLabel(context, entry), style: AppTextStyles.caption),
                const SizedBox(width: 4),
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.textSecondary),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildVariantBody(BuildContext context) {
    switch (entry.variant) {
      case NotificationVariant.mealPreview:
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: AppColors.accentGreenBg,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.restaurant_rounded,
                  color: AppColors.accentGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.mealTitle ?? '',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                        context.l10n.notificationsMealMacros(
                            '${entry.mealProteinG}', '${entry.mealCarbsG}'),
                        style: AppTextStyles.caption),
                  ]),
            ),
          ]),
        );
      case NotificationVariant.specialistNote:
        return _StatRow(
            icon: Icons.local_drink_outlined,
            badge: context.l10n.notificationsClinicalUpdate,
            label: entry.statLabel!,
            value: entry.statValue!);
      case NotificationVariant.planSync:
        return Column(children: [
          _StatRow(
              icon: Icons.trending_up_rounded,
              badge: null,
              label: entry.statLabel!,
              value: entry.statValue!),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
                value: entry.syncPercent,
                minHeight: 6,
                backgroundColor: AppColors.neutralTrack,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary)),
          ),
        ]);
      case NotificationVariant.measurementStatus:
      case NotificationVariant.plain:
        return const SizedBox.shrink();
    }
  }
}

class _EntryAvatar extends StatelessWidget {
  final NotificationEntry entry;
  const _EntryAvatar({required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.variant == NotificationVariant.specialistNote) {
      return Stack(children: [
        Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryTint, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 20)),
        PositionedDirectional(
            bottom: -2,
            start: -2,
            child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.medical_services_rounded,
                    color: Colors.white, size: 10))),
      ]);
    }
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: AppColors.chipInactiveBg, shape: BoxShape.circle),
      child: Text(entry.emoji, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final String label;
  final String value;
  const _StatRow(
      {required this.icon,
      required this.badge,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (badge != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          child: Text(badge!,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
      ] else
        const Spacer(),
      Icon(icon, size: 14, color: AppColors.primary),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption),
      const SizedBox(width: 6),
      Text(value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
    ]);
  }
}

class _LogNowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(AppPageRoute(builder: (_) => const LogMealIntroScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: ButtonShine(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_task_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(context.l10n.notificationsLogNow,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color:
                  AppColors.accentGreen.withValues(alpha: 0.5 + 0.5 * _c.value),
              shape: BoxShape.circle)),
    );
  }
}

/// The inbox itself is empty (no notifications at all yet), distinct from
/// [_EmptyFilterState], which is shown when the active category filter matches
/// nothing.
class _EmptyInboxState extends StatelessWidget {
  const _EmptyInboxState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.chipInactiveBg, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined,
                color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        Text(context.l10n.commonEmptyTitle, style: AppTextStyles.cardTitle),
        const SizedBox(height: 6),
        Text(context.l10n.commonEmptyBody,
            textAlign: TextAlign.center, style: AppTextStyles.caption),
      ]),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.chipInactiveBg, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_off_outlined,
                color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        Text(context.l10n.notificationsEmptyCategory,
            style: AppTextStyles.caption),
      ]),
    );
  }
}

class _TipsFooterCard extends StatelessWidget {
  const _TipsFooterCard();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFDCEFEA), Color(0xFFEFF8F5)]),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(children: [
          Icon(
              directionalIcon(context,
                  rtl: Icons.chevron_left_rounded,
                  ltr: Icons.chevron_right_rounded),
              color: AppColors.primary),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(context.l10n.notificationsPersonalized,
                    style: AppTextStyles.cardTitle),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded,
                    color: AppColors.primary, size: 18),
              ]),
              const SizedBox(height: 4),
              Text(context.l10n.notificationsEditMealTimes,
                  style: AppTextStyles.caption, textAlign: TextAlign.start),
            ]),
          ),
        ]),
      ),
    );
  }
}
