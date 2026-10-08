import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../core/navigation/app_page_route.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/confirm_action_sheet.dart';
import 'onboarding_measurements_screen.dart';
import 'privacy_document_screen.dart';

class _ConsentClause {
  final IconData icon;
  final String question;
  final String answer;
  const _ConsentClause(this.icon, this.question, this.answer);
}

/// The legal/clinical gate between activation and the health-data wizard:
/// a patient cannot reach measurements, conditions, or medications until
/// they've explicitly reviewed what's collected and agreed to it. This
/// mirrors informed-consent flows required by real HIPAA-style clinical
/// products — not just a decorative screen.
class HealthDataConsentScreen extends StatefulWidget {
  const HealthDataConsentScreen({super.key});

  @override
  State<HealthDataConsentScreen> createState() => _HealthDataConsentScreenState();
}

class _HealthDataConsentScreenState extends State<HealthDataConsentScreen> {
  int? _expandedIndex = 0;
  bool _agreed = false;

  static const List<_ConsentClause> _clauses = [
    _ConsentClause(
      Icons.lock_outline_rounded,
      'كيف تُحفظ بياناتك الصحية؟',
      'تشفير كامل وفق أعلى معايير الخصوصية الصحية السريرية (HIPAA standards). تُخزَّن السجلات على خوادم طبية معزولة لا يمكن لأي طرف ثالث أو شركة إعلانات الوصول إليها تحت أي ظرف.',
    ),
    _ConsentClause(
      Icons.medical_services_outlined,
      'من يمكنه الاطلاع عليها؟',
      'أخصائية التغذية العلاجية المعتمدة على حسابك فقط، عبر نظام مراجعة سريري مشفر. لا تُشارك بياناتك مع أي جهة أخرى، ولا تُستخدم لأي غرض تسويقي.',
    ),
    _ConsentClause(
      Icons.person_remove_alt_1_outlined,
      'حقك الكامل في إلغاء الموافقة',
      'يمكنك سحب موافقتك في أي وقت من الحساب ← الخصوصية. سيؤدي ذلك إلى إيقاف تخصيص الخطة الغذائية تلقائياً حتى تجديد الموافقة، دون التأثير على سجلاتك المحفوظة.',
    ),
  ];

  Future<void> _confirmExit() async {
    final confirmed = await ConfirmActionSheet.show(
      context,
      icon: Icons.privacy_tip_outlined,
      title: 'الخروج من إعداد ملفك الصحي؟',
      message: 'لن تتمكني من متابعة رحلتك العلاجية أو الوصول لخطتك الغذائية قبل الموافقة على شروط الخصوصية الصحية.',
      confirmLabel: 'الخروج الآن',
      cancelLabel: 'متابعة الموافقة',
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  void _continue() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const OnboardingMeasurementsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(children: [
            _ConsentHeader(onBack: _confirmExit, onClose: _confirmExit),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ===== الجزء العلوي الجديد (Hero) =====
                  const _ConsentHero(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Reveal(
                          delay: Duration(milliseconds: 900),
                          child: _EncryptionBanner(),
                        ),
                        const SizedBox(height: 16),
                        _Reveal(
                          delay: const Duration(milliseconds: 1050),
                          child: _buildCharterCard(),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          const Expanded(child: Text('بنود الخصوصية ومسؤولية الحفظ', style: AppTextStyles.sectionHeading)),
                          Text('${_clauses.length} بنود رئيسية', style: AppTextStyles.caption),
                        ]),
                        const SizedBox(height: 12),
                        for (int i = 0; i < _clauses.length; i++) _buildClause(i),
                        const SizedBox(height: 8),
                        _AgreementCheckRow(
                          checked: _agreed,
                          onChanged: (v) => setState(() => _agreed = v),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          InkWell(
                            onTap: () => Navigator.of(context).push(AppPageRoute(builder: (_) => const PrivacyDocumentScreen())),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text('قراءة وثيقة الخصوصية السريرية الكاملة', style: AppTextStyles.pillLabel),
                                SizedBox(width: 6),
                                // arrow_forward بينعكس تلقائياً في RTL ويشاور لليسار
                                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                              ]),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          const Text('موثّق', style: AppTextStyles.caption),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: Column(children: [
                GradientCtaButton(label: 'متابعة إعداد خطتي الصحية', onPressed: _agreed ? _continue : null),
                if (!_agreed) ...[
                  const SizedBox(height: 8),
                  const Text('يُرجى الموافقة على الشروط السريرية للمتابعة', style: AppTextStyles.caption),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCharterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryTint.withAlpha(90),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withAlpha(50)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Text('ميثاق الخصوصية التغذوية', style: AppTextStyles.sectionHeading)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('موثّق سري', style: TextStyle(fontSize: 10, color: AppColors.primary)),
          ),
        ]),
        const SizedBox(height: 10),
        const Text(
          'بياناتك (سجل الوجبات، القياسات، والحالة الصحية) تصل لأخصائيتك فقط وتُستخدم لبناء خطتك الغذائية ومتابعة تقدمك السريري بأمان.',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
          child: const Row(children: [
            Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text('مشفّرة بنظام bit-256 ومتوافقة مع المعايير الصحية السريرية (HIPAA).', style: AppTextStyles.caption)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildClause(int index) {
    final clause = _clauses[index];
    final bool expanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expandedIndex = expanded ? null : index),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(10)),
              child: Icon(clause.icon, color: AppColors.primary, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(clause.question, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
            Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.textSecondary, size: 20),
          ]),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(clause.answer, style: AppTextStyles.caption.copyWith(height: 1.6)),
          ),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
          sizeCurve: Curves.easeOutCubic,
        ),
      ]),
    );
  }
}

