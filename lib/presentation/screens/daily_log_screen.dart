import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../data/mock/meal_mock_data.dart';
import '../../data/repositories/meal_log_store.dart';
import 'log_meal_intro_screen.dart';
import 'meal_detail_screen.dart';
import 'weekly_plan_screen.dart';

const int _dailyGoal = 1800;
const Color _mutedIcon = Color(0xFF475467);

/// true = أرقام عربية-هندية (١٢٤٠) زي التصميم. اجعليها false لو بدك 1240.
const bool _kArabicIndicDigits = true;

String _d(Object v) {
  final s = '$v';
  if (!_kArabicIndicDigits) return s;
  const west = '0123456789';
  const east = '٠١٢٣٤٥٦٧٨٩';
  return s.split('').map((c) {
    final i = west.indexOf(c);
    return i == -1 ? c : east[i];
  }).join();
}

String _fmt(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// نص الوجبات بالمفرد/المثنى/الجمع الصحيح.
String _mealsLabel(int n) {
  if (n == 1) return 'وجبة واحدة';
  if (n == 2) return 'وجبتان';
  return '${_d(n)} وجبات';
}

bool _reduceMotion(BuildContext context) => MediaQuery.of(context).disableAnimations;

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  final Set<String> _removed = {};
  bool _previewEmpty = false;

  /// الوجبات الموجودة أول ما فتحت الشاشة: هذول بس بيدخلوا بتتابع،
  /// أي وجبة بتنضاف بعدين بتظهر فوراً بدون تأخير.
  Set<String>? _initialIds;

  void _openWeeklyPlan() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const WeeklyPlanScreen()));
  }

  void _openMeal(Meal meal) {
    Navigator.of(context).push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
  }

  void _onAddMeal() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const LogMealIntroScreen()));
  }

  void _delete(_LogItem item) {
    HapticFeedback.lightImpact();
    setState(() => _removed.add(item.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('تم حذف الوجبة من سجل اليوم'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 100),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () => setState(() => _removed.remove(item.id)),
          ),
        ),
      );
  }

  List<_LogItem> _collectItems() {
    final entries = MealLogStore.instance.entries;
    final loggedPlanIds = entries.map((e) => e.plannedMeal?.id).whereType<String>().toSet();

    final planned = MockData.todayMeals
        .where((m) => m.status == MealStatus.logged || loggedPlanIds.contains(m.id))
        .map((m) => _LogItem(id: m.id, name: m.name, calories: m.calories, time: m.timeRange, meal: m));

    final added = entries
        .where((e) => e.plannedMeal != null && !MockData.todayMeals.any((m) => m.id == e.plannedMeal!.id))
        .map((e) => e.plannedMeal!)
        .map((m) => _LogItem(id: m.id, name: m.name, calories: m.calories, time: m.timeRange, meal: m));

    final offPlanList = entries.where((e) => e.isOffPlan).toList().reversed.toList();
    final off = <_LogItem>[
      for (var i = 0; i < offPlanList.length; i++)
        _LogItem(
          id: 'off-$i-${offPlanList[i].name}',
          name: offPlanList[i].name,
          calories: offPlanList[i].calories,
          grams: offPlanList[i].grams,
          offPlan: true,
        ),
    ];

    return [...planned, ...added, ...off];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: MealLogStore.instance,
          builder: (context, _) {
            final items = _collectItems();
            _initialIds ??= items.map((i) => i.id).toSet();

            final active = items.where((i) => !_removed.contains(i.id)).toList();
            final calories = active.fold<int>(0, (t, i) => t + i.calories);
            final count = active.length;
            final showEmpty = _previewEmpty || count == 0;
            final latestId = active.isEmpty ? null : active.last.id;

            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
              children: [
                _FadeSlide(delayMs: 0, dy: -16, child: _Header(onCalendar: _openWeeklyPlan)),
                const SizedBox(height: 16),
                _FadeSlide(
                  delayMs: 120,
                  child: _SummaryCard(count: count, calories: calories, goal: _dailyGoal),
                ),
                const SizedBox(height: 22),
                _FadeSlide(
                  delayMs: 240,
                  child: _SectionHeader(
                    previewEmpty: _previewEmpty,
                    onTogglePreview: () {
                      HapticFeedback.selectionClick();
                      setState(() => _previewEmpty = !_previewEmpty);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: showEmpty
                      ? const _EmptyState(key: ValueKey('empty'))
                      : Column(
                          key: const ValueKey('list'),
                          children: [
                            for (var i = 0; i < items.length; i++)
                              _FadeSlide(
                                key: ValueKey(items[i].id),
                                delayMs: _initialIds!.contains(items[i].id) ? 340 + math.min(i, 5) * 100 : 0,
                                child: _CollapsibleCard(
                                  removed: _removed.contains(items[i].id),
                                  child: _TimelineCard(
                                    item: items[i],
                                    isLatest: items[i].id == latestId,
                                    onTap: items[i].meal == null ? null : () => _openMeal(items[i].meal!),
                                    onDelete: () => _delete(items[i]),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 4),
                _FadeSlide(delayMs: 700, child: const _ReminderCard()),
                const SizedBox(height: 16),
                _FadeSlide(delayMs: 820, child: _AddMealButton(onTap: _onAddMeal)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────────── Data ─────────────────────────────

class _LogItem {
  final String id;
  final String name;
  final int calories;
  final int? grams;
  final String? time;
  final bool offPlan;
  final Meal? meal;

  const _LogItem({
    required this.id,
    required this.name,
    required this.calories,
    this.grams,
    this.time,
    this.offPlan = false,
    this.meal,
  });
}

// ───────────────────────────── Header ─────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onCalendar;
  const _Header({required this.onCalendar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text('سجل اليوم', style: AppTextStyles.cardTitle),
        const Spacer(),
        _HeaderIcon(icon: Icons.notifications_none_rounded, onTap: () {}, tooltip: 'الإشعارات'),
        const SizedBox(width: 4),
        _HeaderIcon(icon: Icons.calendar_month_outlined, onTap: onCalendar, tooltip: 'استعراض الخطة الأسبوعية'),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _HeaderIcon({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: _PressableScale(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Summary card ─────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int count;
  final int calories;
  final int goal;
  const _SummaryCard({required this.count, required this.calories, required this.goal});

  @override
  Widget build(BuildContext context) {
    final percent = (calories / goal * 100).round();
    final progress = (calories / goal).clamp(0.0, 1.0).toDouble();
    final over = calories > goal;
    final accent = over ? AppColors.accentOrange : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('اليوم النشط', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(_d('الأحد، 21 سبتمبر 2025'), style: AppTextStyles.h1),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.event_available_rounded, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.restaurant_rounded,
                  filled: false,
                  label: 'الوجبات المسجلة',
                  value: count.toDouble(),
                  format: _mealsLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  filled: true,
                  label: 'مجموع الطاقة المستهلكة',
                  value: calories.toDouble(),
                  format: (n) => '${_d(_fmt(n))} سعرة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.eco_outlined, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  over ? 'تجاوزت الهدف بـ ${_d(_fmt(calories - goal))} سعرة' : 'توازن الطاقة اليومي المتزن',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ),
              const SizedBox(width: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent.toDouble()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text(
                  '${_d(v.round())}٪ من الموصى به',
                  style: AppTextStyles.caption.copyWith(color: accent, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _EnergyBar(progress: progress, color: accent),
          const SizedBox(height: 10),
          Text(
            over
                ? 'لا بأس، الأرقام مرشد هادئ وليست حكماً، وغداً يوم جديد.'
                : 'خياراتك اليوم متنوعة ومغذية، تذكّر أن الأرقام مرشد هادئ لدعم نشاطك وصحتك.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final String label;
  final double value;
  final String Function(int n) format;
  const _StatTile({
    required this.icon,
    required this.filled,
    required this.label,
    required this.value,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : AppColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: filled ? Colors.white : AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: _mutedIcon)),
                const SizedBox(height: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 1300),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(format(v.round()), maxLines: 1, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط التقدم: يمتلئ بحركة ناعمة + لمعة تمرّ فوقه (تتوقف لو المستخدم مفعّل تقليل الحركة).
class _EnergyBar extends StatefulWidget {
  final double progress;
  final Color color;
  const _EnergyBar({required this.progress, required this.color});

  @override
  State<_EnergyBar> createState() => _EnergyBarState();
}

class _EnergyBarState extends State<_EnergyBar> with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion(context)) {
      _shimmer.stop();
    } else if (!_shimmer.isAnimating) {
      _shimmer.repeat();
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.progress),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.primaryTint),
                FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: v.clamp(0.0, 1.0).toDouble(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _shimmer,
                        builder: (_, __) => Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(color: widget.color),
                            Align(
                              alignment: Alignment(-1.6 + 3.2 * _shimmer.value, 0),
                              child: FractionallySizedBox(
                                widthFactor: .35,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      Colors.white.withOpacity(0),
                                      Colors.white.withOpacity(.45),
                                      Colors.white.withOpacity(0),
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────────── Section header ─────────────────────────────

class _SectionHeader extends StatelessWidget {
  final bool previewEmpty;
  final VoidCallback onTogglePreview;
  const _SectionHeader({required this.previewEmpty, required this.onTogglePreview});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        // Title takes the leftover space and ellipsizes instead of pushing the
        // toggle pill past the right edge on narrow (320dp) screens.
        Expanded(
          child: Text(
            'التسلسل الزمني',
            style: AppTextStyles.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Semantics(
          button: true,
          toggled: previewEmpty,
          label: 'معاينة السجل الفارغ',
          child: _PressableScale(
            onTap: onTogglePreview,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: previewEmpty ? AppColors.primary : AppColors.primaryTint,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: Icon(
                      previewEmpty ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      key: ValueKey(previewEmpty),
                      size: 14,
                      color: previewEmpty ? Colors.white : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'معاينة السجل الفارغ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: previewEmpty ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────── Timeline card ─────────────────────────────

class _TimelineCard extends StatelessWidget {
  final _LogItem item;
  final bool isLatest;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  const _TimelineCard({required this.item, required this.isLatest, required this.onDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = item.offPlan ? AppColors.accentOrange : AppColors.primary;
    final accentBg = item.offPlan ? AppColors.accentOrangeBg : AppColors.primaryTint;
    final tagText = item.offPlan ? 'خارج الخطة • إضافة حرة' : 'من الخطة الغذائية';
    final tagIcon = item.offPlan ? Icons.add_circle_outline_rounded : Icons.check_circle_outline_rounded;

    return _PressableScale(
      onTap: onTap,
      pressedScale: .98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingIcon(
                  pulse: isLatest,
                  color: accent,
                  background: accentBg,
                  icon: item.offPlan ? Icons.restaurant_rounded : Icons.rice_bowl_rounded,
                ),
                if (item.time != null) ...[
                  const SizedBox(height: 6),
                  Text(_d(item.time!), style: const TextStyle(fontSize: 10, color: _mutedIcon)),
                ],
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tagIcon, size: 13, color: accent),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tagText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded, size: 14, color: accent),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${_d(item.calories)} سعرة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                      if (item.grams != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.scale_rounded, size: 14, color: _mutedIcon),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${_d(item.grams!)} غرام',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'حذف الوجبة',
              child: Tooltip(
                message: 'حذف الوجبة',
                child: _PressableScale(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(11),
                    child: Icon(Icons.delete_outline_rounded, size: 22, color: _mutedIcon),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// أيقونة الوجبة، وآخر وجبة مسجّلة تنبض بحلقة هادئة.
class _PulsingIcon extends StatefulWidget {
  final bool pulse;
  final Color color;
  final Color background;
  final IconData icon;
  const _PulsingIcon({required this.pulse, required this.color, required this.background, required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  void _sync() {
    final run = widget.pulse && !_reduceMotion(context);
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _PulsingIcon old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, __) {
                  final t = Curves.easeOut.transform(_c.value);
                  return Opacity(
                    opacity: (1 - t) * .5,
                    child: Container(
                      width: 44 + 8 * t,
                      height: 44 + 8 * t,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color, width: 2)),
                    ),
                  );
                },
              ),
            ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: widget.background, shape: BoxShape.circle),
            child: Icon(widget.icon, color: widget.color, size: 22),
          ),
        ],
      ),
    );
  }
}

/// عند الحذف: البطاقة تتلاشى وتنكمش بسلاسة (وترجع لو ضغطتي "تراجع").
class _CollapsibleCard extends StatelessWidget {
  final bool removed;
  final Widget child;
  const _CollapsibleCard({required this.removed, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 380),
      sizeCurve: Curves.easeInOutCubic,
      crossFadeState: removed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: child,
      secondChild: const SizedBox(width: double.infinity),
    );
  }
}

// ───────────────────────────── Reminder / empty / button ─────────────────────────────

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تذكير أخصائي التغذية', style: AppTextStyles.cardTitle),
                SizedBox(height: 6),
                Text(
                  'المرونة جزء أساسي من النجاح المستدام. تدوينك اليومي بصدق هو الخطوة الأهم لدعم رعايتك الذاتية.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.self_improvement_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, t, child) => Transform.scale(scale: t, child: child),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 30),
              ),
            ),
            const SizedBox(height: 12),
            const Text('لم تُسجّل أي وجبة بعد', style: AppTextStyles.secondary),
          ],
        ),
      ),
    );
  }
}

class _AddMealButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMealButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'تسجيل وجبة جديدة',
      child: _PressableScale(
        onTap: onTap,
        pressedScale: .96,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(.28), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('تسجيل وجبة جديدة', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Shared helpers ─────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );

/// ظهور تدريجي مع انزلاق، بتأخير يختلف لكل عنصر (stagger).
class _FadeSlide extends StatelessWidget {
  final int delayMs;
  final double dy;
  final Widget child;
  const _FadeSlide({super.key, required this.delayMs, required this.child, this.dy = 26});

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion(context)) return child;
    final total = delayMs + 650;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
      ),
    );
  }
}

/// ضغطة بتصغّر العنصر قليلاً ثم ترجعه (إحساس لمسي).
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const _PressableScale({required this.child, this.onTap, this.pressedScale = .88});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
