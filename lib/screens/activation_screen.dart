import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import '../widgets/password_strength_meter.dart';
import 'health_data_consent_screen.dart';
import '../core/navigation/app_page_route.dart';

/// The very first screen a clinic-invited patient sees after tapping the
/// link their specialist sent them (POST /invites/{token}/activate): the
/// clinic has already entered the patient's basic details, so the only
/// input left here is choosing a password before the health-data wizard
/// (Measurements → Health Data → Notifications) begins.
class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  PasswordStrength get _strength => evaluatePasswordStrength(_password.text);

  bool get _hasMinLength => _password.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password.text);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_password.text);
  bool get _passwordsMatch => _confirm.text.isNotEmpty && _confirm.text == _password.text;

  bool get _canActivate => _hasMinLength && _hasUppercase && _hasDigit && _passwordsMatch;

  void _activate() {
    Navigator.of(context).pushReplacement(AppPageRoute(builder: (_) => const HealthDataConsentScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            children: [
              const _LinkStatusBar(),
              const SizedBox(height: 24),
              Center(
                child: Column(children: [
                  Image.asset('assets/images/logo.png', height: 56),
                  const SizedBox(height: 14),
                  const Text('مرحباً بك في HealthyLife', style: AppTextStyles.h1, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  const Text('فعّلي وصولك الفوري إلى برنامج الرعاية السريرية', textAlign: TextAlign.center, style: AppTextStyles.secondary),
                ]),
              ),
              const SizedBox(height: 22),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                child: IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // الشريط الأخضر على الحافة اليمنى (أول عنصر في RTL)
                    Container(width: 4, color: AppColors.primary),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const _SpecialistAvatar(),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  const Text('أ. خلود العربي', style: AppTextStyles.cardTitle),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                                    child: const Text('معتمدة', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                const Text('أخصائية التغذية العلاجية وإدارة الأيض', style: AppTextStyles.caption),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.cardSmall)),
                            child: const Text(
                              'تمت دعوتك بواسطة أخصائيتك أ. خلود العربي لربط ملفك الصحي وبدء خطتك الغذائية العلاجية المخصصة مباشرة.',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(children: [
                            Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 6),
                            Expanded(child: Text('تم إدخال بياناتك الأساسية مسبقاً من قبل العيادة', style: AppTextStyles.caption)),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              const Align(alignment: AlignmentDirectional.centerStart, child: Text('كلمة المرور الجديدة', style: AppTextStyles.body)),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _password,
                obscure: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              const Align(alignment: AlignmentDirectional.centerStart, child: Text('تأكيد كلمة المرور', style: AppTextStyles.body)),
              const SizedBox(height: 8),
              _PasswordField(
                controller: _confirm,
                obscure: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                matchIndicator: _confirm.text.isEmpty ? null : _passwordsMatch,
              ),
              const SizedBox(height: 20),
              PasswordStrengthMeter(strength: _strength),
              const SizedBox(height: 14),
              _RuleRow(label: '8 أحرف أو أكثر', met: _hasMinLength),
              _RuleRow(label: 'حرف كبير واحد على الأقل (A-Z)', met: _hasUppercase),
              _RuleRow(label: 'رقم واحد على الأقل (0-9)', met: _hasDigit),
              const SizedBox(height: 24),
              GradientCtaButton(label: 'تفعيل الحساب وبدء الخطة', onPressed: _canActivate ? _activate : null),
              const SizedBox(height: 10),
              const Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textSecondary),
                  SizedBox(width: 6),
                  Text('بياناتك الصحية مشفرة ومحمية وفق لوائح الامتثال الطبي', style: AppTextStyles.caption),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شريط حالة الرابط في أعلى الشاشة (عرض فقط).
class _LinkStatusBar extends StatelessWidget {
  const _LinkStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text('رابط ساري وعامل', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text('رابط منتهٍ / مُستخدم', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// صورة الأخصائية مع شارة التوثيق. ضعي الصورة في assets/images/specialist.png
/// (ولو مش موجودة بيظهر الأيقونة القديمة تلقائياً).
class _SpecialistAvatar extends StatelessWidget {
  const _SpecialistAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(clipBehavior: Clip.none, children: [
        ClipOval(
          child: Image.asset(
            'assets/images/specialist.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              color: AppColors.primaryTint,
              child: const Icon(Icons.person_rounded, color: AppColors.primary),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
            child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool? matchIndicator;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.matchIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(builder: (ctx) {
        final focused = Focus.of(ctx).hasFocus;
        final Color borderColor = matchIndicator == false
            ? AppColors.danger
            : (focused || matchIndicator == true)
                ? AppColors.primary
                : AppColors.border;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.cardSmall),
            border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
          ),
          // في RTL: أول عنصر يمين → النص يمين، المؤشر ثم العين على اليسار
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                textAlign: TextAlign.right,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                ),
              ),
            ),
            if (matchIndicator != null)
              Icon(
                matchIndicator! ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 18,
                color: matchIndicator! ? AppColors.primary : AppColors.danger,
              ),
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textSecondary),
            ),
          ]),
        );
      }),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool met;
  const _RuleRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(met ? Icons.check_circle_rounded : Icons.circle_outlined, size: 15, color: met ? AppColors.primary : AppColors.iconMuted),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: met ? AppColors.textPrimary : AppColors.textSecondary)),
      ]),
    );
  }
}