/// الهيدر: (رجوع + عنوان) يميناً، (إغلاق + حساب) يساراً. الرجوع والإغلاق
/// كلاهما يمرّان عبر حوار التأكيد لأن الموافقة شرط للمتابعة.
class _ConsentHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  const _ConsentHeader({required this.onBack, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(children: [
        InkResponse(
          onTap: onBack,
          radius: 22,
          // arrow_back بينعكس تلقائياً في RTL ويصير يشاور لليمين
          child: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'الموافقة على استخدام البيانات الصحية',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
          ),
        ),
        InkResponse(
          onTap: onClose,
          radius: 20,
          child: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.person_outline_rounded, size: 17, color: Colors.white),
        ),
      ]),
    );
  }
}

/// ظهور تدريجي (fade + slide للأعلى) بعد تأخير معين. بنستخدمه عشان
/// عناصر الشاشة تدخل واحد ورا التاني بشكل ناعم.
class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _Reveal({required this.child, this.delay = Duration.zero});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - _curve.value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// الجزء العلوي المعاد تصميمه: خلفية متدرجة ناعمة + دوائر زخرفية +
/// درع متحرك فيه علامة صح + الشارة والعنوان والوصف بظهور متتابع.
class _ConsentHero extends StatelessWidget {
  const _ConsentHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryTint.withAlpha(150), AppColors.background],
        ),
      ),
      child: Stack(children: [
        // دوائر زخرفية خفيفة في الخلفية
        Positioned(
          top: -40,
          right: -30,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withAlpha(14)),
          ),
        ),
        Positioned(
          top: 70,
          left: -45,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentGreen.withAlpha(18)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(children: [
            const _ShieldHero(),
            const SizedBox(height: 6),
            _Reveal(
              delay: const Duration(milliseconds: 450),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withAlpha(22), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'منظومة الحماية السريرية الذكية',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
              ),
            ),
            const SizedBox(height: 18),
            const _Reveal(
              delay: Duration(milliseconds: 600),
              child: Text('قبل أن نبدأ رحلتك الصحية', textAlign: TextAlign.center, style: AppTextStyles.h1),
            ),
            const SizedBox(height: 10),
            const _Reveal(
              delay: Duration(milliseconds: 750),
              child: Text(
                'نحن نلتزم بحماية خصوصية بياناتك الصحية والسريرية بأقصى درجات الشفافية والأمان.',
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// الدرع المتحرك:
/// 1) الدرع يظهر بحركة نبضة (scale)
/// 2) علامة الصح بتترسم جوا الدرع خط بخط
/// 3) أيقونة القفل تطلع بحركة ارتداد صغيرة
/// 4) دوائر موجية (ripple) بتفضل تنبض حوالين الدرع بشكل مستمر
class _ShieldHero extends StatefulWidget {
  const _ShieldHero();

  @override
  State<_ShieldHero> createState() => _ShieldHeroState();
}

class _ShieldHeroState extends State<_ShieldHero> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final Animation<double> _shieldScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _shieldScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack)),
    );
    _checkProgress = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOutCubic),
    );
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entrance, curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack)),
    );

    _entrance.forward();
    _pulse.repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Widget _ripple(double offset) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final double t = (_pulse.value + offset) % 1.0;
        final double size = 92 + 58 * t;
        final int alpha = (70 * (1 - t)).round();
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentGreen.withAlpha(alpha),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(alignment: Alignment.center, children: [
        _ripple(0.0),
        _ripple(0.5),
        ScaleTransition(
          scale: _shieldScale,
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.accentGreenBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 3),
                boxShadow: [
                  BoxShadow(color: AppColors.accentGreen.withAlpha(60), blurRadius: 22, offset: const Offset(0, 8)),
                ],
              ),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.shield_rounded, color: AppColors.accentGreen, size: 56),
                // علامة الصح بتترسم جوا الدرع
                Transform.translate(
                  offset: const Offset(0, -1),
                  child: AnimatedBuilder(
                    animation: _checkProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(26, 26),
                        painter: _CheckPainter(progress: _checkProgress.value),
                      );
                    },
                  ),
                ),
              ]),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ScaleTransition(
                scale: _badgeScale,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2.5),
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// بيرسم علامة صح بيضاء، وبيزوّد طولها حسب progress (من 0 إلى 1)
class _CheckPainter extends CustomPainter {
  final double progress;
  const _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Path full = Path()
      ..moveTo(size.width * 0.14, size.height * 0.54)
      ..lineTo(size.width * 0.40, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.26);

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path partial = Path();
    for (final metric in full.computeMetrics()) {
      partial.addPath(metric.extractPath(0, metric.length * math.min(progress, 1.0)), Offset.zero);
    }
    canvas.drawPath(partial, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) => oldDelegate.progress != progress;
}

