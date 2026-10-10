import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class DayItem {
  final String weekday;
  final int dayNumber;
  final int calories;
  final bool isToday;
  // Days already logged/passed this week get a soft mint tint even when
  // not the selected day — matches the Figma weekly picker exactly.
  final bool completed;
  const DayItem({
    required this.weekday,
    required this.dayNumber,
    required this.calories,
    this.isToday = false,
    this.completed = false,
  });
}

/// DateChipPicker — horizontal day chips, active/inactive + M5 color
/// cross-fade (200ms) + auto-scroll so the selected chip centers itself
/// in the row (300ms ease), driven by Scrollable.ensureVisible so it
/// works regardless of each chip's rendered width.
class DateChipPicker extends StatefulWidget {
  final List<DayItem> days;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DateChipPicker({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<DateChipPicker> createState() => _DateChipPickerState();
}

class _DateChipPickerState extends State<DateChipPicker> {
  late List<GlobalKey> _keys = List.generate(widget.days.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant DateChipPicker old) {
    super.didUpdateWidget(old);
    if (old.days.length != widget.days.length) {
      _keys = List.generate(widget.days.length, (_) => GlobalKey());
    }
    if (old.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerSelected());
    }
  }

  void _centerSelected() {
    final ctx = _keys[widget.selectedIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: widget.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = widget.days[i];
          final bool selected = i == widget.selectedIndex;
          return GestureDetector(
            key: _keys[i],
            onTap: () => widget.onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : (d.completed ? AppColors.primarySoftBg : AppColors.chipInactiveBg),
                borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                border: d.isToday && !selected ? Border.all(color: AppColors.primary, width: 1.6) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.weekday,
                      style: AppTextStyles.caption.copyWith(color: selected ? Colors.white70 : AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text('${d.dayNumber}',
                      style: AppTextStyles.body.copyWith(
                          color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${d.calories} س',
                      style: AppTextStyles.caption.copyWith(color: selected ? Colors.white70 : AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
