import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import 'plan_preparing_screen.dart';
import '../core/navigation/app_page_route.dart';

// ───────────────────────── ألوان إضافية مأخوذة من التصميم ─────────────────────────
const Color _kMint = Color(0xFF5EE0B0);
const Color _kMintSoft = Color(0xFFD5F7EA);
const Color _kLavender = Color(0xFFF3F5FC);
const Color _kCheckBg = Color(0xFFBFD6D4);

/// Onboarding step 3/3 — "لا تفوّت مواعيد وجباتك".
///
/// الأنيميشن:
///  1) دخول متتابع (Staggered) لكل العناصر: fade + slide.
///  2) الجرس: يهتز بشكل مخمَّد كل بضع ثوانٍ، مع موجات (ripples) تنتشر منه،
///     وحلقة منقّطة تدور ببطء، وهالة تتنفس، وشارة تطفو.
///  3) علامات الصح تظهر بـ elastic pop بعد ظهور كل بطاقة.
///  4) زر التفعيل: لمعة (shimmer) تمر عليه + توهج نابض + ضغط مع haptic.
class OnboardingNotificationsScreen extends StatefulWidget {
  const OnboardingNotificationsScreen({super.key});

  @override
  State<OnboardingNotificationsScreen> createState() => _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState extends State<OnboardingNotificationsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _loop;

  late final Animation<double> _header, _hero, _heroScale, _title, _desc;
  late final Animation<double> _c1, _c2, _c3, _k1, _k2, _k3, _privacy, _cta, _later, _progress;

