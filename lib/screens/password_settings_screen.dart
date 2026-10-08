import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';

// ───────────────────────── الألوان (مطابقة للصورة) ─────────────────────────
const Color _teal = Color(0xFF00636E);
const Color _mint = Color(0xFF3DDBB0);
const Color _success = Color(0xFF12A37F);
const Color _lavender = Color(0xFFF3F6FC);
const Color _track = Color(0xFFDCE3F4);
const Color _cardBorder = Color(0xFFEDF0F6);
const Color _fieldBorder = Color(0xFFDDE2EC);
const Color _pageBg = Color(0xFFFBFCFE);
const Color _warnRed = Color(0xFFEF5B5B);
const Color _warnOrange = Color(0xFFF5A524);

/// كلمة المرور — نموذج تغيير كلمة المرور مع مقياس قوة وقائمة شروط،
/// مطابق للتصميم المعتمد مع أنيميشن متتابع وتفاعلي.
class PasswordSettingsScreen extends StatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen>
    with TickerProviderStateMixin {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  bool _saved = false;

  // أنيميشن الدخول المتتابع
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  late final List<Animation<double>> _stagger = List.generate(7, (i) {
    final start = i * 0.1;
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(start, math.min(1.0, start + 0.4),
          curve: Curves.easeOutCubic),
    );
  });

  // أنيميشن اهتزاز الزر عند وجود نقص في البيانات
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _shake.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ───────────────────────── منطق التحقق ─────────────────────────
  bool get _hasMinLength => _newController.text.length >= 8;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_newController.text);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_newController.text);
  bool get _hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newController.text);
  bool get _matches =>
      _newController.text.isNotEmpty &&
      _newController.text == _confirmController.text;
  bool get _canSubmit =>
      _currentController.text.isNotEmpty &&
      _hasMinLength &&
      _hasUpper &&
      _hasDigit &&
      _hasSpecial &&
      _matches;

  /// درجة القوة من 0 إلى 4 (عدد الشروط المتحققة)
  int get _score =>
      (_hasMinLength ? 1 : 0) +
      (_hasUpper ? 1 : 0) +
      (_hasDigit ? 1 : 0) +
      (_hasSpecial ? 1 : 0);

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: success ? _teal : AppColors.danger,
          content: Text(message, textAlign: TextAlign.right),
        ),
      );
  }

  Future<void> _savePassword() async {
    if (_saving || _saved) return;

    if (!_canSubmit) {
      final missing = <String>[
        if (_currentController.text.isEmpty) 'أدخلي كلمة المرور الحالية',
        if (!_hasMinLength) 'اجعلي كلمة المرور 8 أحرف على الأقل',
        if (!_hasUpper) 'أضيفي حرفًا كبيرًا واحدًا على الأقل',
        if (!_hasDigit) 'أضيفي رقمًا واحدًا على الأقل',
        if (!_hasSpecial) 'أضيفي رمزًا خاصًا واحدًا على الأقل',
        if (!_matches) 'أكدي كلمة المرور الجديدة بشكل مطابق',
      ];
      HapticFeedback.mediumImpact();
      _shake.forward(from: 0);
      _showSnack(missing.first);
      return;
    }

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _saving = false;
      _saved = true;
    });
    _showSnack('تم حفظ كلمة المرور بنجاح', success: true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).maybePop();
  }

  void _forgotPassword() {
    _showSnack(
      'سيتم إرسال رابط استعادة كلمة المرور إلى رقمك أو بريدك المسجل',
      success: true,
    );
  }

  // ───────────────────────── عناصر مساعدة ─────────────────────────

  /// يلف أي عنصر بأنيميشن ظهور (تلاشي + انزلاق للأعلى) حسب ترتيبه.
  Widget _reveal(int index, Widget child) {
    final anim = _stagger[index];
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  /// بطاقة بيضاء بإطار رفيع وظل خفيف.
  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D1B2B4B),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          style: AppTextStyles.sectionHeading.copyWith(fontSize: 14),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppHeaderBar(title: 'كلمة المرور'),
        backgroundColor: _pageBg,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // ── بطاقة الحماية ──────────────────────────────────────
              _reveal(0, _SecurityHero(ready: _canSubmit)),
              const SizedBox(height: 16),

              // ── كلمة المرور الحالية ────────────────────────────────
              _reveal(
                1,
                _card(children: [
                  Row(
                    children: [
                      Text(
                        'كلمة المرور الحالية',
                        style:
                            AppTextStyles.sectionHeading.copyWith(fontSize: 14),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _forgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: AppTextStyles.pillLabel
                              .copyWith(fontSize: 12, color: _teal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _currentController,
                    visibilityKey:
                        const ValueKey('password-visibility-current'),
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // ── الجديدة + مقياس القوة + التأكيد (بطاقة واحدة) ─────
              _reveal(
                2,
                _card(children: [
                  _label('كلمة المرور الجديدة'),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _newController,
                    visibilityKey: const ValueKey('password-visibility-new'),
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  _StrengthMeter(score: _score),
                  const SizedBox(height: 22),
                  _label('تأكيد كلمة المرور الجديدة'),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _confirmController,
                    visibilityKey:
                        const ValueKey('password-visibility-confirm'),
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    onChanged: (_) => setState(() {}),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _confirmController.text.isEmpty
                          ? const SizedBox(
                              key: ValueKey('no-message'),
                              width: double.infinity,
                            )
                          : Padding(
                              key: ValueKey(_matches),
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  TweenAnimationBuilder<double>(
                                    key: ValueKey('icon-$_matches'),
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 550),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) =>
                                        Transform.scale(
                                            scale: value, child: child),
                                    child: Icon(
                                      _matches
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.error_outline_rounded,
                                      size: 18,
                                      color: _matches
                                          ? _teal
                                          : AppColors.danger,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _matches
                                          ? 'تطابق كلمة المرور الجديدة تماماً'
                                          : 'كلمتا المرور غير متطابقتين',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 12,
                                        color: _matches
                                            ? _teal
                                            : AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // ── شروط كلمة المرور ───────────────────────────────────
              _reveal(
                3,
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _lavender,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          'شروط كلمة المرور:',
                          style:
                              AppTextStyles.cardTitle.copyWith(fontSize: 15),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _RequirementRow(
                          met: _hasMinLength, label: '٨ أحرف على الأقل'),
                      _RequirementRow(
                          met: _hasUpper,
                          label: 'حرف كبير واحد على الأقل (A-Z)'),
                      _RequirementRow(
                          met: _hasDigit, label: 'رقم واحد على الأقل (0-9)'),
                      _RequirementRow(
                        met: _hasSpecial,
                        label: 'رمز خاص واحد على الأقل (!@#\$%)',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── زر الحفظ (مع اهتزاز عند الخطأ) ────────────────────
              _reveal(
                4,
                AnimatedBuilder(
                  animation: _shake,
                  builder: (context, child) {
                    final dx = math.sin(_shake.value * math.pi * 6) *
                        10 *
                        (1 - _shake.value);
                    return Transform.translate(
                        offset: Offset(dx, 0), child: child);
                  },
                  child: _AnimatedCta(
                    ready: _canSubmit,
                    saving: _saving,
                    saved: _saved,
                    onPressed: (_saving || _saved) ? null : _savePassword,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── ملاحظة أسفل الصفحة ─────────────────────────────────
              _reveal(
                5,
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.verified_user_rounded,
                            size: 20, color: _success),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'بعد تغيير كلمة المرور بنجاح، سيتم تسجيل خروجك من الأجهزة الأخرى تلقائياً لحماية حسابك الطبي وصحتك.',
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 12, height: 1.7),
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

// ═════════════════════════ بطاقة الحماية ═════════════════════════

class _SecurityHero extends StatefulWidget {
  final bool ready;

  const _SecurityHero({required this.ready});

  @override
  State<_SecurityHero> createState() => _SecurityHeroState();
}

class _SecurityHeroState extends State<_SecurityHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = widget.ready ? _success : _teal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _lavender,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // حلقة نبض تتوسع وتتلاشى
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final t = _pulse.value;
                    return Opacity(
                      opacity: (1 - t) * 0.5,
                      child: Transform.scale(
                        scale: 0.85 + 0.4 * t,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: ringColor, width: 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.ready
                        ? const Color(0xFFD8F5EA)
                        : const Color(0xFFE0ECEF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: Tween<double>(begin: -0.25, end: 0.0)
                          .animate(anim),
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: Icon(
                      widget.ready
                          ? Icons.check_circle_rounded
                          : Icons.verified_user_rounded,
                      key: ValueKey(widget.ready),
                      color: ringColor,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  'حماية الحساب والبيانات الصحية',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text(
                  'احرص على اختيار كلمة مرور قوية وغير مكررة لضمان خصوصية خطتك وسجلاتك الصحية.',
                  style:
                      AppTextStyles.caption.copyWith(fontSize: 12.5, height: 1.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════ مقياس القوة ═════════════════════════

class _StrengthMeter extends StatelessWidget {
  final int score; // من 0 إلى 4

  const _StrengthMeter({required this.score});

  static const List<String> _labels = [
    'أدخل كلمة المرور',
    'ضعيفة',
    'متوسطة',
    'جيدة ومقبولة',
    'قوية جداً',
  ];

  @override
  Widget build(BuildContext context) {
    final barColors = <Color>[_track, _warnRed, _warnOrange, _mint, _success];
    final textColors = <Color>[
      AppColors.textSecondary,
      _warnRed,
      _warnOrange,
      _teal,
      _teal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'قوة كلمة المرور:',
              style: AppTextStyles.caption
                  .copyWith(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                _labels[score],
                key: ValueKey(score),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColors[score],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(4, (i) {
            final filled = i < score;
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: _track),
                        AnimatedFractionallySizedBox(
                          // كل شريط يمتلئ بعد الذي قبله بقليل (تموّج)
                          duration:
                              Duration(milliseconds: 300 + (i * 90)),
                          curve: Curves.easeOutCubic,
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: filled ? 1.0 : 0.0,
                          heightFactor: 1.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            color: barColors[score],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═════════════════════════ زر الحفظ ═════════════════════════

class _AnimatedCta extends StatefulWidget {
  final bool ready;
  final bool saving;
  final bool saved;
  final VoidCallback? onPressed;

  const _AnimatedCta({
    required this.ready,
    required this.saving,
    required this.saved,
    required this.onPressed,
  });

  @override
  State<_AnimatedCta> createState() => _AnimatedCtaState();
}

class _AnimatedCtaState extends State<_AnimatedCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  bool _pressed = false;

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  Widget _content() {
    if (widget.saving) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    if (widget.saved) {
      return Row(
        key: const ValueKey('saved'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تم الحفظ',
            style: AppTextStyles.cardTitle
                .copyWith(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
        ],
      );
    }
    return Row(
      key: const ValueKey('idle'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'حفظ كلمة المرور',
          style: AppTextStyles.cardTitle
              .copyWith(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.saved ? _success : _teal;
    final showShine = widget.ready && !widget.saving && !widget.saved;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 58,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: widget.ready ? 0.35 : 0.15),
                blurRadius: widget.ready ? 22 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // لمعان يمر على الزر عند اكتمال الشروط
                if (showShine)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (context, child) {
                        final t = Curves.easeInOut.transform(_shine.value);
                        return Align(
                          alignment: Alignment(-1.6 + 3.2 * t, 0),
                          child: Transform(
                            transform: Matrix4.skewX(-0.3),
                            child: Container(
                              width: 60,
                              height: 58,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.22),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: _content(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ حقل كلمة المرور ═════════════════════════

/// حقل بإطار مدوّر، الإدخال من اليسار (LTR) وأيقونة العين على اليسار،
/// مع توهج أخضر ناعم عند التركيز.
class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final Key visibilityKey;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.visibilityKey,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: focused ? _teal : _fieldBorder,
            width: focused ? 1.4 : 1,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _teal.withValues(alpha: 0.14),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            GestureDetector(
              key: widget.visibilityKey,
              behavior: HitTestBehavior.opaque,
              onTap: widget.onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween<double>(begin: 0.15, end: 0.0).animate(anim),
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Icon(
                    widget.obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(widget.obscure),
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                obscureText: widget.obscure,
                autocorrect: false,
                enableSuggestions: false,
                textAlign: TextAlign.left,
                onChanged: widget.onChanged,
                style: AppTextStyles.body
                    .copyWith(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 17),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════ صف الشرط ═════════════════════════

/// صف شرط: المحقق = دائرة بعلامة صح تظهر بقفزة مرنة،
/// وغير المحقق = دائرة لافندر بنقطة صغيرة.
class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;
  final bool isLast;

  const _RequirementRow({
    required this.met,
    required this.label,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: met ? const Color(0xFFD9E8EA) : const Color(0xFFDDE3F3),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: met
                  ? const Icon(Icons.check_rounded,
                      key: ValueKey('on'), size: 16, color: _teal)
                  : Center(
                      key: const ValueKey('off'),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.iconMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: met ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}
