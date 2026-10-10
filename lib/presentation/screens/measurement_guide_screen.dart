import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../data/mock/measurement_mock_data.dart';
import '../widgets/app_header_bar.dart';

/// دليل القياسات — illustrated step-by-step guide for each circumference
/// measurement. All four guides are listed in one scroll; the chip row jumps
/// to a section and follows the scroll position.
class MeasurementGuideScreen extends StatefulWidget {
  final String initialPart;
  const MeasurementGuideScreen({super.key, this.initialPart = 'waist'});

  @override
  State<MeasurementGuideScreen> createState() => _MeasurementGuideScreenState();
}

class _MeasurementGuideScreenState extends State<MeasurementGuideScreen> {
  // ألوان مقدّرة من اللقطات؛ استبدلها برموز الثيم إن وُجد ما يقابلها.
  static const Color _lavender = Color(0xFFEEF1FC);
  static const Color _lavenderSoft = Color(0xFFF4F6FD);
  static const Color _teal = Color(0xFF0E7C86);

  late String _selected = widget.initialPart;
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _keys = {
    for (final p in MeasurementGuideData.parts) p.key: GlobalKey(),
  };
  bool _programmatic = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    if (widget.initialPart != MeasurementGuideData.parts.first.key) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goTo(widget.initialPart));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _goTo(String key) async {
    setState(() => _selected = key);
    final ctx = _keys[key]?.currentContext;
    if (ctx == null) return;
    _programmatic = true;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.0,
    );
    _programmatic = false;
  }

  /// يحدّث الشريحة المحددة حسب القسم الظاهر أعلى الشاشة.
  void _onScroll() {
    if (_programmatic || !mounted) return;
    final limit = MediaQuery.of(context).padding.top + kToolbarHeight + 140;
    String current = MeasurementGuideData.parts.first.key;
    for (final p in MeasurementGuideData.parts) {
      final box = _keys[p.key]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= limit) current = p.key;
    }
    if (current != _selected) setState(() => _selected = current);
  }

  static IconData _partIcon(String key) {
    switch (key) {
      case 'hip':
        return Icons.accessibility_new_rounded;
      case 'thigh':
        return Icons.directions_walk_rounded;
      case 'arm':
        return Icons.fitness_center_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  static String _arabicDigits(String s) {
    const w = '0123456789';
    const a = '٠١٢٣٤٥٦٧٨٩';
    var out = s;
    for (var i = 0; i < w.length; i++) {
      out = out.replaceAll(w[i], a[i]);
    }
    return out;
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'دليل القياسات'),
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _introCard(),
            const SizedBox(height: 16),
            _chipsRow(),
            const SizedBox(height: 16),
            for (final part in MeasurementGuideData.parts) ...[
              _partCard(part),
              const SizedBox(height: 26),
            ],
            _upcomingFeatureCard(),
            const SizedBox(height: 22),
            _doneButton(),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('هل تحتاجين مساعدة إضافية؟ تواصل مع أخصائيتك عبر المحادثة',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 11.5)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── بطاقة التعريف + النصائح (بطاقة واحدة) ─────────────────────────────
  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFA6CCC6), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.straighten_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 2),
              const Text('إرشادات أخذ القياسات بدقة', style: AppTextStyles.cardTitle),
              const SizedBox(height: 8),
              Text(
                'الرسوم التوضيحية التالية توضح بدقة المكان الصحيح لوضع شريط القياس لضمان الحصول على قراءات دقيقة ومتسقة تساعد أخصائيتك.',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption.copyWith(height: 1.9),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _lavenderSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'نصائح عامة: قف باسترخاء، تنفس طبيعياً، ولا تشد شريط القياس بقوة على الجلد',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500, height: 1.8),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── شرائح التنقل بين الأقسام ──────────────────────────────────────────
  Widget _chipsRow() {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: MeasurementGuideData.parts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = MeasurementGuideData.parts[i];
          final active = p.key == _selected;
          return GestureDetector(
            onTap: () => _goTo(p.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : _lavender,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  active ? Icons.radio_button_checked_rounded : _partIcon(p.key),
                  size: 16,
                  color: active ? Colors.white : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(p.labelAr,
                    style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? Colors.white : AppColors.textPrimary)),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── بطاقة قسم: الرسم في الأعلى والخطوات في الأسفل ─────────────────────
  Widget _partCard(MeasurementGuidePart part) {
    return Container(
      key: _keys[part.key],
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _GuideIllustration(part: part),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Text('${part.labelAr} (${part.labelEn})',
                    style: AppTextStyles.sectionHeading.copyWith(fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFB6D4D6), borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(part.positionBadge,
                      style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ]),
              const SizedBox(height: 14),
              for (int i = 0; i < part.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: Color(0xFFE3EAFB), shape: BoxShape.circle),
                      child: Center(
                        child: Text(_arabicDigits('${i + 1}'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF3E5A8C))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(part.steps[i].text,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body.copyWith(fontSize: 12, height: 1.9)),
                      ),
                    ),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── ميزة قيد الإعداد ──────────────────────────────────────────────────
  Widget _upcomingFeatureCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: const Color(0xFFDCE5FA), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.smart_display_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ميزة قيد الإعداد',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _teal)),
            const SizedBox(height: 4),
            Text('🎬 قريباً: فيديو إرشادي قصير (١٠ ثوان) لكل قياس لتسهيل المتابعة العملية المباشرة.',
                textAlign: TextAlign.right, style: AppTextStyles.caption.copyWith(height: 1.9)),
          ]),
        ),
      ]),
    );
  }

  // ── زر العودة: الأيقونة يسار النص ─────────────────────────────────────
  Widget _doneButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('فهمت، العودة لتسجيل القياسات'),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline_rounded, size: 20),
          ]),
        ),
      ),
    );
  }
}

