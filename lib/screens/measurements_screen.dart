import 'package:flutter/material.dart';
import 'package:healthylife_ai/screens/new_measurement_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../models/measurement_models.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/weight_trend_chart.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/app_header_bar.dart';
import '../core/navigation/app_page_route.dart';

/// Weight & Body Measurements Tracker (Additional Screens table) — current
/// weight + delta, a time-range-filterable trend chart distinguishing
/// clinic-verified vs self-reported points, a body-circumference grid, and
/// a logging-streak card.
class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  int _range = 0; // الكل | 30 يوم | 90 يوم

  @override
  Widget build(BuildContext context) {
    final points = MeasurementMockData.weightTrend;
    const delta = MeasurementMockData.currentWeight - MeasurementMockData.previousWeight;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'الوزن ومحيط الجسم'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                  Spacer(),
                  Text('الجمعة، 19 سبتمبر 2025', style: AppTextStyles.caption),
                  SizedBox(width: 6),
                  Text('الوزن الحالي', style: AppTextStyles.cardTitle),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${MeasurementMockData.currentWeight}', style: AppTextStyles.metricLarge.copyWith(fontSize: 40)),
                    const Padding(padding: EdgeInsets.only(bottom: 6, right: 6), child: Text('كغ', style: AppTextStyles.secondary)),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(delta < 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('${delta.toStringAsFixed(1)} كغ مقارنة بآخر قياس', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('تم التحقق أثناء زيارة العيادة مع الأخصائية خلود', style: AppTextStyles.caption),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SegmentedSlidingTabs(tabs: const ['الكل', '30 يوم', '90 يوم'], selectedIndex: _range, onChanged: (i) => setState(() => _range = i)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: const Text('انسيابي ومستقر', style: AppTextStyles.caption),
                  ),
                  const Spacer(),
                  const Text('مسار التغيير', style: AppTextStyles.cardTitle),
                ]),
                const SizedBox(height: 12),
                WeightTrendChart(points: points),
                const SizedBox(height: 10),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _Legend(ring: true, label: 'قياس العيادة (معتمد)'),
                  SizedBox(width: 18),
                  _Legend(ring: false, label: 'قياس منزلي'),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
                  child: const Row(children: [
                    Icon(Icons.sync_alt_rounded, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('تحديث البيانات متزامن مع قياسات العيادة وسجلك الشخصي بكل موثوقية.',
                          textAlign: TextAlign.right, style: AppTextStyles.caption),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Row(children: [
            Text('آخر تحديث: 19 سبتمبر', style: AppTextStyles.caption),
            Spacer(),
            Text('محيط الجسم', style: AppTextStyles.sectionHeading),
          ]),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [for (final s in MeasurementMockData.circumference) _CircumferenceCard(stat: s)],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: const Text('خطوة مستمرة', style: AppTextStyles.caption),
                  ),
                  const Spacer(),
                  const Text('الالتزام بالتسجيل', style: AppTextStyles.cardTitle),
                ]),
                const SizedBox(height: 12),
                const Row(children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('سجّلتِ ${MeasurementMockData.daysLoggedThisWeek} أيام من 7 أيام هذا الأسبوع',
                            textAlign: TextAlign.right, style: AppTextStyles.body),
                        Text('(إجمالي ${MeasurementMockData.daysLoggedThisMonth} يوماً مسجلاً هذا الشهر)',
                            textAlign: TextAlign.right, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                const Row(children: [
                  Icon(Icons.eco_rounded, size: 16, color: AppColors.accentGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تسجيلك المنتظم يمكّن أخصائيتك من تحليل نمطك بدقة ودعمك بالخيارات الأنسب دون أي ضغط أو تسرّع.',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GradientCtaButton(
            label: 'سجّل قياساتك اليومية',
            icon: Icons.add_rounded,
            onPressed: () => Navigator.of(context).push(
              AppPageRoute(
                builder: (_) => MeasurementEntryScreen(
                  onSaved: () => setState(() {}),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool ring;
  final String label;
  const _Legend({required this.ring, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (ring)
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
        )
      else
        Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: AppTextStyles.caption),
    ]);
  }
}

class _CircumferenceCard extends StatelessWidget {
  final CircumferenceStat stat;
  const _CircumferenceCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final bool improving = (stat.deltaCm ?? 0) < 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Spacer(),
            Text(stat.label, style: AppTextStyles.caption),
            const SizedBox(width: 6),
            const Icon(Icons.straighten_rounded, size: 14, color: AppColors.textSecondary),
          ]),
          const SizedBox(height: 6),
          Text('${stat.valueCm.toStringAsFixed(stat.valueCm.truncateToDouble() == stat.valueCm ? 0 : 1)} سم', style: AppTextStyles.metricMedium),
          const SizedBox(height: 4),
          if (stat.deltaCm == null || stat.deltaCm == 0)
            const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('ثابت ومستقر', style: AppTextStyles.caption),
              SizedBox(width: 4),
              Text('—', style: AppTextStyles.caption),
            ])
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${stat.deltaCm} سم', style: AppTextStyles.caption.copyWith(color: improving ? AppColors.primary : AppColors.accentOrange)),
              const SizedBox(width: 4),
              Icon(improving ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 12, color: improving ? AppColors.primary : AppColors.accentOrange),
            ]),
        ],
      ),
    );
  }
}
