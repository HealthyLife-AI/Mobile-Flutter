import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../app_shell.dart';
import '../../core/navigation/app_page_route.dart';

// ───────────────────────── ألوان إضافية مأخوذة من التصميم ─────────────────────────
const Color _kMint = Color(0xFF5EE0B0);
const Color _kMintSector = Color(0xFFC9F3E3);
const Color _kMintSoft = Color(0xFFE3F8F0);
const Color _kSkySector = Color(0xFFD6EEFA);
const Color _kDisc = Color(0xFFEEF1FB);
const Color _kLavender = Color(0xFFF4F6FC);
const Color _kIconBg = Color(0xFFBFD6D4);
const Color _kLine = Color(0xFFDCE3EC);

String _ar(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

/// اهتزاز مخمَّد في أول [span] من الدورة.
double _swing(double t, {double span = 0.22, double amp = 0.45, int waves = 5}) {
  if (t >= span) return 0;
  final u = t / span;
  return amp * (1 - u) * math.sin(u * math.pi * waves);
}

/// "خطتك قيد التحضير بعناية" — تظهر بينما تُعدّ الأخصائية الخطة.
/// تنتقل تلقائياً بعد 5 ثوانٍ.
///
/// الأنيميشن:
///  1) دخول متتابع لكل العناصر (fade + slide) والمشهد الرئيسي بـ elastic.
///  2) المشهد الرئيسي "حيّ": القرص تتمايل قطاعاته، موجات رادار تنتشر منه،
///     حلقة منقّطة تدور، والمستند يطفو وتُكتب أسطره سطراً سطراً (كأن الخطة تُعدّ الآن)،
///     وعقرب الساعة يدور، وعلامة الصح تنبض، واللمعة تومض.
///  3) الساعة الرملية تنقلب كل بضع ثوانٍ، وجرس "مفعّل" يهتز.
///  4) عدّاد "١٠٠٪" يعدّ تصاعدياً، وزر واتساب بلمعة وتوهج وhaptic.
class PlanPreparingScreen extends StatefulWidget {
  const PlanPreparingScreen({super.key});

  @override
  State<PlanPreparingScreen> createState() => _PlanPreparingScreenState();
}

class _PlanPreparingScreenState extends State<PlanPreparingScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _loop;

  late final Animation<double> _header, _badgePop, _hero, _heroScale, _title, _desc, _card1, _card2, _count;

  Timer? _timer;

  Animation<double> _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(b, e, curve: c));

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _header = _iv(0.00, 0.25);
    _badgePop = _iv(0.10, 0.40, Curves.elasticOut);
    _hero = _iv(0.08, 0.40);
    _heroScale = _iv(0.08, 0.55, Curves.elasticOut);
    _title = _iv(0.30, 0.52);
    _desc = _iv(0.36, 0.58);
    _card1 = _iv(0.48, 0.74);
    _card2 = _iv(0.60, 0.88);
    _count = _iv(0.55, 0.95);

    _timer = Timer(const Duration(seconds: 5), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(builder: (_) => const AppShell()),
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              // ───────── الهيدر: كبسولة العيادة + شارة التوثيق ─────────
              _Reveal(
                animation: _header,
                dy: -0.4,
                child: Row(
                  children: [
                    Flexible(child: _ClinicPill(loop: _loop)),
                    const SizedBox(width: 10),
                    ScaleTransition(
                      scale: _badgePop,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: _kLavender, shape: BoxShape.circle),
                        child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 19),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ───────── المشهد الرئيسي ─────────
              FadeTransition(
                opacity: _hero,
                child: ScaleTransition(scale: _heroScale, child: Center(child: _PlanHero(loop: _loop))),
              ),
              const SizedBox(height: 26),

              // ───────── العنوان والوصف ─────────
              _Reveal(
                animation: _title,
                child: const Text('خطتكِ قيد التحضير بعناية', textAlign: TextAlign.center, style: AppTextStyles.h1),
              ),
              const SizedBox(height: 12),
              _Reveal(
                animation: _desc,
                child: Text(
                  'أخصائية التغذية العلاجية تُعدّ الآن جدولك الغذائي المخصص بدقة ليلائم أهدافك الصحية ونتائج قياساتك الأولية. سنرسل لك إشعاراً فور اعتماد الخطة لتجديها هنا.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.secondary.copyWith(height: 1.7),
                ),
              ),
              const SizedBox(height: 24),

              // ───────── بطاقة 1: الوقت المتوقع ─────────
              _Reveal(
                animation: _card1,
                dy: 0.25,
                child: _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _FlippingHourglass(loop: _loop),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الوقت المتوقع للاعتماد', style: AppTextStyles.cardTitle),
                                SizedBox(height: 4),
                                Text('خلال ٢٤ ساعة عمل من تسجيل قياساتك الأولية', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActiveBadge(loop: _loop),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 17),
                            const SizedBox(width: 6),
                            Text(
                              'مراجعة طبية سريرية موثقة',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            AnimatedBuilder(
                              animation: _count,
                              builder: (_, __) => Text(
                                '${_ar((100 * _count.value).round())}٪ يدوي ومخصص',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ───────── بطاقة 2: التواصل مع الأخصائية ─────────
              _Reveal(
                animation: _card2,
                dy: 0.25,
                child: _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _PulsingChatIcon(loop: _loop),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('استفسار أو تفضيل غذائي طارئ؟', style: AppTextStyles.cardTitle),
                                SizedBox(height: 4),
                                Text('فريقنا وأخصائيتك متاحون للمساعدة الفورية', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ShimmerButton(
                        label: 'تواصل مع الأخصائية عبر واتساب',
                        icon: Icons.support_agent_rounded,
                        loop: _loop,
                        onPressed: () {
                          // TODO: افتحي واتساب عبر url_launcher (wa.me/<number>)
                        },
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'متاح طوال أيام العمل الرسمية من ٩:٠٠ ص حتى ٦:٠٠ م',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
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

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(16), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

// ───────────────────────────── كبسولة العيادة ─────────────────────────────

class _ClinicPill extends StatelessWidget {
  final Animation<double> loop;
  const _ClinicPill({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: loop,
            builder: (_, __) {
              final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 3);
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white.withAlpha((120 * p).toInt()), blurRadius: 6, spreadRadius: 2 * p)],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'عيادة التغذية العلاجية • أ. خلود العربي',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── المشهد الرئيسي ─────────────────────────────

class _PlanHero extends StatelessWidget {
  final Animation<double> loop;
  const _PlanHero({required this.loop});

  static const double _w = 260, _h = 212, _d = 176, _cx = 130, _cy = 96;

  Widget _at(double size, double dx, double dy, Widget child) => Positioned(
        left: _cx + dx - size / 2,
        top: _cy + dy - size / 2,
        width: size,
        height: size,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _w,
      height: _h,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) {
          final t = loop.value;
          const tau = 2 * math.pi;
          final breathe = 1 + 0.05 * math.sin(t * tau);
          final float = math.sin(t * tau) * 4;
          final sway = 0.35 * math.sin(t * tau);
          final twinkle = 0.5 + 0.5 * math.sin(t * tau * 3);
          final pulse = 0.5 + 0.5 * math.sin(t * tau * 2);

          return Stack(clipBehavior: Clip.none, children: [
            // الهالة
            _at(
              _d * 1.45,
              0,
              0,
              Transform.scale(
                scale: breathe,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [_kMint.withAlpha(95), _kMint.withAlpha(0)]),
                  ),
                ),
              ),
            ),

            // موجات رادار
            for (int i = 0; i < 2; i++) _ripple((t * 2 + i / 2) % 1.0),

            // القرص بقطاعيه المتمايلين
            _at(_d, 0, 0, CustomPaint(painter: _DiscPainter(sway))),

            // الحلقة المنقّطة الدوّارة
            _at(
              _d * 0.76,
              0,
              0,
              Transform.rotate(
                angle: -t * tau,
                child: CustomPaint(painter: _DashedCirclePainter(color: AppColors.primary.withAlpha(60))),
              ),
            ),

            // المستند الطافي
            _at(
              90,
              0,
              -8 + float,
              Center(
                child: Transform.rotate(angle: -0.06 + 0.02 * math.sin(t * tau), child: _DocCard(t: t)),
              ),
            ),

            // لمعة
            _at(
              20,
              40,
              -50 - float * 0.5,
              Opacity(
                opacity: (0.35 + 0.65 * twinkle).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.75 + 0.5 * twinkle,
                  child: const Icon(Icons.auto_awesome_rounded, size: 18, color: _kMint),
                ),
              ),
            ),

            // شارة الساعة (عقرب يدور)
            _at(
              34,
              -32,
              30 + float * 0.6,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: CustomPaint(painter: _ClockPainter(t * tau * 3)),
              ),
            ),

            // موجة صغيرة خلف علامة الصح
            _at(
              34 + 22 * pulse,
              30,
              30 - float * 0.6,
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kMint.withAlpha((120 * (1 - pulse)).toInt()), width: 1.5),
                ),
              ),
            ),
            // شارة الصح
            _at(
              34,
              30,
              30 - float * 0.6,
              Transform.scale(
                scale: 1 + 0.07 * pulse,
                child: Container(
                  decoration: BoxDecoration(
                    color: _kMint,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 19),
                ),
              ),
            ),

            // كبسولة "تخصيص متقدم"
            Positioned(
              top: _cy + _d / 2 - 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: _kMint.withAlpha(90)),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _kMint,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _kMint.withAlpha((140 * twinkle).toInt()), blurRadius: 6, spreadRadius: 1.5 * twinkle)],
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text('تخصيص متقدم', style: AppTextStyles.caption),
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _ripple(double p) => _at(
        _d * (1.0 + 0.32 * p),
        0,
        0,
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _kMint.withAlpha((90 * (1 - p)).toInt()), width: 1.4),
          ),
        ),
      );
}

/// المستند: غطاء داكن + أسطر "تُكتب" سطراً سطراً ثم تُمحى وتتكرر.
class _DocCard extends StatelessWidget {
  final double t;
  const _DocCard({required this.t});

  @override
  Widget build(BuildContext context) {
    const maxW = [1.0, 0.8, 1.0, 0.6];
    final fade = t > 0.85 ? (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0) : 1.0;

    return Container(
      width: 62,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              height: 12,
              color: AppColors.primary,
              alignment: Alignment.center,
              child: Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(color: Colors.white.withAlpha(180), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Container(
                        height: 5,
                        alignment: AlignmentDirectional.centerStart,
                        decoration: BoxDecoration(color: _kLine.withAlpha(110), borderRadius: BorderRadius.circular(3)),
                        child: FractionallySizedBox(
                          widthFactor: (maxW[i] * ((t - (0.04 + i * 0.16)) / 0.16).clamp(0.0, 1.0) * fade).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: i == 0 ? _kMint : _kLine,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscPainter extends CustomPainter {
  final double sway;
  const _DiscPainter(this.sway);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = _kDisc);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.translate(c.dx, c.dy);
    canvas.rotate(sway);
    canvas.translate(-c.dx, -c.dy);
    final rect = Rect.fromCircle(center: c, radius: r * 1.05);
    canvas.drawArc(rect, -1.45, 1.5, true, Paint()..color = _kMintSector);
    canvas.drawArc(rect, 1.7, 1.6, true, Paint()..color = _kSkySector);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiscPainter old) => old.sway != sway;
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
    const dashes = 40;
    const sweep = 2 * math.pi / dashes;
    final rect = Offset.zero & size;
    for (int i = 0; i < dashes; i++) {
      canvas.drawArc(rect.deflate(1), i * sweep, sweep * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.color != color;
}

class _ClockPainter extends CustomPainter {
  final double minuteAngle;
  const _ClockPainter(this.minuteAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, size.width * 0.3, p);
    // عقرب الساعات (ثابت)
    const h = -math.pi / 2 + math.pi / 3;
    canvas.drawLine(c, c + Offset(math.cos(h), math.sin(h)) * (size.width * 0.15), p);
    // عقرب الدقائق (يدور)
    final m = -math.pi / 2 + minuteAngle;
    canvas.drawLine(c, c + Offset(math.cos(m), math.sin(m)) * (size.width * 0.22), p);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) => old.minuteAngle != minuteAngle;
}

// ───────────────────────────── عناصر البطاقات ─────────────────────────────

/// ساعة رملية تنقلب مرتين في كل دورة.
class _FlippingHourglass extends StatelessWidget {
  final Animation<double> loop;
  const _FlippingHourglass({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (_, __) {
        final x = loop.value * 2;
        final k = x.floor();
        final u = x - k;
        final f = Curves.easeInOutCubic.transform(((u - 0.8) / 0.2).clamp(0.0, 1.0));
        return Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(color: _kIconBg, shape: BoxShape.circle),
          child: Transform.rotate(
            angle: math.pi * (k + f),
            child: const Icon(Icons.hourglass_bottom_rounded, color: AppColors.primary, size: 22),
          ),
        );
      },
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final Animation<double> loop;
  const _ActiveBadge({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _kMintSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) => Transform.rotate(
            angle: _swing(loop.value, span: 0.18),
            alignment: Alignment.topCenter,
            child: const Icon(Icons.notifications_active_rounded, size: 13, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 4),
        const Text('مفعّل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    );
  }
}

class _PulsingChatIcon extends StatelessWidget {
  final Animation<double> loop;
  const _PulsingChatIcon({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (_, __) {
        final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
        return Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
          Container(
            width: 42 + 10 * p,
            height: 42 + 10 * p,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _kIconBg.withAlpha((70 * (1 - p)).toInt())),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: _kIconBg, shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
          ),
        ]);
      },
    );
  }
}

// ───────────────────────────── زر واتساب (لمعة + توهج + ضغط) ─────────────────────────────

class _ShimmerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Animation<double> loop;
  final VoidCallback onPressed;

  const _ShimmerButton({required this.label, required this.icon, required this.loop, required this.onPressed});

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton> {
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
            final s = ((t - 0.4) / 0.3).clamp(0.0, 1.0);

            return Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40 + (40 * glow).toInt()),
                    blurRadius: 12 + 8 * glow,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(widget.label,
                          style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 15)),
                      const SizedBox(width: 8),
                      Icon(widget.icon, color: Colors.white, size: 20),
                    ]),
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