  Animation<double> _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(b, e, curve: c));

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _header = _iv(0.00, 0.25);
    _hero = _iv(0.05, 0.40);
    _heroScale = _iv(0.05, 0.45, Curves.easeOutBack);
    _title = _iv(0.22, 0.45);
    _desc = _iv(0.28, 0.50);
    _c1 = _iv(0.34, 0.60);
    _c2 = _iv(0.42, 0.68);
    _c3 = _iv(0.50, 0.76);
    _k1 = _iv(0.52, 0.76, Curves.elasticOut);
    _k2 = _iv(0.60, 0.84, Curves.elasticOut);
    _k3 = _iv(0.68, 0.92, Curves.elasticOut);
    _privacy = _iv(0.62, 0.86);
    _cta = _iv(0.70, 0.94);
    _later = _iv(0.80, 1.00);
    _progress = _iv(0.12, 0.80, Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _finish() {
    // TODO: اطلبي إذن الإشعارات هنا قبل الانتقال (permission_handler / firebase_messaging).
    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(builder: (_) => const PlanPreparingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _Reveal(
                animation: _header,
                dy: -0.3,
                child: _TopBar(loop: _loop, progress: _progress, onBack: () => Navigator.of(context).maybePop()),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FadeTransition(
                              opacity: _hero,
                              child: ScaleTransition(scale: _heroScale, child: _BellHero(loop: _loop)),
                            ),
                            const SizedBox(height: 12),
                            _Reveal(
                              animation: _title,
                              child: const Text(
                                'لا تفوّت مواعيد وجباتك',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.h1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _Reveal(
                              animation: _desc,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'فعّل الإشعارات لتصلك تذكيرات الوجبات المخصصة، وتنبيهات الأخصائي لمتابعة التزامك أولاً بأول وبكل سلاسة.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.secondary.copyWith(height: 1.6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _Reveal(
                              animation: _c1,
                              dy: 0.25,
                              child: _FeatureCard(
                                icon: Icons.restaurant_rounded,
                                title: 'تذكيرات بمواعيد الوجبات المحددة',
                                description:
                                    'تنبيه لطيف قبل موعد الوجبة لمساعدتك على تنظيم يومك وتناول طعامك الصحي في التوقيت الأنسب لجسمك.',
                                check: _k1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Reveal(
                              animation: _c2,
                              dy: 0.25,
                              child: _FeatureCard(
                                icon: Icons.forum_outlined,
                                title: 'رسائل وتوجيهات مباشرة من الأخصائي',
                                description:
                                    'استلم تعليقات أخصائيتك وتعديلات الخطة فور إرسالها دون الحاجة لتفقد التطبيق باستمرار.',
                                emphasized: true,
                                check: _k2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Reveal(
                              animation: _c3,
                              dy: 0.25,
                              child: _FeatureCard(
                                icon: Icons.insights_rounded,
                                title: 'تنبيهات لموعد تسجيل الوزن أسبوعياً',
                                description:
                                    'تذكير أسبوعي في الوقت الصباحي المثالي للقياس لمتابعة تطور نتائجك ومؤشراتك الحيوية بدقة.',
                                check: _k3,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _Reveal(animation: _privacy, dy: 0.2, child: const _PrivacyNote()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // شريط سفلي ثابت: الزر بعرض الشاشة بالكامل
              _Reveal(
                animation: _cta,
                dy: 1.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 18, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ShimmerCtaButton(
                        key: const Key('onboarding-notifications-cta'),
                        label: 'تفعيل الإشعارات الآن',
                        loop: _loop,
                        onPressed: _finish,
                      ),
                      FadeTransition(
                        opacity: _later,
                        child: TextButton(
                          onPressed: _finish,
                          child: const Text('ليس الآن، سأضبطها لاحقاً', style: AppTextStyles.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Reveal (fade + slide) ─────────────────────────────

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double dy;

  const _Reveal({required this.animation, required this.child, this.dy = 0.15});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, dy), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

// ───────────────────────────── الهيدر العلوي (نفس نظام شاشة البيانات الصحية) ─────────────────────────────

/// عنوان + سهم رجوع + أفاتار، وتحتها شريط تقدّم يتحرك من ٦٧٪ (الخطوة ٢) إلى ١٠٠٪
/// (الخطوة ٣) مع عدّاد نسبة مئوية ونقطة مضيئة عند رأس الشريط.
class _TopBar extends StatelessWidget {
  final Animation<double> loop;
  final Animation<double> progress;
  final VoidCallback onBack;

  const _TopBar({required this.loop, required this.progress, required this.onBack});

  static const double _from = 2 / 3;

  static String _ar(int n) {
    const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Column(
        children: [
          Row(
            children: [
              InkResponse(
                onTap: onBack,
                radius: 24,
                // في RTL يتجه هذا السهم لليمين تلقائياً
                child: const Icon(Icons.arrow_back_rounded, size: 26, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Text('الإشعارات', style: AppTextStyles.cardTitle.copyWith(fontSize: 19, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, size: 21, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              final v = _from + (1 - _from) * progress.value;
              final pct = (v * 100).round();
              return Column(
                children: [
                  Row(
                    children: [
                      Text('خطوة ٣ من ٣ (${_ar(pct)}%)',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const Spacer(),
                      const Text('إعداد التنبيهات • HealthyLife', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 9),
                  _ProgressBar(value: v, loop: loop),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Animation<double> loop;

  const _ProgressBar({required this.value, required this.loop});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return SizedBox(
        height: 12,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              height: 7,
              decoration: BoxDecoration(color: const Color(0xFFE3E8EF), borderRadius: BorderRadius.circular(4)),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart, // يبدأ من اليمين في RTL
              child: Container(
                width: c.maxWidth * value,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(colors: [_kMint, AppColors.primary]),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd, // رأس الشريط
                  child: AnimatedBuilder(
                    animation: loop,
                    builder: (_, __) {
                      final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
                      return Transform.translate(
                        offset: const Offset(-1, 0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _kMint, width: 2.5),
                            boxShadow: [
                              BoxShadow(color: _kMint.withAlpha((120 * p).toInt() + 40), blurRadius: 8, spreadRadius: 2 * p),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ───────────────────────────── الجرس البطل ─────────────────────────────

class _BellHero extends StatelessWidget {
  final Animation<double> loop;

  const _BellHero({required this.loop});

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final d = (viewportHeight * 0.185).clamp(110.0, 152.0);
    final ring = d * 0.74;
    final core = d * 0.50;

    return Center(
      child: SizedBox(
        width: d,
        height: d,
        child: AnimatedBuilder(
          animation: loop,
          builder: (context, _) {
            final t = loop.value;

            // اهتزاز الجرس: أول 30% من الدورة، مخمَّد
            double swing = 0;
            if (t < 0.30) {
              final u = t / 0.30;
              swing = 0.42 * (1 - u) * math.sin(u * math.pi * 5);
            }
            final breathe = 1 + 0.06 * math.sin(t * 2 * math.pi);
            final float = math.sin(t * 2 * math.pi * 2) * 2.5;

            return Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
              // الهالة الخضراء (تتنفس)
              Transform.scale(
                scale: breathe,
                child: Container(
                  width: d * 1.15,
                  height: d * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _kMint.withAlpha(120),
                      _kMint.withAlpha(0),
                    ]),
                  ),
                ),
              ),

              // موجات تنتشر من الجرس (3 موجات متتابعة)
              for (int i = 0; i < 3; i++) _ripple(d, ring, (t * 1.0 + i / 3) % 1.0),

              // الحلقة البيضاء
              Container(
                width: ring,
                height: ring,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withAlpha(36), blurRadius: 20, offset: const Offset(0, 5)),
                  ],
                ),
              ),

              // الحلقة المنقّطة الدوّارة
              Transform.rotate(
                angle: t * 2 * math.pi,
                child: CustomPaint(
                  size: Size.square(ring * 0.88),
                  painter: _DashedCirclePainter(color: AppColors.primary.withAlpha(70)),
                ),
              ),

              // النواة على شكل قطرة + الجرس يهتز
              SizedBox(
                width: core,
                height: core * 1.1,
                child: CustomPaint(
                  painter: const _DropPainter(color: AppColors.primary),
                  child: Align(
                    alignment: const Alignment(0, 0.25),
                    child: Transform.rotate(
                      angle: swing,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.notifications_active_rounded, color: Colors.white, size: core * 0.5),
                    ),
                  ),
                ),
              ),

              // الشارة الطافية + لمعة صغيرة تومض
              Positioned(
                top: d * 0.20 + float,
                right: d * 0.20,
                child: Container(
                  width: d * 0.13,
                  height: d * 0.13,
                  decoration: BoxDecoration(
                    color: _kMint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
              Positioned(
                top: d * 0.30 - float,
                right: d * 0.06,
                child: Opacity(
                  opacity: (0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 3))).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + 0.4 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 3)),
                    child: const Icon(Icons.auto_awesome_rounded, size: 14, color: _kMint),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _ripple(double d, double ring, double p) {
    final size = ring * (0.9 + 0.55 * p);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kMint.withAlpha((110 * (1 - p)).toInt()), width: 1.6),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dashes = 36;
    const sweep = 2 * math.pi / dashes;
    final rect = Offset.zero & size;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(rect.deflate(1), i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

/// دائرة بذروة مدببة أعلاها (قطرة).
class _DropPainter extends CustomPainter {
  final Color color;
  const _DropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(size.width / 2, size.height - r);
    final rect = Rect.fromCircle(center: c, radius: r);

    const a0 = -65 * math.pi / 180;
    final p0 = Offset(c.dx + r * math.cos(a0), c.dy + r * math.sin(a0));
    final tip = Offset(c.dx, 0);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..arcTo(rect, a0, 2 * math.pi - 50 * math.pi / 180, false);
    final end = path.getBounds(); // يضمن بقاء المسار صالحاً
    assert(end.width > 0);
    path
      ..quadraticBezierTo(c.dx - r * 0.22, c.dy - r * 0.95, tip.dx, tip.dy)
      ..quadraticBezierTo(c.dx + r * 0.22, c.dy - r * 0.95, p0.dx, p0.dy)
      ..close();

    canvas.drawShadow(path, color.withAlpha(120), 8, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DropPainter old) => old.color != color;
}

// ───────────────────────────── بطاقة الميزة ─────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool emphasized;
  final Animation<double> check;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.check,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 14, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: emphasized ? _kMintSoft : _kLavender,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
            const SizedBox(height: 6),
            Text(description, style: AppTextStyles.caption.copyWith(height: 1.6)),
          ]),
        ),
        const SizedBox(width: 10),
        ScaleTransition(
          scale: check,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(color: _kCheckBg, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, size: 15, color: AppColors.primary),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────── ملاحظة الخصوصية ─────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kLavender,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: const Color(0xFFE6EBFA), borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.lock_outline_rounded, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: 'نحترم هدوءك وخصوصيتك: ',
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const TextSpan(text: 'لن نرسل أي إعلانات ترويجية، ويمكنك دائماً ضبط أو كتم أوقات التنبيهات من الإعدادات.'),
            ]),
            style: AppTextStyles.caption.copyWith(height: 1.6),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────── زر التفعيل (لمعة + توهج + ضغط) ─────────────────────────────

class _ShimmerCtaButton extends StatefulWidget {
  final String label;
  final Animation<double> loop;
  final VoidCallback onPressed;

  const _ShimmerCtaButton({super.key, required this.label, required this.loop, required this.onPressed});

  @override
  State<_ShimmerCtaButton> createState() => _ShimmerCtaButtonState();
}

class _ShimmerCtaButtonState extends State<_ShimmerCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: widget.loop,
          builder: (context, _) {
            final t = widget.loop.value;
            final glow = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
            final s = ((t - 0.45) / 0.35).clamp(0.0, 1.0);

            return Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50 + (40 * glow).toInt()),
                    blurRadius: 14 + 8 * glow,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(alignment: Alignment.center, children: [
                    Positioned(
                      left: -w * 0.3 + s * w * 1.6,
                      top: 0,
                      bottom: 0,
                      width: w * 0.3,
                      child: Transform(
                        transform: Matrix4.skewX(-0.35),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.white.withAlpha(0),
                              Colors.white.withAlpha(60),
                              Colors.white.withAlpha(0),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.label,
                      style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ]);
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}