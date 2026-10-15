import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../widgets/gradient_cta_button.dart';
import 'log_meal_intro_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../../l10n/l10n.dart';

const Color _mint = Color(0xFF19D3A2);
const Color _screenTint = Color(0xFFF2FBF9);

String _num(BuildContext context, num v) =>
    context.localizeDigits(v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1));

class MealLogSuccessScreen extends StatefulWidget {
  final MealLogEntry? entry;

  /// مدة الانتقال التلقائي للخطة اليومية. مرري null لتعطيله؛ وقتها بيظهر
  /// زر "تسجيل وجبة أخرى". الحركات تحتاج ~1.6 ثانية، فيُفضّل 3-4 ثوانٍ.
  final Duration? autoReturnAfter;

  /// الالتزام اليومي: لو أي منهم null بيختفي القسم.
  final int? mealsLogged;
  final int? mealsPlanned;

  /// الماكروز بالغرام. لو كلهم null بيختفي الصف.
  final num? proteinGrams;
  final num? carbsGrams;
  final num? fatGrams;

  const MealLogSuccessScreen({
    super.key,
    this.entry,
    this.autoReturnAfter = const Duration(seconds: 4),
    this.mealsLogged,
    this.mealsPlanned,
    this.proteinGrams,
    this.carbsGrams,
    this.fatGrams,
  });

  @override
  State<MealLogSuccessScreen> createState() => _MealLogSuccessScreenState();
}