/// صورة الرعاية مع شريط التشفير فوقها (بدل البطاقة المنفصلة السابقة).
/// ضعي الصورة في assets/images/consent_care.jpg وسجّليها في pubspec.yaml؛
/// لو مش موجودة بيظهر خلفية بلون الـ theme بدون أخطاء.
class _EncryptionBanner extends StatelessWidget {
  const _EncryptionBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AspectRatio(
        aspectRatio: 2.3,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/consent_care.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primaryTint,
              child: const Icon(Icons.health_and_safety_rounded, size: 48, color: AppColors.primary),
            ),
          ),
          // تدرّج داكن من الأسفل لقراءة النص
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black.withAlpha(170), Colors.black.withAlpha(0)],
              ),
            ),
          ),
          const Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Row(children: [
              Icon(Icons.enhanced_encryption_rounded, size: 16, color: AppColors.accentGreen),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بياناتك الطبية مشفرة بنظام bit AES-256 من لحظة إدخالها',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _AgreementCheckRow extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  const _AgreementCheckRow({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: checked ? AppColors.primaryTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: checked ? AppColors.primary : AppColors.border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: checked ? AppColors.primary : Colors.transparent,
              border: Border.all(color: checked ? AppColors.primary : AppColors.iconMuted, width: 1.4),
            ),
            child: checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 15) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'قرأت ووافقت على شروط مشاركة البيانات بسياسة الخصوصية الصحية.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.5),
              ),
              const SizedBox(height: 4),
              const Text(
                'موافقتك قابلة للتعديل أو الإلغاء فوراً في أي وقت.',
                style: AppTextStyles.caption,
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}