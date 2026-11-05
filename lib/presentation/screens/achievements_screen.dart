import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/achievements.dart';
import '../../l10n/l10n.dart';
import '../bloc/health_profile/health_profile_cubit.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../bloc/measurements/measurements_cubit.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/spec_ui.dart';

/// "إنجازاتي" — milestones computed from what the patient really logged:
/// meals on this device, readings and the goal from the server. Nothing is
/// shown as earned that the data does not show.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HealthProfileCubit>(
      create: (context) => HealthProfileCubit(
          context.read<AppDependencies>().patientHealthProfile)
        ..load(),
      child: const _AchievementsView(),
    );
  }
}

class _AchievementsView extends StatelessWidget {
  const _AchievementsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meals = context.watch<MealLogCubit>().state.entries;
    final snapshot = context.watch<MeasurementsCubit>().state.snapshot;
    final goal = context.watch<HealthProfileCubit>().state.dataOrNull?.goal;
    final mealDays = [for (final e in meals) e.loggedAt];
    final achievements = computeAchievements(AchievementInputs(
      mealDays: mealDays,
      readingWeights: [
        for (final e in snapshot?.savedEntries ?? const [])
          if (e.weightKg case final kg?) kg,
      ],
      goalType: goal?.goalType,
      targetWeightKg: goal?.targetWeightKg,
    ));
    final sorted = [
      ...achievements.where((a) => a.earned),
      ...achievements.where((a) => !a.earned),
    ];
    final earned = achievements.where((a) => a.earned).length;
    final streak = currentStreak(mealDays);
    final best = bestStreak(mealDays);
    final gain = goal?.goalType == 'weight_gain';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: l10n.achievementsTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _Hero(earned: earned, total: achievements.length),
            const SizedBox(height: 14),
            _StreakCard(current: streak, best: best),
            const SizedBox(height: 18),
            SpecSectionTitle(l10n.achvSectionTitle,
                icon: Icons.workspace_premium_outlined),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final a in sorted)
                    SizedBox(
                        width: width,
                        child: _AchievementTile(achievement: a, gain: gain)),
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(l10n.achvFootnote, style: AppTextStyles.tiny)),
              ],
=======
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

import '../../l10n/l10n.dart';

class _Achievement {
  final String title;
  final IconData icon;
  final bool earned;
  const _Achievement(this.title, this.icon, this.earned);
}

/// Achievements / Streaks — grid of surface cards, M14 springy pulse on
/// a slot's first log (applied to the earned badge icon here).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static List<_Achievement> _items(AppLocalizations l10n) => [
        _Achievement(l10n.achievementsFullWeek,
            Icons.local_fire_department_rounded, true),
        _Achievement(
            l10n.achievementsSevenDayStreak, Icons.verified_rounded, true),
        _Achievement(
            l10n.achievementsFirstMeal, Icons.emoji_events_rounded, true),
        _Achievement(
            l10n.achievementsHydration, Icons.water_drop_rounded, false),
        _Achievement(
            l10n.achievementsThirtyDays, Icons.military_tech_rounded, false),
        _Achievement(
            l10n.achievementsFirstWeightGoal, Icons.flag_rounded, false),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _items(context.l10n);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.achievementsTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
          children: [
            Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(context.l10n.achievementsEncouragement,
                    style: AppTextStyles.secondary)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) => _AchievementCard(
                  item: items[i], delay: Duration(milliseconds: i * 90)),
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
            ),
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
class _Hero extends StatelessWidget {
  const _Hero({required this.earned, required this.total});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = total == 0 ? 0.0 : earned / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                const Center(
                  child: Icon(Icons.emoji_events_rounded,
                      color: Color(0xFFFFD166), size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    l10n.achvEarnedOf(context.localizeDigits(earned),
                        context.localizeDigits(total)),
                    style: AppTextStyles.sectionHeading
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    earned == 0
                        ? l10n.achvHeroStart
                        : earned == total
                            ? l10n.achvHeroAll
                            : l10n.achvHeroKeepGoing,
                    style: AppTextStyles.secondary.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current, required this.best});