class _MealLogSuccessScreenState extends State<MealLogSuccessScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remaining = 0;

  /// حركة الدخول (مرة وحدة) — تقود كل الـ stagger.
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700))
    ..forward();

  /// حركة مستمرة (توهج، موجات، دوران أيقونة التحديث).
  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void initState() {
    super.initState();
    final d = widget.autoReturnAfter;
    if (d != null) {
      final seconds = (d.inMilliseconds / 1000).ceil();
      _remaining = seconds < 1 ? 1 : seconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _remaining--);
        if (_remaining <= 0) {
          t.cancel();
          _returnToApp();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _returnToApp() {
    _timer?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _logAnother() {
    _timer?.cancel();
    Navigator.of(context)
        .push(AppPageRoute(builder: (_) => const LogMealIntroScreen()));
  }

  // The final tick (0) still reads "one second", as before.
  String get _countdownLabel {
    final n = _remaining <= 1 ? 1 : _remaining;
    return context.l10n.mealLoggedCountdown(n, context.localizeDigits(n));
  }

  String _mealsWord(int n) =>
      context.l10n.mealLoggedMealsCount(n, context.localizeDigits(n));

  /// تقدّم جزء من حركة الدخول بين [a] و[b] (0..1).
  double _p(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      Interval(a, b, curve: curve).transform(_intro.value);

  Widget _reveal(double a, double b, Widget child, {double dy = 26}) {
    final t = _p(a, b);
    return Opacity(
      opacity: t.clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final grams = entry?.grams ?? 0;
    final planLabel = entry?.isOffPlan == true
        ? context.l10n.mealLoggedOffPlan
        : context.l10n.mealLoggedFromPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_screenTint, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _intro,
            builder: (context, _) => Column(
              children: [
                _reveal(0, .2, _buildTopBar(), dy: -14),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                    child: Column(
                      children: [
                        _buildBadge(),
                        const SizedBox(height: 6),
                        _reveal(
                            .3,
                            .52,
                            Text(context.l10n.mealLoggedTitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h1)),
                        const SizedBox(height: 8),
                        _reveal(
                          .36,
                          .58,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              context.l10n.mealLoggedBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _reveal(
                          .44,
                          .72,
                          _buildSummaryCard(
                              entry?.name ?? context.l10n.mealLoggedYourMeal,
                              context.l10n.mealLoggedMealLine(
                                  planLabel, context.localizeDigits(grams)),
                              entry?.calories ?? 0),
                          dy: 40,
                        ),
                        const SizedBox(height: 12),
                        if (widget.autoReturnAfter != null)
                          _reveal(.7, .92, _buildAutoReturnBanner()),
                      ],
                    ),
                  ),
                ),
                _reveal(
                  .76,
                  1,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                    child: Column(children: [
                      SizedBox(
                        width: double.infinity,
                        child: GradientCtaButton(
                          label: context.l10n.mealLoggedGoToPlan,
                          // arrow_forward بينعكس تلقائياً في RTL ويشاور لليسار
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _returnToApp,
                        ),
                      ),
                      if (widget.autoReturnAfter == null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _logAnother,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(context.l10n.mealLoggedLogAnother),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary),
                        ),
                      ],
                    ]),
                  ),
                  dy: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Top bar ─────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _loop,
              builder: (_, __) {
                final s = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: _mint.withOpacity(.55 * s),
                          blurRadius: 6 + 4 * s,
                          spreadRadius: 1 + 2 * s)
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(context.l10n.mealLoggedInstantUpdate,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.hairline),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: IconButton(
            tooltip: context.l10n.commonClose,
            padding: EdgeInsets.zero,
            onPressed: _returnToApp,
            icon: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.textPrimary),
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── Animated success badge ─────────────────────────

  Widget _buildBadge() {
    final ring = _p(0, .4, Curves.elasticOut);
    final inner = _p(.08, .5, Curves.elasticOut);
    final check = _p(.3, .6, Curves.easeOutCubic);
    final burst = _p(.22, .85, Curves.linear);
    final ripple = _p(.55, .75);

    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // موجات هادئة تنتشر باستمرار بعد ما يخلص الدخول
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _loop,
              builder: (_, __) =>
                  CustomPaint(painter: _RipplePainter(_loop.value, ripple)),
            ),
          ),
          // توهج يتنفّس
          AnimatedBuilder(
            animation: _loop,
            builder: (_, __) {
              final s = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                          (.28 + .12 * s) * ring.clamp(0.0, 1.0).toDouble()),
                      blurRadius: 36 + 14 * s,
                      spreadRadius: 2 + 4 * s,
                    ),
                  ],
                ),
              );
            },
          ),
          // الحلقة البيضاء
          Transform.scale(
            scale: ring,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
            ),
          ),
          // الدائرة المتدرّجة + علامة الصح اللي تنرسم
          Transform.scale(
            scale: inner,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [_mint, AppColors.primary],
                ),
              ),
              child: CustomPaint(painter: _CheckPainter(check)),
            ),
          ),
          // انفجار جزيئات صغيرة حول الأيقونة
          Positioned.fill(child: CustomPaint(painter: _BurstPainter(burst))),
        ],
      ),
    );
  }

  // ───────────────────────── Summary card ─────────────────────────

  Widget _buildSummaryCard(String name, String subtitle, int calories) {
    final logged = widget.mealsLogged;
    final planned = widget.mealsPlanned;
    final showAdherence = logged != null && planned != null && planned > 0;
    final showMacros = widget.proteinGrams != null ||
        widget.carbsGrams != null ||
        widget.fatGrams != null;

    final countT = _p(.5, .88);
    final shownCalories = (calories * countT).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(.15)),
            ),
            child: const Icon(Icons.restaurant_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text(
              context.l10n
                  .commonKcalValue(context.localizeDigits(shownCalories)),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
        ]),
        if (showAdherence) ...[
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.hairline),
          const SizedBox(height: 14),
          Row(children: [
            Text(context.l10n.mealLoggedDailyAdherence,
                style: AppTextStyles.caption),
            const Spacer(),
            Text(
              context.l10n.mealLoggedSummary(
                  context.localizeDigits(logged),
                  _mealsWord(planned),
                  context.localizeDigits((logged / planned * 100 * _p(.58, .95))
                      .round()
                      .clamp(0, 100))),
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 8),
          _ProgressBar(
            value: (logged / planned) * _p(.58, .95),
            height: 7,
            gradient: true,
          ),
        ],
        if (showMacros) ...[
          const SizedBox(height: 14),
          Row(children: [
            _MacroBox(
                label: context.l10n.macroProteinLabel,
                grams: widget.proteinGrams,
                t: _p(.62, .86, Curves.easeOutBack),
                count: _p(.66, .95)),
            const SizedBox(width: 8),
            _MacroBox(
                label: context.l10n.macroCarbohydrates,
                grams: widget.carbsGrams,
                t: _p(.67, .91, Curves.easeOutBack),
                count: _p(.7, .97)),
            const SizedBox(width: 8),
            _MacroBox(
                label: context.l10n.macroFatLabel,
                grams: widget.fatGrams,
                t: _p(.72, .96, Curves.easeOutBack),
                count: _p(.74, 1)),
          ]),
        ],
      ]),
    );
  }

  // ───────────────────────── Auto-return banner ─────────────────────────

  Widget _buildAutoReturnBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          RotationTransition(
            turns: _loop,
            child: const Icon(Icons.refresh_rounded,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(context.l10n.mealLoggedRedirecting,
                  style: AppTextStyles.caption)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, .5), end: Offset.zero)
                        .animate(a),
                child: c,
              ),
            ),
            child: Text(
              _countdownLabel,
              key: ValueKey(_countdownLabel),
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: widget.autoReturnAfter!,
          builder: (_, v, __) => _ProgressBar(value: v, height: 3),
        ),
      ]),
    );
  }
}

