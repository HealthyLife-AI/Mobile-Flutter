import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

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

  static const List<_Achievement> _items = [
    _Achievement('أسبوع كامل من الالتزام', Icons.local_fire_department_rounded, true),
    _Achievement('7 أيام تسجيل متواصل', Icons.verified_rounded, true),
    _Achievement('أول وجبة مسجّلة', Icons.emoji_events_rounded, true),
    _Achievement('شرب الماء بانتظام', Icons.water_drop_rounded, false),
    _Achievement('30 يوم التزام', Icons.military_tech_rounded, false),
    _Achievement('هدف الوزن الأول', Icons.flag_rounded, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'إنجازاتك'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
          children: [
            const Align(alignment: AlignmentDirectional.centerStart, child: Text('استمري، كل خطوة صغيرة تُحسب', style: AppTextStyles.secondary)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) => _AchievementCard(item: _items[i], delay: Duration(milliseconds: i * 90)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatefulWidget {
  final _Achievement item;
  final Duration delay;
  const _AchievementCard({required this.item, required this.delay});

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

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
              scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, child) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: earned ? AppColors.accentGreenBg : AppColors.chipInactiveBg,
                    shape: BoxShape.circle,
                    boxShadow: earned
                        ? [BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.25 * (1 - _c.value) + 0.05), blurRadius: 16)]
                        : null,
                  ),
                  child: child,
                ),
                child: Icon(widget.item.icon, color: earned ? AppColors.accentGreen : AppColors.textSecondary, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.item.title, textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