  final int current;
  final int best;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SpecCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(AppRadius.panel),
            ),
            child: Icon(Icons.local_fire_department_rounded,
                color:
                    current > 0 ? const Color(0xFFEA580C) : AppColors.iconMuted,
                size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.achvStreakTitle, style: AppTextStyles.cardTitle),
                Text(
                    current == 0
                        ? l10n.achvStreakNone
                        : l10n.achvBestStreak(context.localizeDigits(best)),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          // No number until there is a streak: "٠" alone reads as a dot.
          if (current > 0)
            Column(
              children: [
                Text(context.localizeDigits(current),
                    style: AppTextStyles.metricLarge
                        .copyWith(color: const Color(0xFFEA580C), height: 1.1)),
                Text(l10n.achvDaysUnit(current), style: AppTextStyles.tiny),
              ],
            ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement, required this.gain});

  final Achievement achievement;
  final bool gain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = achievement;
    final (icon, color, title, body) = switch (a.kind) {
      AchievementKind.firstMeal => (
          Icons.restaurant_rounded,
          const Color(0xFF16A34A),
          l10n.achvFirstMeal,
          l10n.achvFirstMealBody
        ),
      AchievementKind.streak3 => (
          Icons.local_fire_department_rounded,
          const Color(0xFFEA580C),
          l10n.achvStreak3,
          l10n.achvStreak3Body
        ),
      AchievementKind.streak7 => (
          Icons.whatshot_rounded,
          const Color(0xFFDC2626),
          l10n.achvStreak7,
          l10n.achvStreak7Body
        ),
      AchievementKind.days30 => (
          Icons.calendar_month_rounded,
          const Color(0xFF7C3AED),
          l10n.achvDays30,
          l10n.achvDays30Body
        ),
      AchievementKind.firstReading => (
          Icons.monitor_weight_outlined,
          AppColors.primary,
          l10n.achvFirstReading,
          l10n.achvFirstReadingBody
        ),
      AchievementKind.fiveReadings => (
          Icons.straighten_rounded,
          const Color(0xFF0284C7),
          l10n.achvFiveReadings,
          l10n.achvFiveReadingsBody
        ),
      AchievementKind.firstKilos => (
          gain ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          AppColors.success,
          gain ? l10n.achvFirstKilosGain : l10n.achvFirstKilosLoss,
          l10n.achvFirstKilosBody
        ),
      AchievementKind.halfway => (
          Icons.flag_outlined,
          const Color(0xFFCA8A04),
          l10n.achvHalfway,
          l10n.achvHalfwayBody
        ),
      AchievementKind.goalReached => (
          Icons.emoji_events_rounded,
          const Color(0xFFCA8A04),
          l10n.achvGoalReached,
          l10n.achvGoalReachedBody
        ),
    };
    final kilos = a.kind == AchievementKind.firstKilos ||
        a.kind == AchievementKind.halfway ||
        a.kind == AchievementKind.goalReached;
    String amount(double v) => context
        .localizeDigits(kilos ? v.toStringAsFixed(1) : v.floor().toString());
    return Semantics(
      label: '$title. ${a.earned ? l10n.achvEarned : ''}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
              color:
                  a.earned ? color.withValues(alpha: 0.35) : AppColors.border),
          boxShadow: a.earned ? AppShadowsFor.earned(color) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: a.earned
                        ? color.withValues(alpha: 0.12)
                        : AppColors.chipInactiveBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.earned ? icon : Icons.lock_outline_rounded,
                      color: a.earned ? color : AppColors.iconMuted, size: 22),
                ),
                const Spacer(),
                if (a.earned) const StatusPill('✓', tone: PillTone.success),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: a.earned
                        ? AppColors.textPrimary
                        : AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(body,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted, height: 1.4)),
            if (!a.earned) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: a.progress,
                  minHeight: 6,
                  color: color,
                  backgroundColor: AppColors.chipInactiveBg,
                ),
              ),
              const SizedBox(height: 4),
              Text('${amount(a.current)} / ${amount(a.target)}',
                  style: AppTextStyles.tiny),
            ],
          ],
        ),
=======
class _AchievementCard extends StatefulWidget {
  final _Achievement item;
  final Duration delay;
  const _AchievementCard({required this.item, required this.delay});

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    if (widget.item.earned) {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earned = widget.item.earned;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: earned ? null : Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _c,
            child: ScaleTransition(
              // M21 (v2 correction): calm Scale+Fade (0.9→1.0) with a single
              // soft glow fading over 500ms — same "no confetti" philosophy
              // as the corrected M6, not a springy bounce.
              scale: Tween(begin: 0.9, end: 1.0)
                  .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, child) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: earned
                        ? AppColors.accentGreenBg
                        : AppColors.chipInactiveBg,
                    shape: BoxShape.circle,
                    boxShadow: earned
                        ? [
                            BoxShadow(
                                color: AppColors.accentGreen.withValues(
                                    alpha: 0.25 * (1 - _c.value) + 0.05),
                                blurRadius: 16)
                          ]
                        : null,
                  ),
                  child: child,
                ),
                child: Icon(widget.item.icon,
                    color: earned
                        ? AppColors.accentGreen
                        : AppColors.textSecondary,
                    size: 26),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.item.title,
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      ),
    );
  }
}
<<<<<<< HEAD

/// A soft glow in an earned achievement's own color.
abstract final class AppShadowsFor {
  static List<BoxShadow> earned(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
