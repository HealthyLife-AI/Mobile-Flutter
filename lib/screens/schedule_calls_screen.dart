import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/detail_hero_header.dart';
import '../widgets/date_chip_picker.dart';
import '../widgets/sticky_bottom_bar.dart';
import '../widgets/segmented_sliding_tabs.dart';
import '../widgets/gradient_cta_button.dart';

class _Appointment {
  final String title;
  final String date;
  final String time;
  final bool upcoming;
  final String statusLabel;
  final Color statusColor;
  const _Appointment(this.title, this.date, this.time, this.upcoming, this.statusLabel, this.statusColor);
}

/// Schedule / Accountability Calls — DetailHeroHeader (primaryDark panel +
/// white info sheet, M11), day picker (M5), sticky bottom bar (M12),
/// SegmentedSlidingTabs (Upcoming/Past).
class ScheduleCallsScreen extends StatefulWidget {
  const ScheduleCallsScreen({super.key});

  @override
  State<ScheduleCallsScreen> createState() => _ScheduleCallsScreenState();
}

class _ScheduleCallsScreenState extends State<ScheduleCallsScreen> {
  int _tab = 0;
  int _selectedDay = 2;

  final List<DayItem> _days = const [
    DayItem(weekday: 'الأحد', dayNumber: 28, calories: 0),
    DayItem(weekday: 'الإثنين', dayNumber: 29, calories: 0),
    DayItem(weekday: 'الثلاثاء', dayNumber: 30, calories: 0, isToday: true),
    DayItem(weekday: 'الأربعاء', dayNumber: 1, calories: 0),
    DayItem(weekday: 'الخميس', dayNumber: 2, calories: 0),
  ];

  final List<_Appointment> _upcoming = const [
    _Appointment('متابعة أسبوعية مع أ. خلود العربي', '30 سبتمبر', '05:00 م', true, 'خلال 3 أيام', AppColors.accentOrange),
    _Appointment('مراجعة نتائج القياسات', '3 أكتوبر', '11:00 ص', true, 'خلال 6 أيام', AppColors.primary),
  ];

  final List<_Appointment> _past = const [
    _Appointment('جلسة تعارف أولى', '10 سبتمبر', '04:00 م', false, 'مكتملة', AppColors.accentGreen),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _upcoming : _past;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DetailHeroHeader(
                  topPanelHeight: 180,
                  topPanelChild: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white)),
                      const Spacer(),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('المواعيد والمتابعة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          SizedBox(height: 6),
                          Text('مع أ. خلود العربي — أخصائية التغذية العلاجية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  sheetChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedSlidingTabs(tabs: const ['السابقة', 'القادمة'], selectedIndex: 1 - _tab, onChanged: (i) => setState(() => _tab = 1 - i)),
                      const SizedBox(height: 18),
                      const Align(alignment: AlignmentDirectional.centerStart, child: Text('اختاري يوماً للحجز', style: AppTextStyles.cardTitle)),
                      const SizedBox(height: 10),
                      DateChipPicker(days: _days, selectedIndex: _selectedDay, onChanged: (i) => setState(() => _selectedDay = i)),
                      const SizedBox(height: 20),
                      for (final a in list) _AppointmentCard(item: a),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StickyBottomBar(
            left: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppColors.chipInactiveBg, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            ),
            right: GradientCtaButton(label: 'حجز موعد جديد', icon: Icons.add_rounded, onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final _Appointment item;
  const _AppointmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(gradient: AppColors.primaryDarkGradient, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: Text(item.date.split(' ').first, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, textAlign: TextAlign.right, style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text('${item.date} • ${item.time}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: item.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text(item.statusLabel, style: AppTextStyles.caption.copyWith(color: item.statusColor)),
          ),
        ],
      ),
    );
  }
}
