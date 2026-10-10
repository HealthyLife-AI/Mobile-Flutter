import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/app_header_bar.dart';
import '../../core/navigation/app_page_route.dart';
import 'measurement_guide_screen.dart';

const _tintBox = Color(0xFFF3F6FC); // خلفية الصناديق الفاتحة في التصميم
const _iconBlue = Color(0xFFE3ECFA);
const _leafGreen = Color(0xFF1FB57A);

/// Shown once, right after the very first weight measurement is saved.
class FirstMeasurementScreen extends StatefulWidget {
  final double weightKg;
  final VoidCallback? onMeasurementSaved;
  final bool showBack;
  final bool showExitAction;
  final bool replaceEntryRoute;

  const FirstMeasurementScreen({
    super.key,
    this.weightKg = 78.4,
    this.onMeasurementSaved,
    this.showBack = true,
    this.showExitAction = true,
    this.replaceEntryRoute = true,
  });

  @override
  State<FirstMeasurementScreen> createState() => _FirstMeasurementScreenState();
}

class _FirstMeasurementScreenState extends State<FirstMeasurementScreen> with TickerProviderStateMixin {
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..forward();
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  static double _seg(double v, double b, double e, [Curve c = Curves.easeOutCubic]) =>
      Interval(b, e, curve: c).transform(v);

