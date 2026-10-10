import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart' show AppHeaderBar;
import '../../core/navigation/logout_flow.dart';

/// حول التطبيق — هوية التطبيق، قائمة الشفافية والمعايير الطبية،
/// وإجراء تسجيل الخروج (نفس إجراء شاشة الحساب).
class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _loop;

  late final Animation<double> _hero;
  late final Animation<double> _medicalLabel;
  late final Animation<double> _legal;
  late final Animation<double> _protection;
  late final Animation<double> _sessionLabel;
  late final Animation<double> _sessionNote;
  late final Animation<double> _logout;
  late final Animation<double> _footer;

  Animation<double> _iv(double begin, double end, [Curve curve = Curves.easeOutCubic]) {
    return CurvedAnimation(parent: _enter, curve: Interval(begin, end, curve: curve));
  }

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250))..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();

    _hero = _iv(0.00, 0.42, Curves.easeOutBack);
    _medicalLabel = _iv(0.18, 0.46);
    _legal = _iv(0.24, 0.58);
    _protection = _iv(0.36, 0.70);
    _sessionLabel = _iv(0.48, 0.78);
    _sessionNote = _iv(0.56, 0.86);
    _logout = _iv(0.66, 0.94);
    _footer = _iv(0.76, 1.00);
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeaderBar(title: 'حول التطبيق'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _AboutReveal(
              animation: _hero,
              dy: 0.10,
              child: _IdentityHero(loop: _loop),
            ),
            const SizedBox(height: 20),
            _AboutReveal(
              animation: _medicalLabel,
              child: const _SectionLabel(
                title: 'الشفافية والمعايير الطبية',
                trailing: 'لوائح معتمدة',
              ),
            ),
            const SizedBox(height: 10),
            _AboutReveal(animation: _legal, dy: 0.12, child: const _LegalCard()),
            const SizedBox(height: 14),
            _AboutReveal(animation: _protection, dy: 0.12, child: const _StandardProtectionCard()),
            const SizedBox(height: 22),
            _AboutReveal(
              animation: _sessionLabel,
              child: const _SectionLabel(
                title: 'منطقة الجلسة والحساب',
                titleColor: AppColors.danger,
              ),
            ),
            const SizedBox(height: 10),
            _AboutReveal(animation: _sessionNote, dy: 0.12, child: const _SessionNote()),
            const SizedBox(height: 10),
            _AboutReveal(
              animation: _logout,
              dy: 0.14,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () => performLogoutFlow(context),
                  child: const Text('تسجيل الخروج'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _AboutReveal(
              animation: _footer,
              dy: 0.08,
              child: const Center(
                child: Text(
                  'HealthyLife Clinical Suite © 2026 • جميع الحقوق محفوظة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutReveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double dy;

  const _AboutReveal({
    required this.animation,
    required this.child,
    this.dy = 0.08,
  });

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

/// بطاقة الهوية: توهج أخضر فاتح، مربع الشعار مع الشارة، الاسم، الشعار
/// النصي، كبسولة الإصدار، وصندوق الوصف.
class _IdentityHero extends StatelessWidget {
  final Animation<double> loop;

  const _IdentityHero({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -70,
              child: AnimatedBuilder(
                animation: loop,
                builder: (context, child) {
                  final pulse = 0.92 + 0.08 * math.sin(loop.value * 2 * math.pi);
                  return Transform.scale(scale: pulse, child: child);
                },
                child: const _GlowBlob(size: 200),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -70,
              child: AnimatedBuilder(
                animation: loop,
                builder: (context, child) {
                  final pulse = 0.94 + 0.06 * math.sin((loop.value * 2 * math.pi) + math.pi);
                  return Transform.scale(scale: pulse, child: child);
                },
                child: const _GlowBlob(size: 190),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _LogoPlate(loop: loop),
                  const SizedBox(height: 16),
                  const Text(
                    'HealthyLife',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      height: 1.25,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'حياة صحية',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pillLabel.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'منصة المتابعة والتغذية العلاجية للمرضى',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'الإصدار 1.0.0 (Build 240)',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    ),
                    child: const Text(
                      'تطبيق معتمد ومصمم لدعمك بالتعاون المباشر مع أخصائيك المعتمدة لتحقيق أهدافك الصحية المستدامة.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دائرة توهج ناعمة (تدرج شعاعي أخضر فاتح إلى شفاف).
class _GlowBlob extends StatelessWidget {
  final double size;
  const _GlowBlob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFB8F0DF).withValues(alpha: 0.60),
            const Color(0xFFB8F0DF).withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// مربع الشعار الأبيض المدوّر بظل خفيف مع شارة خضراء صغيرة أسفله على اليسار.
class _LogoPlate extends StatelessWidget {
  final Animation<double> loop;

  const _LogoPlate({required this.loop});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loop,
      builder: (context, _) {
        final glow = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi);
        return Transform.scale(
          scale: 1 + 0.018 * glow,
          child: SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05 + 0.05 * glow),
                        blurRadius: 18 + 5 * glow,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  left: -6,
                  bottom: -6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// عنوان القسم: العنوان على اليمين، والنص الجانبي (اختياري) على اليسار.
class _SectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;
  final Color? titleColor;

  const _SectionLabel({
    required this.title,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionHeading.copyWith(
              color: titleColor,
              fontSize: 13,
            ),
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _LegalItem {
  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String subtitle;

  const _LegalItem({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.subtitle,
  });
}

/// بطاقة واحدة تضم صفوف الشفافية والخصوصية بينها فواصل.
class _LegalCard extends StatelessWidget {
  const _LegalCard();

  static const List<_LegalItem> _items = [
    _LegalItem(
      icon: Icons.health_and_safety_outlined,
      iconColor: Color(0xFF0E7C86),
      tint: Color(0xFFE3F5F7),
      title: 'سياسة الخصوصية وأمان البيانات الصحية',
      subtitle: 'تشفير سريري عالي المستوى لملفك الغذائي',
    ),
    _LegalItem(
      icon: Icons.description_outlined,
      iconColor: Color(0xFF3E5A8C),
      tint: Color(0xFFE9EFFA),
      title: 'الشروط والأحكام الطبية',
      subtitle: 'إرشادات متابعة خطط الرعاية الصحية',
    ),
    _LegalItem(
      icon: Icons.verified_outlined,
      iconColor: Color(0xFF1E9E6A),
      tint: Color(0xFFE0F6EC),
      title: 'تراخيص الهيئة الطبية والاعتماد',
      subtitle: 'سجل الامتثال الطبي الموثق رقم #A-8841',
    ),
    _LegalItem(
      icon: Icons.headset_mic_outlined,
      iconColor: Color(0xFF5B52B0),
      tint: Color(0xFFECEAFA),
      title: 'الدعم الفني ومساعدة التطبيق',
      subtitle: 'مساعدة متواصلة للاستفسارات التقنية',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 14,
                endIndent: 14,
                color: AppColors.hairline,
              ),
            _LegalRow(item: _items[i]),
          ],
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final _LegalItem item;
  const _LegalRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// بطاقة "حماية صحية قياسية" بخلفية لافندر فاتحة.
class _StandardProtectionCard extends StatelessWidget {
  const _StandardProtectionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FC),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFA8CFD0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حماية صحية قياسية',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'بياناتك مشفرة ومحمية وفق معايير الخصوصية الصحية المعتمدة لمزامنة آمنة مع ملفك السريري.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ملاحظة إنهاء الجلسة: أيقونة حمراء فاتحة ونص الشرح.
class _SessionNote extends StatelessWidget {
  const _SessionNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3E3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_backup_restore_rounded,
              color: AppColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'سيتم إنهاء جلستك بأمان، مع الاحتفاظ بجميع سجلاتك وقياساتك في السجلات الطبية دون أي فقدان للبيانات.',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}
