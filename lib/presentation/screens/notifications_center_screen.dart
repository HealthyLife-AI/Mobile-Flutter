import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification_entities.dart';
import '../../data/mock/notification_mock_data.dart';
import '../notification_category_labels.dart';
import 'log_meal_intro_screen.dart';
import '../../core/navigation/app_page_route.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/gradient_cta_button.dart';

/// "التنبيهات" — the notification feed/inbox (distinct from
/// [NotificationSettingsScreen], which configures *which* notifications get
/// sent). Filterable by category, grouped by day, each entry rendered with
/// the rich body its [NotificationVariant] calls for, plus a rotating
/// "tips" footer card.
class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  NotificationCategory _filter = NotificationCategory.all;
  late List<NotificationDateGroup> _groups = NotificationMockData.groups;

  int get _unreadCount =>
      _groups.expand((g) => g.items).where((n) => n.unread).length;

  List<NotificationDateGroup> get _visibleGroups {
    if (_filter == NotificationCategory.all) return _groups;
    return _groups
        .map((g) => NotificationDateGroup(
            label: g.label,
            items: g.items.where((n) => n.category == _filter).toList()))
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  void _markAllRead() {
    setState(() {
      _groups = _groups
          .map((g) => NotificationDateGroup(
                label: g.label,
                items: g.items.map((n) => n.unread ? _withRead(n) : n).toList(),
              ))
          .toList();
    });
  }

  NotificationEntry _withRead(NotificationEntry n) => NotificationEntry(
        id: n.id,
        category: n.category,
        variant: n.variant,
        title: n.title,
        body: n.body,
        time: n.time,
        emoji: n.emoji,
        unread: false,
        mealTitle: n.mealTitle,
        mealCalories: n.mealCalories,
        mealProteinG: n.mealProteinG,
        mealCarbsG: n.mealCarbsG,
        specialistName: n.specialistName,
        statLabel: n.statLabel,
        statValue: n.statValue,
        statusLabel: n.statusLabel,
        statusDone: n.statusDone,
        syncPercent: n.syncPercent,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'التنبيهات'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: _markAllRead,
                          child: ButtonShine(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Text('تحديد الكل كمقروء',
                                  style: AppTextStyles.pillLabel),
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (_unreadCount > 0)
                        Row(children: [
                          Text('لديك $_unreadCount إشعارات جديدة',
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
                          final bool active = c == _filter;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: ButtonShine(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Text(c == NotificationCategory.all
                                      ? 'الكل'
                                      : '${c.label} ${_emojiFor(c)}'),
                                ),
                              ),
                              selected: active,
                              onSelected: (_) => setState(() => _filter = c),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.chipInactiveBg,
                              labelStyle: AppTextStyles.caption.copyWith(
                                  color: active
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
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
                  for (final group in _visibleGroups) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(group.label,
                          style: AppTextStyles.sectionHeading),
                    ),
                    for (final n in group.items)
                      _NotificationReveal(
                        key: ValueKey(n.id),
                        child: _NotificationCard(entry: n),
                      ),
                  ],
                  if (_visibleGroups.isEmpty) const _EmptyFilterState(),
                  const SizedBox(height: 8),
                  const _TipsFooterCard(),
                ],
              ),
            ),
          ],
        ),
      ),
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
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('كل جديدك في مكان واحد', style: AppTextStyles.cardTitle),
              SizedBox(height: 4),
              Text('تحديثات خطتك وتذكيراتك الصحية',
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
  const _NotificationCard({required this.entry});

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
                  padding: const EdgeInsets.only(top: 6, left: 6),
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
          _buildVariantBody(),
          const SizedBox(height: 10),
          Row(children: [
            if (entry.variant == NotificationVariant.mealPreview)
              _LogNowButton()
            else if (entry.statusDone == true)
              const Row(children: [
                Icon(Icons.check_circle_rounded,
                    size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text('مقروء', style: AppTextStyles.caption)
              ])
            else
              const SizedBox.shrink(),
            const Spacer(),
            Row(children: [
              Text(entry.time, style: AppTextStyles.caption),
              const SizedBox(width: 4),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppColors.textSecondary),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _buildVariantBody() {
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
                        'بروتين ${entry.mealProteinG} جم  •  كربوهيدرات ${entry.mealCarbsG} جم',
                        style: AppTextStyles.caption),
                  ]),
            ),
          ]),
        );
      case NotificationVariant.specialistNote:
        return _StatRow(
            icon: Icons.local_drink_outlined,
            badge: 'تحديث سريري',
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
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 10)),
        ),
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
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_task_rounded, size: 14, color: Colors.white),
              SizedBox(width: 6),
              Text('تسجيل الآن',
                  style: TextStyle(
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
        const Text('لا توجد إشعارات في هذا التصنيف حالياً',
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
        child: const Row(children: [
          Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('تنبيهاتك مخصصة لراحتك', style: AppTextStyles.cardTitle),
                SizedBox(width: 8),
                Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
              ]),
              SizedBox(height: 4),
              Text('يمكنك تعديل أوقات الوجبات من الإعدادات',
                  style: AppTextStyles.caption, textAlign: TextAlign.right),
            ]),
          ),
        ]),
      ),
    );
  }
}