// ───────────────────────────── Widgets ─────────────────────────────

/// شريط تقدّم يمتلئ من جهة البداية (اليمين في RTL).
class _ProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final bool gradient;
  const _ProgressBar(
      {required this.value, required this.height, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.primaryTint,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0).toDouble(),
          child: Container(
            decoration: BoxDecoration(
              color: gradient ? null : AppColors.primary,
              gradient: gradient
                  ? const LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [AppColors.primary, _mint],
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  final String label;
  final num? grams;
  final double t; // ظهور + pop
  final double count; // عدّاد الرقم
  const _MacroBox(
      {required this.label,
      required this.grams,
      required this.t,
      required this.count});

  @override
  Widget build(BuildContext context) {
    final g = grams;
    final String text;
    if (g == null) {
      text = '—';
    } else if (count >= 1) {
      text = context.l10n.commonGramsValue(_num(context, g));
    } else {
      text = context.l10n
          .commonGramsValue(context.localizeDigits((g * count).round()));
    }

    return Expanded(
      child: Opacity(
        opacity: t.clamp(0.0, 1.0).toDouble(),
        child: Transform.scale(
          scale: .85 + .15 * t,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(text, style: AppTextStyles.cardTitle.copyWith(fontSize: 13)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Painters ─────────────────────────────

/// علامة الصح بتنرسم تدريجياً بدل ما تظهر جاهزة.
class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * .29, h * .52)
      ..lineTo(w * .45, h * .67)
      ..lineTo(w * .73, h * .36);
    final metric = path.computeMetrics().first;
    final extracted =
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));
    canvas.drawPath(
      extracted,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .075
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.progress != progress;
}

/// جزيئات صغيرة (نقاط وخطوط) تنفجر حول الأيقونة وتتلاشى.
class _BurstPainter extends CustomPainter {
  final double t;
  _BurstPainter(this.t);

  static const _colors = [
    AppColors.primary,
    _mint,
    Color(0xFFFFC15A),
    Color(0xFF7FE3C9)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);
    const count = 18;

    for (var i = 0; i < count; i++) {
      final angle = i / count * 2 * math.pi + (i.isEven ? .1 : -.08);
      final dist = 66 + eased * (26 + (i % 3) * 14);
      final dir = Offset(math.cos(angle), math.sin(angle));
      final pos = center + dir * dist;
      final paint = Paint()
        ..color = _colors[i % _colors.length]
            .withOpacity((1 - t).clamp(0.0, 1.0).toDouble())
        ..strokeCap = StrokeCap.round;

      if (i.isEven) {
        canvas.drawCircle(pos, (4.5 - (i % 3)) * (1 - t * .5), paint);
      } else {
        paint
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        canvas.drawLine(pos, pos + dir * (8 * (1 - t * .5)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

/// حلقتان تنتشران وتتلاشيان باستمرار.
class _RipplePainter extends CustomPainter {
  final double loop;
  final double appear;
  _RipplePainter(this.loop, this.appear);

  @override
  void paint(Canvas canvas, Size size) {
    if (appear <= 0) return;
    final center = size.center(Offset.zero);
    for (var k = 0; k < 2; k++) {
      final p = (loop + k * .5) % 1.0;
      final radius = 76 + 38 * Curves.easeOut.transform(p);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.primary
              .withOpacity((1 - p) * .3 * appear.clamp(0.0, 1.0).toDouble()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.loop != loop || old.appear != appear;
}
