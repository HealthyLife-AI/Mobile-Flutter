// ignore_for_file: unused_import
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../models/meal_models.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/metric_stat_box.dart' show AnimatedNumberCounter;
import '../widgets/substitution_badges.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/meal_card.dart' show mealSlotIcon, mealSlotBg, mealSlotIconColor;
import 'meal_log_success_screen.dart';
import '../widgets/app_header_bar.dart';
import '../core/navigation/app_page_route.dart';

/// تفاصيل الوجبة — شريط الوجبة الحالية، بطاقة الاستبدال الذكي، بطاقة السعرات
/// والماكروز، ثم مجموعات المكونات والبدائل، وزر التسجيل.
///
/// الأنيميشن: ظهور متتابع للبطاقات، عدّاد سعرات يتحدّث مباشرة عند تبديل
/// صنف، لهب نابض، نقطة نبض، موجة عند الاختيار، قفل يهتزّ، وزر تسجيل بلمعة.
class MealDetailScreen extends StatefulWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> with TickerProviderStateMixin {
  // مفتاح المجموعة = عنوانها، والقيمة = فهرس الخيار المحدد (الافتراضي 0).
  final Map<String, int> _selected = {};

  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))..forward();
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  int _selectedIndex(FoodCategoryGroup g) =>
      ((_selected[g.title] ?? 0).clamp(0, g.options.length - 1)).toInt();

  /// إجمالي السعرات = سعرات الوجبة الأصلية + فرق كل بديل مختار.
  int _totalCalories(List<FoodCategoryGroup> groups) {
    var total = widget.meal.calories;
    for (final g in groups) {
      final original = g.options.firstWhere((o) => o.isOriginal, orElse: () => g.options.first);
      total += g.options[_selectedIndex(g)].calories - original.calories;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final groups = MockData.lunchDetailGroups;
    var i = 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'تفاصيل الوجبة'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _Reveal(
              anim: _intro,
              index: i++,
              child: _TopRow(mealName: meal.name, timeRange: meal.timeRange, loop: _loop),
            ),
            const SizedBox(height: 14),
            _Reveal(anim: _intro, index: i++, child: const _SmartSwapNotice()),
            const SizedBox(height: 14),
            _Reveal(
              anim: _intro,
              index: i++,
              child: _CaloriesCard(calories: _totalCalories(groups), loop: _loop),
            ),
            const SizedBox(height: 22),
            _Reveal(
              anim: _intro,
              index: i++,
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'مكونات الوجبة والبدائل',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionHeading,
                    ),
                  ),
                  const Spacer(),
                  Text('${groups.length} أصناف غذائية', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final group in groups)
              _Reveal(
                anim: _intro,
                index: i++,
                child: _CategoryGroupCard(
                  group: group,
                  selectedIndex: _selectedIndex(group),
                  onSelect: (idx) {
                    if (idx == _selectedIndex(group)) return;
                    HapticFeedback.selectionClick();
                    setState(() => _selected[group.title] = idx);
                  },
                ),
              ),
            const SizedBox(height: 6),
            _Reveal(
              anim: _intro,
              index: i++,
              child: _LogButton(
                loop: _loop,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final entry = MealLogStore.instance.recordPlanned(meal);
                  Navigator.of(context).push(AppPageRoute(builder: (_) => MealLogSuccessScreen(entry: entry)));
                },
              ),
            ),
            const SizedBox(height: 12),
            _Reveal(
              anim: _intro,
              index: i++,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _loop,
                    child: const Icon(Icons.autorenew_rounded, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  const Text('سيتم تحديث سجل اليوم ونسبة التزامك فوراً', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// ظهور متتابع: يتلاشى العنصر ويصعد قليلاً حسب ترتيبه
// ═════════════════════════════════════════════════════════════════════════
class _Reveal extends StatelessWidget {
  final Animation<double> anim;
  final int index;
  final Widget child;
  const _Reveal({required this.anim, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.06).clamp(0.0, 0.6).toDouble();
    final a = CurvedAnimation(parent: anim, curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(a),
        child: child,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// الصف العلوي: الوجبة الحالية (يمين) + اسم الوجبة (يسار)
// ═════════════════════════════════════════════════════════════════════════
class _TopRow extends StatelessWidget {
  final String mealName;
  final String timeRange;
  final Animation<double> loop;
  const _TopRow({required this.mealName, required this.timeRange, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(loop: loop),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'الوجبة الحالية • $timeRange',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(fontSize: 11.5, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            mealName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _PulseDot extends StatelessWidget {
  final Animation<double> loop;
  const _PulseDot({required this.loop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: AnimatedBuilder(
        animation: loop,
        builder: (_, __) {
          final t = loop.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 7 + 9 * t,
                height: 7 + 9 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: (1 - t) * 0.35),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// بطاقة الاستبدال الذكي
// ═════════════════════════════════════════════════════════════════════════
class _SmartSwapNotice extends StatelessWidget {
  const _SmartSwapNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SwapIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('مرونة الاستبدال الذكي', style: AppTextStyles.cardTitle),
                SizedBox(height: 6),
                Text(
                  'اختر البديل إذا لم يتوفر الصنف الأصلي، والبديل يستبدل الصنف ولا يُضاف إليه لتحقيق التوازن التغذوي الدقيق.',
                  style: TextStyle(fontSize: 11.5, height: 1.8, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// أيقونة التبديل: تدور نصف دورة عند الدخول، وتدور مجدداً عند الضغط عليها.
class _SwapIcon extends StatefulWidget {
  const _SwapIcon();

  @override
  State<_SwapIcon> createState() => _SwapIconState();
}

class _SwapIconState extends State<_SwapIcon> {
  double _turns = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _turns = 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _turns += 0.5),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(13)),
        child: AnimatedRotation(
          turns: _turns,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutBack,
          child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// بطاقة السعرات + الماكروز
// ═════════════════════════════════════════════════════════════════════════
class _CaloriesCard extends StatelessWidget {
  final int calories;
  final Animation<double> loop;
  const _CaloriesCard({required this.calories, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('إجمالي السعرات النشطة',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _CountText(
                          value: calories,
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.1),
                        ),
                        const SizedBox(width: 8),
                        const Text('سعرة حرارية', style: AppTextStyles.secondary),
                      ],
                    ),
                  ],
                ),
              ),
              _Flame(loop: loop),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Color(0xFFD5F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF12B886)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'وجبة متوازنة معتمدة من أ. خلود العربي (أخصائية التغذية)',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _MacroBox(label: 'البروتين', grams: 43, order: 0)),
              SizedBox(width: 10),
              Expanded(child: _MacroBox(label: 'الكارب', grams: 38, order: 1)),
              SizedBox(width: 10),
              Expanded(child: _MacroBox(label: 'الدهون الصحية', grams: 14, order: 2)),
            ],
          ),
        ],
      ),
    );
  }
}

/// رقم يعدّ تصاعدياً عند الظهور، ويتحرك بسلاسة من القيمة القديمة للجديدة.
class _CountText extends StatelessWidget {
  final int value;
  final TextStyle style;
  const _CountText({required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(v.round().toString(), style: style),
    );
  }
}

/// لهب نابض بوهج خفيف وميلان بسيط يشبه الاشتعال.
class _Flame extends StatelessWidget {
  final Animation<double> loop;
  const _Flame({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (_, __) {
        final s = 0.5 - 0.5 * math.cos(loop.value * 2 * math.pi);
        return Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.06 + 0.12 * s), blurRadius: 16 + 10 * s),
            ],
          ),
          child: Transform.rotate(
            angle: math.sin(loop.value * 4 * math.pi) * 0.05,
            child: Transform.scale(
              scale: 1 + 0.09 * s,
              child: const Icon(Icons.local_fire_department_outlined, size: 36, color: AppColors.primary),
            ),
          ),
        );
      },
    );
  }
}

/// مربع ماكرو: يظهر بقفزة خفيفة ويعدّ قيمته تصاعدياً.
class _MacroBox extends StatelessWidget {
  final String label;
  final int grams;
  final int order;
  const _MacroBox({required this.label, required this.grams, required this.order});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + order * 150),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0).toDouble(),
        child: Transform.scale(scale: 0.85 + 0.15 * v, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(color: const Color(0xFFF4F6FD), borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(child: Text(label, maxLines: 1, style: AppTextStyles.caption.copyWith(fontSize: 11.5))),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: grams.toDouble()),
              duration: Duration(milliseconds: 900 + order * 150),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text(
                '${v.round()} غ',
                style: AppTextStyles.caption.copyWith(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// مجموعة صنف (بروتين / نشويات / خضار)
// ═════════════════════════════════════════════════════════════════════════
class _CategoryGroupCard extends StatelessWidget {
  final FoodCategoryGroup group;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryGroupCard({required this.group, required this.selectedIndex, required this.onSelect});

  static const Color _green = Color(0xFF34D3A5);

  @override
  Widget build(BuildContext context) {
    final bool locked = group.options.length == 1 && group.options.first.locked;
    final original = group.options.firstWhere((o) => o.isOriginal, orElse: () => group.options.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: locked ? _green : AppColors.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              if (locked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('صنف أساسي بدون بديل',
                          style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.check_circle_outline_rounded, size: 13, color: Colors.white),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('اختر صنفاً واحداً', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < group.options.length; i++)
            _OptionTile(
              option: group.options[i],
              selected: locked || i == selectedIndex,
              calorieDelta: group.options[i].calories - original.calories,
              replacesName: original.name,
              onTap: locked ? null : () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final FoodOption option;
  final bool selected;
  final int calorieDelta;
  final String replacesName;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.calorieDelta,
    required this.replacesName,
    this.onTap,
  });

  static String _short(String name) => name.split(' ').take(2).join(' ');

  @override
  Widget build(BuildContext context) {
    final bool original = option.isOriginal;
    final bool locked = option.locked;
    final bool hasDesc = locked && option.macroLabel.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F7FD) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.35) : AppColors.hairline,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: _FoodThumb(option: option),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(option.name,
                          style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                      if (original && !locked)
                        _pill('الصنف المجدول الأصلي', filled: true)
                      else if (!original && !locked)
                        _pill('يستبدل ${_short(replacesName)}', filled: false),
                    ],
                  ),
                  if (hasDesc) ...[
                    const SizedBox(height: 4),
                    Text(option.macroLabel, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.caption.copyWith(fontSize: 11.5),
                      children: [
                        TextSpan(
                          text: '${option.grams} غرام',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: '  •  '),
                        TextSpan(text: '${option.calories} سعرة حرارية'),
                        if (!original && !locked && calorieDelta != 0)
                          TextSpan(text: ' (${calorieDelta > 0 ? '+' : '-'}${calorieDelta.abs()})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _RadioMark(selected: selected, locked: locked),
          ],
        ),
      ),
    );
  }

  static Widget _pill(String text, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: filled ? null : Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: filled ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// صورة الصنف. استبدلي الأيقونة بـ Image.asset / Image.network عندما تتوفر
/// صورة في موديل FoodOption.
class _FoodThumb extends StatelessWidget {
  final FoodOption option;
  const _FoodThumb({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFF1DC), Color(0xFFF6D3A6)],
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(categoryIcon(option), size: 28, color: const Color(0xFFD9822B)),
    );
  }
}

/// دائرة الاختيار: قفزة مرنة للعلامة + موجة تتسع عند الاختيار، وقفل يهتزّ.
class _RadioMark extends StatefulWidget {
  final bool selected;
  final bool locked;
  const _RadioMark({required this.selected, required this.locked});

  @override
  State<_RadioMark> createState() => _RadioMarkState();
}

class _RadioMarkState extends State<_RadioMark> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void didUpdateWidget(covariant _RadioMark old) {
    super.didUpdateWidget(old);
    if (!old.selected && widget.selected) _ripple.forward(from: 0);
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.selected || widget.locked;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _ripple,
            builder: (_, __) {
              final t = Curves.easeOutCubic.transform(_ripple.value);
              if (_ripple.value == 0 || _ripple.value == 1) return const SizedBox.shrink();
              return Container(
                width: 28 + 16 * t,
                height: 28 + 16 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: (1 - t) * 0.5), width: 2),
                ),
              );
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? AppColors.primary : const Color(0xFFEEF1FA),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: widget.locked
                  ? const _ShakingLock(key: ValueKey('lock'))
                  : (widget.selected
                      ? const Icon(Icons.check_rounded, key: ValueKey('check'), size: 17, color: Colors.white)
                      : const SizedBox.shrink(key: ValueKey('empty'))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShakingLock extends StatelessWidget {
  const _ShakingLock({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (_, v, child) => Transform.rotate(
        angle: math.sin(v * math.pi * 5) * (1 - v) * 0.4,
        child: child,
      ),
      child: const Icon(Icons.lock_rounded, size: 14, color: Colors.white),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// زر التسجيل: ضغط بتصغير خفيف + لمعة تمرّ كل بضع ثوانٍ
// ═════════════════════════════════════════════════════════════════════════
class _LogButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Animation<double> loop;
  const _LogButton({required this.onPressed, required this.loop});

  @override
  State<_LogButton> createState() => _LogButtonState();
}

class _LogButtonState extends State<_LogButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: ColoredBox(color: AppColors.primary)),
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: widget.loop,
                    builder: (_, __) {
                      final t = (widget.loop.value / 0.5).clamp(0.0, 1.0).toDouble();
                      return Align(
                        alignment: Alignment(-1.6 + 3.2 * t, 0),
                        child: FractionallySizedBox(
                          widthFactor: 0.3,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('سجّلت هذه الوجبة الآن',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(width: 10),
                    Icon(Icons.check_circle_outline_rounded, size: 22, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// عناصر عامة محفوظة كما كانت (قد تُستخدم في شاشات أخرى)
// ═════════════════════════════════════════════════════════════════════════

/// One macronutrient: tinted glyph above the value and the label.
class MacroTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color tintBg;

  const MacroTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.tintBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(color: tintBg.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(label, maxLines: 1, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// Per-option food glyph — derived from the option's macro label (and, as a
/// fallback, the food name).
IconData categoryIcon(FoodOption option) {
  final label = '${option.macroLabel} ${option.name}';
  if (label.contains('بروتين')) return Icons.set_meal_outlined;
  if (label.contains('كارب') || label.contains('نشويات')) return Icons.bakery_dining_outlined;
  if (label.contains('دهون')) return Icons.water_drop_outlined;
  if (label.contains('فاكهة')) return Icons.apple_rounded;
  if (label.contains('خضار') || label.contains('ألياف')) return Icons.eco_outlined;
  return Icons.restaurant_menu_rounded;
}