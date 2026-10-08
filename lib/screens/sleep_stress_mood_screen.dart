import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/pulsing_breathing_button.dart';
import '../widgets/app_header_bar.dart';

/// Sleep / Stress / Mood Tracking — circular gauge/donut in primary/
/// accentPurple, a breathing card in the breathingGradient pattern + M9.
class SleepStressMoodScreen extends StatelessWidget {
  const SleepStressMoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'النوم والإجهاد والمزاج'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              children: [
                const Text('جودة نومك الليلة الماضية', style: AppTextStyles.cardTitle),
                const SizedBox(height: 18),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(size: const Size(160, 160), painter: _DonutPainter(0.78, AppColors.primary)),
                      const Column(
                        children: [
                          Text('7.8', style: AppTextStyles.metricLarge),
                          Text('ساعات', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('نوم جيد — استمري على نفس الروتين', style: AppTextStyles.secondary),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              children: [
                const Text('مستوى الإجهاد', style: AppTextStyles.cardTitle),
                const SizedBox(height: 18),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(size: const Size(160, 160), painter: _DonutPainter(0.35, AppColors.accentPurple)),
                      const Column(
                        children: [
                          Text('35%', style: AppTextStyles.metricLarge),
                          Text('منخفض', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.breathingGradient, borderRadius: BorderRadius.circular(AppRadius.card)),
            child: Column(
              children: [
                const Text('لحظة تنفّس', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                Theme(
                  data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white)),
                  child: const PulsingBreathingButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double value;
  final Color color;
  _DonutPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final bgPaint = Paint()
      ..color = AppColors.chipInactiveBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * value, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
