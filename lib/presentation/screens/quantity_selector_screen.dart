import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../bloc/meal_log/meal_log_cubit.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/load_error_view.dart';
import '../widgets/clinical_trust_footer.dart';
import 'meal_log_success_screen.dart';
import '../widgets/app_header_bar.dart';
import '../../core/navigation/app_page_route.dart';

import '../widgets/directional_icon.dart';
import '../../l10n/l10n.dart';

const Color _mint = Color(0xFFD9F5EC);
const Color _periwinkle = Color(0xFFDDE6F8);
const Color _cardBase = Color(0xFFF4F7FD);

/// Quantity/grams stepper screen (POST /me/meal-logs quantity_grams field).
class QuantitySelectorScreen extends StatefulWidget {
  final SearchableFood food;
  const QuantitySelectorScreen({super.key, required this.food});

  @override
  State<QuantitySelectorScreen> createState() => _QuantitySelectorScreenState();
}

class _QuantitySelectorScreenState extends State<QuantitySelectorScreen>
    with TickerProviderStateMixin {
  int _grams = 150;
  bool _lastWasAdd = true;

  /// True while the log is being saved. A second tap is ignored.
  bool _saving = false;
  final List<int> _quickAmounts = const [50, 100, 150, 200];

  // M13 — الكمية المضافة "تقفز" من زر +/- باتجاه الرقم (Scale+Bounce ~380ms).
  late final AnimationController _jumpController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));

  /// نبضة صغيرة على رقم السعرات عند كل تغيير.
  late final AnimationController _bump = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 360));

  /// حركة الدخول المتتابعة.
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();

  /// حركة مستمرة (بقع الخلفية، التوهج، نبض القلب...).
  late final AnimationController _loop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
    ..repeat();

  int get _calories => (_grams * widget.food.caloriesPer100g / 100).round();

  void _changeGrams(int delta) {
    final next = (_grams + delta).clamp(1, 1000);
    if (next == _grams) return;
    HapticFeedback.selectionClick();
    setState(() {
      _grams = next;
      _lastWasAdd = delta > 0;
    });
    _jumpController.forward(from: 0);
    _bump.forward(from: 0);
  }

  void _pickQuick(int g) {
    if (g == _grams) return;
    HapticFeedback.selectionClick();
    setState(() => _grams = g);
    _bump.forward(from: 0);
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _bump.dispose();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _p(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      Interval(a, b, curve: curve).transform(_intro.value);

  Widget _reveal(double a, double b, Widget child, {double dy = 28}) {
    final t = _p(a, b);
    return Opacity(
      opacity: t.clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeaderBar(title: context.l10n.foodSearchAteOffPlan),
      body: AnimatedBuilder(
        animation: _intro,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            _reveal(0, .3, _buildFoodCard()),
            const SizedBox(height: 18),
            _reveal(.1, .46, _buildMainCard(), dy: 40),
            const SizedBox(height: 18),
            _reveal(.3, .5, _buildQuickHeader()),
            const SizedBox(height: 10),
            _reveal(.36, .62, _buildQuickAmounts()),
            const SizedBox(height: 18),
            _reveal(.46, .72, _buildFineTune()),
            const SizedBox(height: 16),
            _reveal(.56, .8, _buildTip()),
            const SizedBox(height: 12),
            _reveal(.63, .87, _buildHealthyApproach()),
            const SizedBox(height: 22),
            _reveal(.72, 1, _buildCta(), dy: 34),
            _reveal(.82, 1, const ClinicalTrustFooter(), dy: 14),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Food card ─────────────────────────

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      );

  Widget _buildFoodCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Row(children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
              color: AppColors.foodTagBg(widget.food.category),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.restaurant_rounded,
              color: AppColors.foodTagIcon(widget.food.category)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                    child: Text(widget.food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(context.l10n.quantityFreshFruit,
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 5),
              Text(
                  context.l10n.quantityKcalPerGrams(
                      context.localizeDigits(widget.food.caloriesPer100g),
                      context.localizeDigits(100)),
                  style: AppTextStyles.caption),
            ],
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── Main calories card ─────────────────────────

  Widget _buildMainCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _cardBase),
        child: Stack(
          children: [
            // بقع لونية ناعمة تتحرك ببطء خلف المحتوى
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _loop,
                builder: (_, __) {
                  final s = math.sin(_loop.value * 2 * math.pi);
                  final c = math.cos(_loop.value * 2 * math.pi);
                  return Stack(children: [
                    PositionedDirectional(
                        top: -60 + 14 * s,
                        start: -50 + 12 * c,
                        child: const _Blob(size: 200, color: _mint)),
                    PositionedDirectional(
                        bottom: -70 + 12 * c,
                        end: -60 + 14 * s,
                        child: const _Blob(size: 220, color: _periwinkle)),
                  ]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bump,
                    builder: (_, child) => Transform.scale(
                        scale: 1 + .06 * math.sin(math.pi * _bump.value),
                        child: child),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 8)
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.local_fire_department_rounded,
                            size: 15, color: AppColors.primary),
                        const SizedBox(width: 5),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          transitionBuilder: (c, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(
                                position: Tween<Offset>(
                                        begin: const Offset(0, .4),
                                        end: Offset.zero)
                                    .animate(a),
                                child: c),
                          ),
                          child: Text(
                            context.l10n.quantityKcalTimesPortions(
                                context.localizeDigits(
                                    widget.food.caloriesPer100g),
                                context.localizeDigits(
                                    (_grams / 100).toStringAsFixed(2))),
                            key: ValueKey(_grams),
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _bump,
                          builder: (_, child) => Transform.scale(
                              scale: 1 + .08 * math.sin(math.pi * _bump.value),
                              child: child),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _calories.toDouble()),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => Text(
                              context.localizeDigits(v.round()),
                              style: AppTextStyles.metricLarge.copyWith(
                                  fontSize: 46, color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(context.l10n.commonCaloriesUnit,
                                style: AppTextStyles.secondary)),
                      ]),
                  const SizedBox(height: 6),
                  Text(context.l10n.quantityCalculatedNote,
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  _buildStepper(),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                        context.l10n.quantityRange(context.localizeDigits(1),
                            context.localizeDigits(1000)),
                        style: AppTextStyles.caption),
                    const SizedBox(width: 6),
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: AppColors.primary),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // في الـ RTL: أول عنصر يمين (−) وآخر عنصر يسار (+) زي التصميم.
          Row(
            children: [
              _StepperButton(
                  icon: Icons.remove_rounded,
                  filled: false,
                  onStep: () => _changeGrams(-10)),
              Expanded(
                child: Column(children: [
                  // رقم الغرامات: يتدحرج لفوق عند الزيادة ولتحت عند النقصان
                  ClipRect(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, anim) {
                        final incoming = child.key == ValueKey(_grams);
                        final dir = _lastWasAdd ? 1.0 : -1.0;
                        final begin =
                            Offset(0, incoming ? .7 * dir : -.7 * dir);
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                              position:
                                  Tween<Offset>(begin: begin, end: Offset.zero)
                                      .animate(anim),
                              child: child),
                        );
                      },
                      child: Text(context.localizeDigits(_grams),
                          key: ValueKey(_grams),
                          style: AppTextStyles.metricLarge),
                    ),
                  ),
                  Text(context.l10n.quantityGramsUnit,
                      style: AppTextStyles.caption),
                ]),
              ),
              _StepperButton(
                  icon: Icons.add_rounded,
                  filled: true,
                  onStep: () => _changeGrams(10)),
            ],
          ),
          // M13: شارة "+10/-10" تقفز من الزر المضغوط باتجاه الرقم
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _jumpController,
              builder: (context, child) {
                if (_jumpController.isDismissed) return const SizedBox.shrink();
                final t = _jumpController.value;
                // الزر + في نهاية الصف (اليسار في العربية)، والزر − في بدايته.
                final sign = rtlDesignSign(context);
                final startAlign = _lastWasAdd
                    ? Alignment(-0.85 * sign, 0)
                    : Alignment(0.85 * sign, 0);
                final align = Alignment.lerp(startAlign, Alignment.center,
                    Curves.easeOutCubic.transform(t))!;
                final bounce = Curves.elasticOut.transform(t.clamp(0.0, 1.0));
                final opacity = (1 - t).clamp(0.0, 1.0);
                return Positioned.fill(
                  child: Align(
                    alignment: align,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: 0.6 + bounce * 0.6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill)),
                          child: Text(
                            _lastWasAdd
                                ? context.l10n
                                    .quantityStepAdd(context.localizeDigits(10))
                                : context.l10n.quantityStepSubtract(
                                    context.localizeDigits(10)),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Quick amounts ─────────────────────────

  Widget _buildQuickHeader() {
    return Row(children: [
      Text(context.l10n.quantityCommonAmounts, style: AppTextStyles.cardTitle),
      const Spacer(),
      Text(context.l10n.quantityOneTap, style: AppTextStyles.caption),
    ]);
  }

  Widget _buildQuickAmounts() {
    final idx = _quickAmounts.indexOf(_grams);
    final x = idx == -1 ? -1.0 : -1 + 2 * idx / (_quickAmounts.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: _cardDeco(),
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            // مؤشر متدرّج ينزلق بين الكميات بحركة مرنة
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutBack,
                alignment: AlignmentDirectional(x, 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / _quickAmounts.length,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: idx == -1 ? 0 : 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppRadius.cardSmall),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: _quickAmounts.map((g) {
                final active = g == _grams;
                return Expanded(
                  child: _PressScale(
                    onTap: () => _pickQuick(g),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: AppTextStyles.body.copyWith(
                          color: active ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                        child: Text(context.l10n
                            .commonGramsShortValue(context.localizeDigits(g))),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Fine tune slider ─────────────────────────

  Widget _buildFineTune() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(context.l10n.quantityFineSlider,
                style: AppTextStyles.cardTitle),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.chipInactiveBg,
                  borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (c, a) => FadeTransition(
                    opacity: a, child: ScaleTransition(scale: a, child: c)),
                child: Text(
                    context.l10n
                        .commonGramsValue(context.localizeDigits(_grams)),
                    key: ValueKey(_grams),
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.chipInactiveBg,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 11, elevation: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
              overlayColor: AppColors.primary.withOpacity(0.15),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: _grams.toDouble().clamp(1.0, 500.0).toDouble(),
              min: 1,
              max: 500,
              onChanged: (v) => setState(() => _grams = v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [1, 125, 250, 375, 500]
                .map((v) => Text(
                    context.l10n
                        .commonGramsShortValue(context.localizeDigits(v)),
                    style: AppTextStyles.caption))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Tip + healthy approach ─────────────────────────

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.primaryTint.withOpacity(.55),
          borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // المصباح: توهج أصفر ناعم يتنفّس
        AnimatedBuilder(
          animation: _loop,
          builder: (_, __) {
            final s = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.28),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFFC15A).withOpacity(.12 + .28 * s),
                      blurRadius: 10 + 8 * s,
                      spreadRadius: 1)
                ],
              ),
              child: const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.textPrimary, size: 20),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.l10n.quantityEstimateHint,
                style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text(
              context.l10n.quantityEstimateBody(
                  context.localizeDigits(150), context.localizeDigits(100)),
              style: AppTextStyles.caption,
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildHealthyApproach() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: AnimatedBuilder(
        animation: _loop,
        builder: (_, __) {
          // نبضتان للقلب في كل دورة + ورقة تتمايل
          final x = (_loop.value * 2) % 1.0;
          final beat = 1 + .16 * math.pow(math.sin(math.pi * x), 14);
          final sway = .14 * math.sin(_loop.value * 2 * math.pi);
          return Row(children: [
            Transform.scale(
              scale: beat.toDouble(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.favorite_border_rounded,
                    color: AppColors.primary, size: 21),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.quantityReassuring,
                        style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text(context.l10n.quantityFlexibility,
                        style: AppTextStyles.caption),
                  ]),
            ),
            const SizedBox(width: 8),
            Transform.rotate(
                angle: sway,
                alignment: Alignment.bottomCenter,
                child: const Icon(Icons.eco_outlined,
                    color: AppColors.primary, size: 26)),
          ]);
        },
      ),
    );
  }

  Widget _buildCta() {
    return GradientCtaButton(
      label: context.l10n.quantityConfirm,
      icon: Icons.check_circle_outline_rounded,
      loading: _saving,
      onPressed: _saving ? null : _confirm,
    );
  }

  /// Logs the food at the chosen portion. The success screen opens once the log
  /// is kept on the device, even if it is still waiting to reach the server. A
  /// refused log shows its reason and stays on this screen.
  Future<void> _confirm() async {
    setState(() => _saving = true);
    final result =
        await context.read<MealLogCubit>().logFood(widget.food, grams: _grams);
    if (!mounted) return;
    setState(() => _saving = false);
    final entry = result.valueOrNull;
    if (entry == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loadFailureMessage(context, result.failureOrNull)),
      ));
      return;
    }
    Navigator.of(context)
        .push(AppPageRoute(builder: (_) => MealLogSuccessScreen(entry: entry)));
  }
}

