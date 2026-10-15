import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/measurement_entities.dart';

/// WeightTrendChart — line chart distinguishing clinic-verified readings
/// (ring marker) from self-reported home readings (solid dot), per the
/// Mobile API Reference's BR-13 requirement to show `source` visually.
class WeightTrendChart extends StatelessWidget {
  final List<WeightPoint> points;
  const WeightTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(
        size: Size.infinite,
        painter: _WeightChartPainter(points),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightPoint> points;
  _WeightChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final values = points.map((p) => p.kg).toList();
    final maxV = values.reduce((a, b) => a > b ? a : b) + 2;
    final minV = values.reduce((a, b) => a < b ? a : b) - 2;
    final range = (maxV - minV).clamp(1, double.infinity);

    const leftPad = 34.0;
    const rightPad = 8.0;
    const topPad = 8.0;
    const bottomPad = 8.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Gridlines + labels (78 / 80 / 82 style ticks).
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const labelStyle = TextStyle(color: AppColors.textSecondary, fontSize: 11);
    const ticks = 3;
    for (int i = 0; i <= ticks; i++) {
      final v = minV + (range * i / ticks);
      final y = topPad + chartH - (chartH * i / ticks);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width - rightPad, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: v.round().toString(), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    Offset pointOffset(int i) {
      final x =
          leftPad + chartW * i / (points.length - 1).clamp(1, double.infinity);
      final y = topPad + chartH - (chartH * (points[i].kg - minV) / range);
      return Offset(x, y);
    }

    // Filled area under the line.
    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      final o = pointOffset(i);
      if (i == 0) {
        fillPath.moveTo(o.dx, o.dy);
      } else {
        fillPath.lineTo(o.dx, o.dy);
      }
    }
    fillPath.lineTo(pointOffset(points.length - 1).dx, topPad + chartH);
    fillPath.lineTo(pointOffset(0).dx, topPad + chartH);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.primary.withValues(alpha: 0.0)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH)),
    );

    // The line itself.
    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      final o = pointOffset(i);
      if (i == 0) {
        linePath.moveTo(o.dx, o.dy);
      } else {
        linePath.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Markers: solid dot (home) vs ring (clinic-verified).
    for (int i = 0; i < points.length; i++) {
      final o = pointOffset(i);
      if (points[i].clinicVerified) {
        canvas.drawCircle(o, 7, Paint()..color = AppColors.surface);
        canvas.drawCircle(
            o,
            7,
            Paint()
              ..color = AppColors.primary
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
        canvas.drawCircle(o, 2.5, Paint()..color = AppColors.primary);
      } else {
        canvas.drawCircle(o, 4.5, Paint()..color = AppColors.primary);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