/// بطاقة الرسم المتحرك: خلفية أزرق-أخضر هادئ، "تكبير الرسم" أعلى اليسار،
/// ووسم الموضع أسفل اليمين. تبدأ الحركة عند ظهور البطاقة على الشاشة.
class _GuideIllustration extends StatefulWidget {
  final MeasurementGuidePart part;
  const _GuideIllustration({required this.part});

  @override
  State<_GuideIllustration> createState() => _GuideIllustrationState();
}

class _GuideIllustrationState extends State<_GuideIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
  late final Animation<double> _pillAnim = CurvedAnimation(
      parent: _intro, curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic));

  ScrollPosition? _pos;
  bool _played = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pos?.removeListener(_check);
    _pos = Scrollable.maybeOf(context)?.position;
    _pos?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  /// يبدأ الأنيميشن عندما يظهر الرسم على الشاشة لأول مرة.
  void _check() {
    if (_played || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final y = box.localToGlobal(Offset.zero).dy;
    final h = MediaQuery.of(context).size.height;
    if (y < h * 0.85 && y + box.size.height > 0) {
      _played = true;
      _intro.forward();
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _pill({required Widget child, required Offset from}) {
    return FadeTransition(
      opacity: _pillAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: from, end: Offset.zero).animate(_pillAnim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _intro.forward(from: 0), // اضغطي على الرسم لإعادة الحركة
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: const Color(0xFFB3D0D4),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SilhouettePainter(part.key, _intro, _loop),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: _pill(
                from: const Offset(-0.3, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('تكبير الرسم', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                    SizedBox(width: 6),
                    Icon(Icons.zoom_in_rounded, size: 16, color: AppColors.textPrimary),
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: _pill(
                from: const Offset(0.3, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color: const Color(0xFF6B8C90).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: Text(part.cornerHint,
                      style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// الرسم: صور ظلّية مبسّطة (مقطوعة) مع شريط القياس على محيط الجسم
// ═════════════════════════════════════════════════════════════════════════

/// صندوق التصميم: خط المنتصف عند x = designWidth / 2، وكل الإحداثيات أدناه
/// (dx من خط المنتصف، y من أعلى البطاقة) تُكبَّر بنسبة موحّدة لتناسب البطاقة.
const double designHeight = 240;
const double designWidth = 360;

/// حافة واحدة من الجسم: عقد `[y, x]` (x نسبة إلى خط المنتصف) مع استيفاء
/// Hermite التكعيبي لإبقاء الحافة ناعمة بلا زوايا.
class _Contour {
  final List<List<double>> knots;
  const _Contour(this.knots);

  double get top => knots.first[0];
  double get bottom => knots.last[0];

  /// الصورة المعكوسة (للحافة اليسرى من اليمنى).
  _Contour mirrored() => _Contour([
        for (final k in knots) [k[0], -k[1]],
      ]);

  double xAt(double y) {
    if (y <= knots.first[0]) return knots.first[1];
    if (y >= knots.last[0]) return knots.last[1];
    var i = 0;
    while (i < knots.length - 2 && y > knots[i + 1][0]) {
      i++;
    }
    final y0 = knots[i][0], y1 = knots[i + 1][0];
    final x0 = knots[i][1], x1 = knots[i + 1][1];
    final m0 = _slopeAt(i), m1 = _slopeAt(i + 1);
    final h = y1 - y0;
    final t = (y - y0) / h;
    final t2 = t * t, t3 = t2 * t;
    return (2 * t3 - 3 * t2 + 1) * x0 +
        (t3 - 2 * t2 + t) * h * m0 +
        (-2 * t3 + 3 * t2) * x1 +
        (t3 - t2) * h * m1;
  }

  double _slopeAt(int i) {
    final a = i == 0 ? 0 : i - 1;
    final b = i + 1 < knots.length ? i + 1 : i;
    final dy = knots[b][0] - knots[a][0];
    if (dy == 0) return 0;
    return (knots[b][1] - knots[a][1]) / dy;
  }
}

class _Figure {
  final _Contour left;
  final _Contour right;

  /// ارتفاع شريط القياس ونصف قطره الرأسي (إسقاط الحلقة في المنظر الأمامي).
  final double bandY;
  final double bandRy;

  /// خط إرشاد عمودي منقط بجانب الجسم (الفخذ والذراع): موضعه ونهايتاه.
  final double? guideDx;
  final double guideTop;
  final double guideBottom;

  /// خطوط بيضاء قصيرة تمتد خارج الشريط (الخصر).
  final bool extensionLines;

  _Figure({
    required this.left,
    required this.right,
    required this.bandY,
    required this.bandRy,
    this.guideDx,
    this.guideTop = 0,
    this.guideBottom = 0,
    this.extensionLines = false,
  });

  /// جسم متماثل من نصف عرض `[y, half]`.
  factory _Figure.symmetric(
    List<List<double>> half, {
    required double bandY,
    required double bandRy,
    bool extensionLines = false,
  }) {
    final r = _Contour(half);
    return _Figure(left: r.mirrored(), right: r, bandY: bandY, bandRy: bandRy, extensionLines: extensionLines);
  }
}

final Map<String, _Figure> _figures = {
  // الجذع: أكتاف عريضة مقطوعة ← خصر ضيق ← تدرّج نحو الأسفل.
  'waist': _Figure.symmetric(
    const [
      [36, 60], [58, 61], [84, 53], [104, 44], [121, 39],
      [140, 44], [165, 54], [195, 62], [224, 66],
    ],
    bandY: 121,
    bandRy: 10,
    extensionLines: true,
  ),
  // الحوض: عنق ضيق ← خصر ← أعرض نقطة في الحوض ← ساقان.
  'hip': _Figure.symmetric(
    const [
      [39, 46], [60, 40], [94, 30], [115, 40], [135, 58],
      [152, 69], [170, 71], [224, 71],
    ],
    bandY: 156,
    bandRy: 14,
  ),
  // الفخذ: الحافة اليسرى مائلة للداخل، واليمنى شبه مستقيمة.
  'thigh': _Figure(
    left: const _Contour([[29, -70], [60, -62], [95, -50], [122, -47.5], [165, -48], [210, -49.5]]),
    right: const _Contour([[29, 26], [60, 27], [122, 28.5], [210, 28.5]]),
    bandY: 122,
    bandRy: 9,
    guideDx: 50.5,
    guideTop: 40,
    guideBottom: 210,
  ),
  // العضد: قطع علوي مائل، وأسطوانة مدبّبة قليلاً نحو الأسفل.
  'arm': _Figure(
    left: const _Contour([[31, -25.5], [60, -30], [126, -32.5], [211, -32.5]]),
    right: const _Contour([[41, 23.5], [60, 26], [126, 28.5], [160, 25], [211, 21]]),
    bandY: 126,
    bandRy: 7,
    guideDx: -56.5,
    guideTop: 39,
    guideBottom: 211,
  ),
};

class _SilhouettePainter extends CustomPainter {
  final String part;
  final Animation<double> intro; // دخول لمرة واحدة 0 → 1
  final Animation<double> loop; // نبض مستمر 0 → 1

  _SilhouettePainter(this.part, this.intro, this.loop)
      : super(repaint: Listenable.merge([intro, loop]));

  static const Color _fill = Color(0xFFEFF3E8);
  static const Color _tape = Color(0xFF12B886);
  static const Color _tapeFar = Color(0xFFA7C4BC);
  static const Color _mark = Color(0xFFC5D8BE);

  /// جزء من زمن الدخول بين [a] و [b] مع منحنى.
  double _seg(double a, double b, Curve c) =>
      c.transform(((intro.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || intro.value == 0) return;
    final fig = _figures[part] ?? _figures['waist']!;

    final u = math.min(size.width / designWidth, size.height / designHeight);
    final cx = size.width / 2;
    final oy = (size.height - designHeight * u) / 2;
    Offset at(double dx, double y) => Offset(cx + dx * u, oy + y * u);

    // ١) الجسم: ظهور تدريجي مع صعود خفيف.
    final bodyT = _seg(0.0, 0.4, Curves.easeOutCubic);
    canvas.saveLayer(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: bodyT));
    canvas.translate(0, (1 - bodyT) * 14 * u);

    const steps = 90;
    final body = Path();
    Offset onContour(_Contour c, double t) {
      final y = c.top + (c.bottom - c.top) * t;
      return at(c.xAt(y), y);
    }

    final start = onContour(fig.left, 0);
    body.moveTo(start.dx, start.dy);
    for (var i = 1; i <= steps; i++) {
      final p = onContour(fig.left, i / steps);
      body.lineTo(p.dx, p.dy);
    }
    for (var i = 0; i <= steps; i++) {
      final p = onContour(fig.right, 1 - i / steps);
      body.lineTo(p.dx, p.dy);
    }
    body.close();

    canvas.drawPath(body, Paint()..color = _fill);
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * u
        ..strokeJoin = StrokeJoin.round,
    );
    _drawLandmarks(canvas, at, u);
    canvas.restore();

    // ٢) خط الإرشاد ثم الشريط.
    if (fig.guideDx != null) _drawGuide(canvas, fig, at, u);
    _drawBand(canvas, fig, at, u);
  }

  /// علامات تشريحية خفيفة داخل الجسم.
  void _drawLandmarks(Canvas canvas, Offset Function(double, double) at, double u) {
    final soft = Paint()
      ..color = _mark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * u
      ..strokeCap = StrokeCap.round;

    switch (part) {
      case 'waist':
        // السرّة: مثلث صغير أسفل الشريط.
        final a = at(-4, 131), b = at(4, 131), c = at(0, 138);
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(b.dx, b.dy)
            ..lineTo(c.dx, c.dy)
            ..close(),
          Paint()..color = _mark,
        );
        break;
      case 'hip':
        // خط الفصل بين الساقين.
        canvas.drawLine(
          at(0, 191),
          at(0, 224),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2.2 * u
            ..strokeCap = StrokeCap.round,
        );
        break;
      case 'thigh':
        // قوس الركبة.
        final p0 = at(-24, 204), c = at(-2, 213), p1 = at(18, 204);
        canvas.drawPath(Path()..moveTo(p0.dx, p0.dy)..quadraticBezierTo(c.dx, c.dy, p1.dx, p1.dy), soft);
        break;
      case 'arm':
        // قوس العضلة الدالية.
        final p0 = at(-18, 45), c = at(0, 51), p1 = at(16, 47);
        canvas.drawPath(Path()..moveTo(p0.dx, p0.dy)..quadraticBezierTo(c.dx, c.dy, p1.dx, p1.dy), soft);
        break;
    }
  }

  /// خط الإرشاد العمودي: يرسم نفسه من الأعلى للأسفل ثم تظهر النقاط.
  void _drawGuide(Canvas canvas, _Figure fig, Offset Function(double, double) at, double u) {
    final t = _seg(0.15, 0.6, Curves.easeOutCubic);
    if (t <= 0) return;
    final top = at(fig.guideDx!, fig.guideTop);
    final bottom = at(fig.guideDx!, fig.guideBottom);
    _dashPath(
      canvas,
      Path()
        ..moveTo(top.dx, top.dy)
        ..lineTo(bottom.dx, bottom.dy),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u
        ..strokeCap = StrokeCap.round,
      0.1,
      5.5 * u,
      fraction: t,
    );
    final white = Paint()..color = Colors.white;
    canvas.drawCircle(top, 3.4 * u * Curves.easeOutBack.transform(math.min(1, t * 4)), white);
    if (t > 0.9) {
      canvas.drawCircle(bottom, 3.4 * u * Curves.easeOutBack.transform((t - 0.9) * 10), white);
    }
    _centerDot(canvas, at(fig.guideDx!, fig.bandY), u);
  }

  /// النقطة المركزية: تظهر بقفزة مرنة وتنبض بموجة تتسع وتتلاشى.
  void _centerDot(Canvas canvas, Offset c, double u) {
    final s = _seg(0.72, 1.0, Curves.elasticOut);
    if (s <= 0) return;
    final ripple = loop.value;
    canvas.drawCircle(
      c,
      (5.6 + 11 * ripple) * u,
      Paint()
        ..color = AppColors.primary.withValues(alpha: (1 - ripple) * 0.4 * s.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * u,
    );
    canvas.drawCircle(c, 5.6 * u * s, Paint()..color = Colors.white);
    canvas.drawCircle(c, 4.2 * u * s, Paint()..color = AppColors.primary);
  }

  /// الشريط: ينفرد حول الجسم من اليسار عبر الواجهة ثم الخلف، ومعه نقطة بيضاء
  /// تقود طرفه، وتظهر العلامات خلفه تباعاً.
  void _drawBand(Canvas canvas, _Figure fig, Offset Function(double, double) at, double u) {
    final tapeT = _seg(0.3, 0.8, Curves.easeInOutCubic);
    if (tapeT <= 0) return;

    final l = fig.left.xAt(fig.bandY);
    final r = fig.right.xAt(fig.bandY);
    final hw = (r - l) / 2 * u;
    if (hw <= 0.5) return;
    final center = at((l + r) / 2, fig.bandY);
    final ry = fig.bandRy * u;
    final rect = Rect.fromCenter(center: center, width: hw * 2, height: ry * 2);

    final sweep = 2 * math.pi * tapeT;
    final front = math.min(sweep, math.pi);
    final back = math.max(0.0, sweep - math.pi);

    // حلقة بيضاء منقطة تدور ببطء.
    _dashPath(
      canvas,
      Path()..addOval(rect.inflate(4 * u)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * tapeT)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4 * u,
      3 * u,
      3 * u,
      phase: loop.value * 6 * u,
    );

    // الخلفي (العلوي): يبدأ من اليمين ويكمل الدائرة.
    if (back > 0) {
      canvas.drawPath(
        Path()..addArc(rect, 0, -back),
        Paint()
          ..color = _tapeFar
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7 * u,
      );
    }
    // الأمامي (السفلي): الشريط الأخضر.
    canvas.drawPath(
      Path()..addArc(rect, math.pi, -front),
      Paint()
        ..color = _tape
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 9 * u,
    );

    // علامات بيضاء خلف الطرف المتحرك.
    final tickCount = math.max(7, (hw / (5 * u)).round());
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * u;
    for (var i = 1; i < tickCount; i++) {
      final a = math.pi * i / tickCount;
      if (a < math.pi - front) continue;
      final grad = Offset(math.cos(a) / hw, math.sin(a) / ry);
      final n = grad / grad.distance;
      final p = center + Offset(math.cos(a) * hw, math.sin(a) * ry);
      canvas.drawLine(p - n * 3.2 * u, p + n * 3.2 * u, tickPaint);
    }

    // نقطة لامعة تقود طرف الشريط أثناء الانفراد.
    if (tapeT < 1) {
      final th = math.pi - sweep;
      final tip = center + Offset(math.cos(th) * hw, math.sin(th) * ry);
      canvas.drawCircle(tip, 6 * u, Paint()..color = Colors.white.withValues(alpha: 0.35));
      canvas.drawCircle(tip, 3.2 * u, Paint()..color = Colors.white);
    }

    // الخصر: خطوط القياس تمتد للخارج.
    if (fig.extensionLines) {
      final ext = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * u
        ..strokeCap = StrokeCap.round;
      final grow = _seg(0.7, 1.0, Curves.easeOutCubic);
      for (final dir in const [-1.0, 1.0]) {
        final edge = center.dx + dir * hw;
        final outer = edge + dir * 16 * u * grow;
        canvas.drawLine(Offset(edge, center.dy), Offset(outer, center.dy), ext);
        if (grow > 0.95) {
          canvas.drawLine(Offset(outer, center.dy - 3 * u), Offset(outer, center.dy + 3 * u), ext);
        }
      }
    }

    // الخصر والورك: النقطة الداكنة في مركز الشريط.
    if (fig.guideDx == null) _centerDot(canvas, center, u);
  }

  /// [fraction] لرسم جزء من المسار فقط، و[phase] لإزاحة النقاط (حركة مستمرة).
  void _dashPath(Canvas canvas, Path path, Paint paint, double dash, double gap,
      {double fraction = 1.0, double phase = 0}) {
    for (final m in path.computeMetrics()) {
      final limit = m.length * fraction;
      var d = -phase;
      while (d < limit) {
        final s = math.max(0.0, d);
        final e = math.min(d + dash, limit);
        if (e > s) canvas.drawPath(m.extractPath(s, e), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter old) => old.part != part;
}