// ───────────────────────────── Widgets ─────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

/// زر +/-: يصغر عند الضغط، ومع الضغط المطوّل يكرّر الخطوة بسرعة.
class _StepperButton extends StatefulWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onStep;
  const _StepperButton(
      {required this.icon, required this.filled, required this.onStep});

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  Timer? _delay;
  Timer? _repeat;
  bool _down = false;

  void _start() {
    setState(() => _down = true);
    widget.onStep();
    _delay = Timer(const Duration(milliseconds: 320), () {
      _repeat = Timer.periodic(
          const Duration(milliseconds: 75), (_) => widget.onStep());
    });
  }

  void _stop() {
    _delay?.cancel();
    _repeat?.cancel();
    if (mounted) setState(() => _down = false);
  }

  @override
  void dispose() {
    _delay?.cancel();
    _repeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _start(),
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: AnimatedScale(
        scale: _down ? .88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.filled ? AppColors.primaryGradient : null,
            color: widget.filled ? null : AppColors.primaryTint,
            boxShadow: widget.filled
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Icon(widget.icon,
              color: widget.filled ? Colors.white : AppColors.primary,
              size: 24),
        ),
      ),
    );
  }
}

/// ضغطة بتصغّر العنصر قليلاً (إحساس لمسي).
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? .92 : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
}
