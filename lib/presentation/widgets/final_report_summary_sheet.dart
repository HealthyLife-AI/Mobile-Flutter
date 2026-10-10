import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class _FinalStat {
  final String value;
  final String label;
  final IconData icon;
  const _FinalStat(this.value, this.label, this.icon);
}

/// "ملخص التقرير النهائي للمتابعة" — a read-only recap shown when a
/// patient's clinical follow-up period has ended, so they have something
/// concrete to look back on before renewing.
class FinalReportSummarySheet extends StatelessWidget {
  const FinalReportSummarySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FinalReportSummarySheet(),
    );
  }

  static const List<_FinalStat> _stats = [
    _FinalStat('12', 'أسبوع متابعة', Icons.calendar_month_rounded),
    _FinalStat('88%', 'الالتزام بالوجبات', Icons.restaurant_rounded),
    _FinalStat('62%', 'من الهدف الاستراتيجي', Icons.flag_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.pill))),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                children: [
                  const Text('ملخص التقرير النهائي للمتابعة', style: AppTextStyles.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  const Text('من 3 أغسطس إلى 27 أكتوبر 2025', textAlign: TextAlign.center, style: AppTextStyles.caption),
                  const SizedBox(height: 20),
                  Row(
                    children: _stats
                        .map((s) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                                child: Column(children: [
                                  Icon(s.icon, color: AppColors.primary, size: 20),
                                  const SizedBox(height: 8),
                                  Text(s.value, style: AppTextStyles.metricLarge.copyWith(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(s.label, style: AppTextStyles.caption, textAlign: TextAlign.center),
                                ]),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 34, height: 34, decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 16)),
                        const SizedBox(width: 10),
                        const Text('ملاحظة ختامية من د. خلود العربي', style: AppTextStyles.cardTitle),
                      ]),
                      const SizedBox(height: 10),
                      const Text(
                        'أداء ممتاز خلال هذه المتابعة، وصلتِ إلى 62% من هدفك الاستراتيجي بانضباط لافت. أنصح باستكمال المرحلة القادمة لترسيخ العادات المكتسبة والوصول للهدف كاملاً.',
                        style: AppTextStyles.caption,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      label: const Text('إغلاق', style: AppTextStyles.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
