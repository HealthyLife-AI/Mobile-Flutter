import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/meal_mock_data.dart';
import '../widgets/date_chip_picker.dart';
import '../widgets/meal_card.dart';
import '../widgets/metric_stat_box.dart';
import 'meal_detail_screen.dart';
import '../../core/navigation/app_page_route.dart';
import '../widgets/app_header_bar.dart';

/// 4.4 Weekly Plan — week picker, macro summary, meal-slot list.
class WeeklyPlanScreen extends StatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  int _selectedDay = 1;

  final List<DayItem> _days = const [
    DayItem(weekday: 'السبت', dayNumber: 20, calories: 1320, completed: true),
    DayItem(weekday: 'الأحد', dayNumber: 21, calories: 1350, isToday: true),
    DayItem(weekday: 'الإثنين', dayNumber: 22, calories: 1380),
    DayItem(weekday: 'الثلاثاء', dayNumber: 23, calories: 1350),
    DayItem(weekday: 'الأربعاء', dayNumber: 24, calories: 1400),
    DayItem(weekday: 'الخميس', dayNumber: 25, calories: 1380),
    DayItem(weekday: 'الجمعة', dayNumber: 26, calories: 1320),
  ];

  @override
  Widget build(BuildContext context) {
    const meals = MockData.todayMeals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'استعراض الخطة الأسبوعية'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          children: [
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.accentGreen),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('شاشة استعراض الخطة والتحضير المسبق', textAlign: TextAlign.right, style: AppTextStyles.cardTitle),
                          SizedBox(height: 4),
                          Text('لتسجيل الوجبات وتأكيد تناولها يرجى التوجه لتبويب خطتي اليومية',
                              textAlign: TextAlign.right, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Row(children: [
                    Icon(Icons.verified_rounded, color: AppColors.accentGreen, size: 14),
                    SizedBox(width: 4),
                    Text('الأسبوع الثالث', style: AppTextStyles.caption),
                  ]),
                ),
                const Spacer(),
                const Text('سبتمبر 2025', style: AppTextStyles.body),
              ],
            ),
            const SizedBox(height: 12),
            DateChipPicker(days: _days, selectedIndex: _selectedDay, onChanged: (i) => setState(() => _selectedDay = i)),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.accentGreenBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: const Row(children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 14),
                            SizedBox(width: 4),
                            Text('خطة غذائية مفصلة', style: AppTextStyles.caption),
                          ]),
                        ),
                        const Spacer(),
                        Text('خطة يوم ${_days[_selectedDay].weekday} • ${_days[_selectedDay].dayNumber} سبتمبر', style: AppTextStyles.body),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${_days[_selectedDay].calories}', style: AppTextStyles.metricLarge.copyWith(color: AppColors.primary)),
                        const SizedBox(width: 6),
                        const Padding(padding: EdgeInsets.only(top: 10), child: Text('سعرة حرارية', style: AppTextStyles.secondary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(children: [
                      MetricStatBox(label: 'دهون صحية', value: '42 غ'),
                      MetricStatBox(label: 'كربوهيدرات', value: '120 غ'),
                      MetricStatBox(label: 'بروتين', value: '105 غ'),
                    ]),
                    const SizedBox(height: 10),
                    const Text('خطة متوازنة لتعزيز الطاقة وحرق الدهون بإشراف أ. خلود العربي',
                        textAlign: TextAlign.right, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            for (final m in meals)
              MealCard(
                meal: m,
                enableHero: false,
                forceMealTypeColors: true,
                onLog: () => Navigator.of(context).push(AppPageRoute(builder: (_) => MealDetailScreen(meal: m))),
              ),
          ],
        ),
      ),
    );
  }
}
