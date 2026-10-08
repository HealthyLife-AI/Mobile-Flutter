import 'package:flutter/material.dart';
import 'dart:math';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

/// LiveMetricCard — liveCardBg pattern + M7 continuous glowing chart loop + LIVE badge.
class LiveMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  const LiveMetricCard({super.key, required this.title, required this.value, required this.unit});

  @override
  State<LiveMetricCard> createState() => _LiveMetricCardState();
}

class _LiveMetricCardState extends State<LiveMetricCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.liveCardGradient, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.liveLineGlow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.liveLineGlow, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text('مباشر', style: TextStyle(color: AppColors.liveLineGlow, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
              const Spacer(),
              Text(widget.title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text(widget.value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.unit, style: const TextStyle(color: Colors.white54, fontSize: 12))),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(size: Size.infinite, painter: _LiveLinePainter(_c.value)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveLinePainter extends CustomPainter {
  final double t;
  _LiveLinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.liveLineGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final path = Path();
    const points = 40;
    for (int i = 0; i <= points; i++) {
      final x = size.width * i / points;
      final phase = (i / points) * 4 * pi + t * 2 * pi;
      final y = size.height / 2 + sin(phase) * (size.height / 2 - 4);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiveLinePainter oldDelegate) => true;
}