  /// دخول متتابع: تلاشي + انزلاق من الأسفل
  Widget _reveal(double b, double e, Widget child, {double dy = 26}) {
    return AnimatedBuilder(
      animation: _enter,
      child: child,
      builder: (_, c) {
        final v = _seg(_enter.value, b, e);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: c),
        );
      },
    );
  }

  List<BoxShadow> get _shadow => [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4)),
      ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomPadding = widget.showExitAction ? 28.0 : 132.0 + bottomInset;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: 'دليل القياسات', showBack: widget.showBack),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18, 12, 18, bottomPadding),
        children: [
          _reveal(0.00, 0.25, _buildBaselineCard()),
          const SizedBox(height: 26),
          _WaitingIllustration(enter: _enter, loop: _loop),
          const SizedBox(height: 22),
          _reveal(
            0.50,
            0.70,
            const Text('سجّل قياسك التالي لنرسم لك خط التقدم', textAlign: TextAlign.center, style: AppTextStyles.h1),
          ),
          const SizedBox(height: 12),
          _reveal(
            0.58,
            0.76,
            const Text(
              'يتطلب رسم منحنى التقدم قياسين على الأقل لإظهار اتجاه التغير الحقيقي بدقة وموضوعية. تسجيلك القادم سيفعّل المخطط البياني فوراً.',
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
          ),
          const SizedBox(height: 18),
          _reveal(0.66, 0.84, _buildTipCard()),
          const SizedBox(height: 12),
          _reveal(0.72, 0.88, _buildTimingCard()),
          const SizedBox(height: 12),
          _reveal(0.78, 0.92, _buildGuideRow(context)),
          const SizedBox(height: 22),
          _reveal(
            0.84,
            1.0,
            AnimatedBuilder(
              animation: _loop,
              builder: (_, child) {
                final pulse = 1 + 0.015 * math.sin(_loop.value * 2 * math.pi);
                return Transform.scale(scale: pulse, child: child);
              },
              child: GradientCtaButton(
                label: 'سجّل قياساً جديداً',
                icon: Icons.add_rounded,
                onPressed: () {
                  final route = AppPageRoute(
                    builder: (_) => MeasurementEntryScreen(onSaved: widget.onMeasurementSaved),
                  );
                  if (widget.replaceEntryRoute) {
                    Navigator.of(context).pushReplacement(route);
                  } else {
                    Navigator.of(context).push(route);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.showExitAction)
            _reveal(
              0.90,
              1.0,
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('العودة إلى خطتي اليومية', style: AppTextStyles.secondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────── الكرت العلوي ─────────────────────────
  Widget _buildBaselineCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            // توهّج تدرّجي في الزاوية
            PositionedDirectional(
              end: -34,
              top: -34,
              child: AnimatedBuilder(
                animation: _loop,
                builder: (_, __) {
                  final s = 1 + 0.06 * math.sin(_loop.value * 2 * math.pi);
                  return Transform.scale(
                    scale: s,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.primaryTint,
                          AppColors.primaryTint.withOpacity(0.0),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            PositionedDirectional(
              end: 30,
              top: 26,
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), shape: BoxShape.circle),
                child: const Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('نقطة البداية المعتمدة', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('القياس الأولي المسجل', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration:
                        BoxDecoration(color: _tintBox, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
                    child: Row(children: [
                      // الوزن (يمين) مع عدّاد تصاعدي
                      AnimatedBuilder(
                        animation: _enter,
                        builder: (_, __) {
                          final v = _seg(_enter.value, 0.10, 0.45, Curves.easeOutQuart);
                          return Text('${(widget.weightKg * v).toStringAsFixed(1)} كغ',
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 18));
                        },
                      ),
                      const Spacer(),
                      // التاريخ (يسار)
                      const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      const Text('الجمعة، ١٩ سبتمبر ٢٠٢٥', style: AppTextStyles.caption),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    AnimatedBuilder(
                      animation: _enter,
                      builder: (_, child) =>
                          Transform.scale(scale: _seg(_enter.value, 0.22, 0.40, Curves.elasticOut), child: child),
                      child: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text('تم توثيق نقطة البداية بنجاح في ملفك الصحي.', style: AppTextStyles.caption),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── بطاقة النصيحة ─────────────────────────
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _tintBox, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _loop,
          builder: (_, child) {
            // توهّج خفيف للمصباح
            final glow = (math.sin(_loop.value * 2 * math.pi) + 1) / 2;
            return Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.28),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.10 + 0.18 * glow), blurRadius: 6 + 8 * glow),
                ],
              ),
              child: child,
            );
          },
          child: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'قياس واحد يحدد نقطة انطلاقك، والقياس القادم هو ما يرسم رحلتك مع أخصائيتك خطوة بخطوة.',
            style: AppTextStyles.caption,
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── بطاقة التوقيت ─────────────────────────
  Widget _buildTimingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _shadow,
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(color: _iconBlue, shape: BoxShape.circle),
          child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('توقيت القياس المقترح', style: AppTextStyles.cardTitle),
              SizedBox(height: 2),
              Text('صباحاً بعد الاستيقاظ مباشرة لقراءة مستقرة', style: AppTextStyles.caption),
            ],
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── صف الدليل المصوّر ─────────────────────────
  Widget _buildGuideRow(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const MeasurementGuideScreen())),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: _shadow),
          child: Row(children: [
            const Icon(Icons.straighten_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text('دليل القياس المصوّر 📐',
                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
            ),
            // سهم يتحرك نحو اتجاه الانتقال
            AnimatedBuilder(
              animation: _loop,
              builder: (_, child) => Transform.translate(
                offset: Offset(-3 * (math.sin(_loop.value * 2 * math.pi) + 1) / 2, 0),
                child: child,
              ),
              child: const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary),
            ),
          ]),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// الرسم التوضيحي: نقطة البداية → خط يُرسم تدريجياً → هدف نابض
/// ─────────────────────────────────────────────────────────────
class _WaitingIllustration extends StatelessWidget {
  final Animation<double> enter;
  final Animation<double> loop;
  const _WaitingIllustration({required this.enter, required this.loop});

  static const double _w = 240, _h = 190;
  static const Offset _startC = Offset(42, 108); // مركز نقطة البداية
  static const Offset _targetC = Offset(209, 45); // مركز الهدف

  static double _seg(double v, double b, double e, [Curve c = Curves.easeOutCubic]) =>
      Interval(b, e, curve: c).transform(v);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: _w,
        height: _h,
        child: AnimatedBuilder(
          animation: Listenable.merge([enter, loop]),
          builder: (context, _) {
            final e = enter.value;
            final l = loop.value;

            final bigScale = _seg(e, 0.15, 0.40, Curves.easeOutBack);
            final startScale = _seg(e, 0.20, 0.45, Curves.elasticOut);
            final pathProgress = _seg(e, 0.42, 0.72, Curves.easeInOut);
            final targetScale = _seg(e, 0.66, 0.84, Curves.easeOutBack);
            final pillT = _seg(e, 0.76, 0.92);
            final sway = math.sin(l * 2 * math.pi) * 0.12;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // الدائرة الكبيرة الباهتة
                Positioned(
                  left: 38,
                  top: 0,
                  child: Transform.scale(
                    scale: bigScale.clamp(0.0, 1.2),
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primaryTint.withOpacity(0.35)),
                    ),
                  ),
                ),

                // الخط المتقطع + النقطة المسافرة
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      progress: pathProgress,
                      travel: pathProgress >= 1 ? Curves.easeInOut.transform(l) : -1,
                      start: _startC,
                      end: _targetC,
                    ),
                  ),
                ),

                // نقطة البداية
                Positioned(
                  left: 0,
                  top: 66,
                  child: Transform.scale(
                    scale: startScale,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: const Color(0xFFD2F4E6).withOpacity(0.85)),
                      alignment: Alignment.center,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ),
                    ),
                  ),
                ),

                // ورقة النبات (تتمايل)
                Positioned(
                  left: 29,
                  top: 44,
                  child: Transform.scale(
                    scale: startScale,
                    child: Transform.rotate(
                      angle: sway,
                      alignment: Alignment.bottomCenter,
                      child: const Icon(Icons.eco_rounded, color: _leafGreen, size: 26),
                    ),
                  ),
                ),

                // موجات الهدف
                for (final offset in const [0.0, 0.5])
                  Positioned(
                    left: _targetC.dx - 23,
                    top: _targetC.dy - 23,
                    child: _Ripple(t: ((l + offset) % 1.0), visible: targetScale > 0.9),
                  ),

                // الهدف
                Positioned(
                  left: _targetC.dx - 23,
                  top: _targetC.dy - 23,
                  child: Transform.scale(
                    scale: targetScale.clamp(0.0, 1.2),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.primaryTint.withOpacity(0.9)),
                      alignment: Alignment.center,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.6),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ),
                    ),
                  ),
                ),

                // حبة «بانتظار القياس الثاني»
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: pillT.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (1 - pillT) * 14),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Text('بانتظار القياس الثاني',
                                style: TextStyle(fontSize: 12, color: AppColors.primary)),
                            const SizedBox(width: 6),
                            Transform.rotate(
                              angle: l * 2 * math.pi,
                              child: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Ripple extends StatelessWidget {
  final double t; // 0..1
  final bool visible;
  const _Ripple({required this.t, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 46, height: 46);
    return SizedBox(
      width: 46,
      height: 46,
      child: Transform.scale(
        scale: 1 + t * 1.1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity((1 - t) * 0.45), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final double progress; // 0..1 رسم الخط
  final double travel; // 0..1 موضع النقطة المسافرة، أو -1 لإخفائها
  final Offset start;
  final Offset end;
  _PathPainter({required this.progress, required this.travel, required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final dir = (end - start) / (end - start).distance;
    final a = start + dir * 30;
    final b = end - dir * 28;
    final total = (b - a).distance;
    final drawn = total * progress;

    final paint = Paint()
      ..color = AppColors.iconMuted
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dash = 6.0, gap = 5.0;
    double covered = 0;
    while (covered < drawn) {
      final len = math.min(dash, drawn - covered);
      canvas.drawLine(a + dir * covered, a + dir * (covered + len), paint);
      covered += dash + gap;
    }

    if (travel >= 0) {
      final p = a + dir * (total * travel);
      canvas.drawCircle(p, 7, Paint()..color = AppColors.primary.withOpacity(0.18));
      canvas.drawCircle(p, 3.6, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.progress != progress || old.travel != travel;
}
