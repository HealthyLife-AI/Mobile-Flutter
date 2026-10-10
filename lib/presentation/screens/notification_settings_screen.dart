import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/app_header_bar.dart';
import '../../core/navigation/app_page_route.dart';
import 'notifications_center_screen.dart';

// ───────────────────────── ألوان إضافية مأخوذة من التصميم ─────────────────────────
const Color _kMint = Color(0xFF5EE0B0);
const Color _kLavender = Color(0xFFEEF2FD); // خلفية البطاقات الفاتحة
const Color _kIconBox = Color(0xFFF3F5FC); // مربع الأيقونة
const Color _kOffTrack = Color(0xFFB9C6C8);

/// "10:00 م" — صيغة 12 ساعة كما في التصميم.
String _fmtTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period == DayPeriod.am ? 'ص' : 'م'}';
}

/// اهتزاز مخمَّد في أول [span] من الدورة.
double _swing(double t, {double span = 0.2, double amp = 0.4, int waves = 5}) {
  if (t >= span) return 0;
  final u = t / span;
  return amp * (1 - u) * math.sin(u * math.pi * waves);
}

List<BoxShadow> _cardShadow() => [
      BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 16, offset: const Offset(0, 4)),
    ];

/// الإشعارات (الإعدادات) — تحدد أي الإشعارات تُرسل (تختلف عن شاشة مركز الإشعارات).
///
/// الأنيميشن:
///  1) دخول متتابع لكل الأقسام.
///  2) بطاقة التحذير: أيقونة الجرس المكتوم تهتز مع نبضة حلقية، وزر "فتح الإعدادات" بلمعة وتوهج.
///  3) بطاقة الهدوء: الصورة بتكبير بطيء (Ken Burns) وورقة "تتنفس" داخل دائرة تنبض بهدوء.
///  4) مفاتيح التنبيه: مفتاح مخصص بحركة ارتداد، وعند التبديل: نبضة حلقية + ارتداد الأيقونة +
///     نقطة تظهر بـ elastic وشارة "معطل" تتبدل بسلاسة + haptic.
///  5) عدم الإزعاج: عقرب ساعة يدور وسهم يلمّح بالنقر. وملاحظة الالتزام بدرع نابض.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with TickerProviderStateMixin {
  bool _mealReminders = true;
  bool _measurementReminders = true;
  bool _planUpdates = false;
  bool _quietHoursEnabled = true;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);
  // يحاكي إيقاف صلاحية الإشعارات على مستوى النظام (شارة التحذير).
  final bool _systemNotificationsOff = true;

  late final AnimationController _enter;
  late final AnimationController _loop;
  late final Animation<double> _warn, _calm, _heading, _r1, _r2, _r3, _quiet, _note;

  Animation<double> _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(b, e, curve: c));

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _warn = _iv(0.10, 0.38);
    _calm = _iv(0.22, 0.50);
    _heading = _iv(0.34, 0.56);
    _r1 = _iv(0.42, 0.68);
    _r2 = _iv(0.50, 0.76);
    _r3 = _iv(0.58, 0.84);
    _quiet = _iv(0.68, 0.90);
    _note = _iv(0.76, 1.00);
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// يفتح محرر ساعات الهدوء (مفتاح + اختيار البداية والنهاية) في Bottom Sheet.
  Future<void> _openQuietHours() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                  _QuietHoursCard(
                    enabled: _quietHoursEnabled,
                    onToggle: (v) {
                      setState(() => _quietHoursEnabled = v);
                      setSheet(() {});
                    },
                    start: _quietStart,
                    end: _quietEnd,
                    onStartChanged: (v) {
                      setState(() => _quietStart = v);
                      setSheet(() {});
                    },
                    onEndChanged: (v) {
                      setState(() => _quietEnd = v);
                      setSheet(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openNotificationsCenter() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const NotificationsCenterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppHeaderBar(title: 'الإشعارات'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              // ───────── بطاقة تحذير إشعارات الهاتف ─────────
              if (_systemNotificationsOff) ...[
                _Reveal(
                  animation: _warn,
                  dy: 0.2,
                  child: _WarningCard(
                    loop: _loop,
                    onOpenSettings: _openNotificationsCenter,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ───────── بطاقة الهدوء والتوازن ─────────
              _Reveal(animation: _calm, dy: 0.2, child: _CalmCard(loop: _loop)),
              const SizedBox(height: 22),

              // ───────── عنوان القسم ─────────
              _Reveal(
                animation: _heading,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تخصيص التنبيهات الصحية', style: AppTextStyles.sectionHeading),
                      SizedBox(height: 8),
                      Text(
                        'يمكنك تحديد الإشعارات التي ترغب في استلامها بكل دقة، لتبقى على اتصال دائم بأهدافك دون أي إزعاج.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ───────── المفاتيح ─────────
              _Reveal(
                animation: _r1,
                dy: 0.25,
                child: _ToggleCard(
                  icon: Icons.restaurant_rounded,
                  title: 'تذكير الوجبات',
                  subtitle: 'تذكير بمواعيد وجبات خطتك اليومية وتسجيلها في وقتها المناسب.',
                  value: _mealReminders,
                  onChanged: (v) => setState(() => _mealReminders = v),
                ),
              ),
              const SizedBox(height: 12),
              _Reveal(
                animation: _r2,
                dy: 0.25,
                child: _ToggleCard(
                  icon: Icons.monitor_weight_outlined,
                  title: 'تذكير القياسات',
                  subtitle: 'تنبيه لطيف صباح كل أسبوع لأخذ قياس الوزن ومحيط الجسم وتحديث تقدمك.',
                  value: _measurementReminders,
                  onChanged: (v) => setState(() => _measurementReminders = v),
                ),
              ),
              const SizedBox(height: 12),
              _Reveal(
                animation: _r3,
                dy: 0.25,
                child: _ToggleCard(
                  icon: Icons.auto_fix_high_rounded,
                  title: 'تحديثات الخطة',
                  subtitle: 'إشعار فوري عند مراجعة أخصائيتك الغذائية لخطتك وتعديل الوجبات أو البدائل.',
                  value: _planUpdates,
                  onChanged: (v) => setState(() => _planUpdates = v),
                ),
              ),
              const SizedBox(height: 12),

              // ───────── أوقات عدم الإزعاج ─────────
              _Reveal(
                animation: _quiet,
                dy: 0.25,
                child: _QuietRow(
                  loop: _loop,
                  text: 'من ${_fmtTime(_quietStart)} حتى ${_fmtTime(_quietEnd)} تلقائياً',
                  onTap: _openQuietHours,
                ),
              ),
              const SizedBox(height: 16),

              // ───────── ملاحظة الالتزام ─────────
              _Reveal(animation: _note, dy: 0.25, child: _CommitmentNote(loop: _loop)),
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

// ───────────────────────────── بطاقة التحذير ─────────────────────────────

class _WarningCard extends StatelessWidget {
  final Animation<double> loop;
  final VoidCallback onOpenSettings;

  const _WarningCard({required this.loop, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الجرس المكتوم: تهتز + نبضة حلقية
              AnimatedBuilder(
                animation: loop,
                builder: (_, __) {
                  final t = loop.value;
                  final ping = (t * 2) % 1.0;
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                      Container(
                        width: 50 + 22 * ping,
                        height: 50 + 22 * ping,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 + 8 * ping),
                          border: Border.all(color: AppColors.primary.withAlpha((70 * (1 - ping)).toInt()), width: 1.4),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Transform.rotate(
                          angle: _swing(t),
                          alignment: Alignment.topCenter,
                          child: const Icon(Icons.notifications_off_outlined, color: AppColors.primary, size: 24),
                        ),
                      ),
                    ]),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('إشعارات الهاتف معطلة', style: AppTextStyles.cardTitle)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: Text('إعدادات النظام',
                              style: AppTextStyles.caption.copyWith(
                                  fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'تم إيقاف صلاحية الإشعارات لتطبيق HealthyLife من إعدادات جهازك. لتلقي التذكيرات ومتابعة خطتك الغذائية، يرجى تفعيلها من إعدادات النظام.',
                      style: AppTextStyles.caption.copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: _ShimmerPillButton(
              label: 'فتح إعدادات الهاتف',
              loop: loop,
              onPressed: onOpenSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPillButton extends StatefulWidget {
  final String label;
  final Animation<double> loop;
  final VoidCallback onPressed;

  const _ShimmerPillButton({required this.label, required this.loop, required this.onPressed});

  @override
  State<_ShimmerPillButton> createState() => _ShimmerPillButtonState();
}

class _ShimmerPillButtonState extends State<_ShimmerPillButton> {
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
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: widget.loop,
          builder: (_, __) {
            final t = widget.loop.value;
            final glow = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
            final s = ((t - 0.35) / 0.3).clamp(0.0, 1.0);
            const w = 180.0;
            return Container(
              width: w,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(35 + (45 * glow).toInt()),
                    blurRadius: 10 + 8 * glow,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Stack(alignment: Alignment.center, children: [
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
                            Colors.white.withAlpha(70),
                            Colors.white.withAlpha(0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Text(widget.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────────── بطاقة الهدوء والتوازن ─────────────────────────────

class _CalmCard extends StatelessWidget {
  final Animation<double> loop;
  const _CalmCard({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _cardShadow(),
      ),
      child: Row(children: [
        // الصورة بتكبير بطيء (Ken Burns)
        AnimatedBuilder(
          animation: loop,
          builder: (_, child) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 78,
              height: 78,
              child: Transform.scale(scale: 1.06 + 0.07 * math.sin(loop.value * 2 * math.pi), child: child),
            ),
          ),
          child: Image.asset(
            // TODO: ضعي مسار الصورة الحقيقي.
            'assets/images/notifications_calm.jpg',
            width: 78,
            height: 78,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 78,
              height: 78,
              color: AppColors.primaryTint,
              child: const Icon(Icons.self_improvement_rounded, color: AppColors.primary, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هدوء وتوازن بدون تشويش', style: AppTextStyles.cardTitle),
              SizedBox(height: 4),
              Text('ننظم إشعاراتك بما يلائم روتينك اليومي', style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // ورقة "تتنفس" داخل دائرة تنبض بهدوء
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) {
            final b = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi);
            return SizedBox(
              width: 48,
              height: 48,
              child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                Container(
                  width: 40 + 12 * b,
                  height: 40 + 12 * b,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _kLavender.withAlpha((200 * (1 - b)).toInt())),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: _kLavender, shape: BoxShape.circle),
                  child: Transform.rotate(
                    angle: 0.12 * math.sin(loop.value * 2 * math.pi),
                    child: Transform.scale(
                      scale: 1 + 0.12 * b,
                      child: const Icon(Icons.spa_rounded, color: AppColors.primary, size: 19),
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
      ]),
    );
  }
}

// ───────────────────────────── بطاقة المفتاح ─────────────────────────────

class _ToggleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ToggleCard> createState() => _ToggleCardState();
}

class _ToggleCardState extends State<_ToggleCard> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  static final Animatable<double> _pop = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
  ]);

  @override
  void didUpdateWidget(covariant _ToggleCard old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _burst.forward(from: 0);
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: _cardShadow(),
        border: Border.all(color: on ? AppColors.primary.withAlpha(30) : Colors.transparent),
      ),
      child: Row(children: [
        // مربع الأيقونة + نبضة التبديل
        AnimatedBuilder(
          animation: _burst,
          builder: (_, __) {
            final b = Curves.easeOut.transform(_burst.value);
            final active = _burst.isAnimating;
            return SizedBox(
              width: 50,
              height: 50,
              child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                if (active)
                  Container(
                    width: 50 + 30 * b,
                    height: 50 + 30 * b,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16 + 10 * b),
                      border: Border.all(
                        color: (on ? _kMint : _kOffTrack).withAlpha((200 * (1 - b)).toInt()),
                        width: 2,
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: _pop.evaluate(_burst),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: _kIconBox, borderRadius: BorderRadius.circular(16)),
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: on ? AppColors.primary : AppColors.textSecondary),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, c, __) => Icon(widget.icon, color: c, size: 23),
                    ),
                  ),
                ),
              ]),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // النقطة الخضراء تظهر بـ elastic عند التفعيل
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: on ? 16 : 0,
                    child: AnimatedScale(
                      scale: on ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      curve: on ? Curves.elasticOut : Curves.easeIn,
                      // AnimatedScale takes a resolved Alignment only, so the
                      // directional start edge is resolved against the text
                      // direction here.
                      alignment: Directionality.of(context) == TextDirection.rtl
                          ? const Alignment(1, 0)
                          : const Alignment(-1, 0),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                  Flexible(child: Text(widget.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15))),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, a) =>
                        FadeTransition(opacity: a, child: ScaleTransition(scale: a, child: child)),
                    child: on
                        ? const SizedBox.shrink(key: ValueKey('on'))
                        : Container(
                            key: const ValueKey('off'),
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: _kIconBox, borderRadius: BorderRadius.circular(8)),
                            child: Text('معطل', style: AppTextStyles.caption.copyWith(fontSize: 10)),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(widget.subtitle, style: AppTextStyles.caption.copyWith(height: 1.6)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _PillSwitch(value: on, onChanged: widget.onChanged),
      ]),
    );
  }
}

/// مفتاح مخصص: مسار تيل عند التفعيل ورمادي عند الإيقاف، وقرص أبيض بارتداد.
/// (في RTL يتجه القرص إلى اليسار عند التفعيل كما في التصميم.)
class _PillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 60,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : _kOffTrack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
          alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4, offset: const Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── أوقات عدم الإزعاج ─────────────────────────────

class _QuietRow extends StatefulWidget {
  final Animation<double> loop;
  final String text;
  final VoidCallback onTap;

  const _QuietRow({required this.loop, required this.text, required this.onTap});

  @override
  State<_QuietRow> createState() => _QuietRowState();
}

class _QuietRowState extends State<_QuietRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: _cardShadow(),
          ),
          child: AnimatedBuilder(
            animation: widget.loop,
            builder: (_, __) {
              final t = widget.loop.value;
              final nudge = 3 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 2));
              return Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: _kIconBox, borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(13),
                  child: CustomPaint(painter: _ClockPainter(t * 2 * math.pi * 4, AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('أوقات عدم الإزعاج', style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(widget.text, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(color: _kLavender, shape: BoxShape.circle),
                  child: Transform.translate(
                    offset: Offset(-nudge, 0),
                    child: const Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.primary),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final double minuteAngle;
  final Color color;
  const _ClockPainter(this.minuteAngle, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r - 1, p);
    const h = -math.pi / 2 + math.pi / 3;
    canvas.drawLine(c, c + Offset(math.cos(h), math.sin(h)) * (r * 0.45), p);
    final m = -math.pi / 2 + minuteAngle;
    canvas.drawLine(c, c + Offset(math.cos(m), math.sin(m)) * (r * 0.68), p);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) => old.minuteAngle != minuteAngle || old.color != color;
}

// ───────────────────────────── ملاحظة الالتزام ─────────────────────────────

class _CommitmentNote extends StatelessWidget {
  final Animation<double> loop;
  const _CommitmentNote({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: loop,
            builder: (_, __) {
              final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
              return SizedBox(
                width: 56,
                height: 56,
                child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                  Container(
                    width: 40 + 16 * p,
                    height: 40 + 16 * p,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha((170 * (1 - p)).toInt())),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Transform.scale(
                      scale: 1 + 0.08 * p,
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                    ),
                  ),
                ]),
              );
            },
          ),
          const SizedBox(height: 8),
          Text.rich(
            const TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 4),
                  child: Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFF2B01E)),
                ),
              ),
              TextSpan(
                text: 'نلتزم بإرسال التنبيهات الضرورية فقط لمساعدتك على الالتزام، دون أي إزعاج أو إشعارات ترويجية.',
              ),
            ]),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── محرر ساعات الهدوء (Bottom Sheet) ─────────────────────────────

/// الهدوء الليلي: عنوان + مفتاح، ثم اختيار وقتي البداية والنهاية.
/// النافذة تفاعلية فقط عند التفعيل، وإلا تُعتَّم وتتعطل.
class _QuietHoursCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final TimeOfDay start;
  final TimeOfDay end;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const _QuietHoursCard({
    required this.enabled,
    required this.onToggle,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.55,
      duration: const Duration(milliseconds: 220),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: _cardShadow(),
          border: Border.all(color: enabled ? AppColors.primary.withAlpha(60) : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: _kIconBox, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.bedtime_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('الهدوء الليلي', style: AppTextStyles.cardTitle)),
                _PillSwitch(value: enabled, onChanged: onToggle),
              ],
            ),
            const SizedBox(height: 12),
            Text('من ${_fmtTime(start)} حتى ${_fmtTime(end)}', style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TimeSelector(
                    label: 'يبدأ',
                    icon: Icons.nightlight_round,
                    value: _fmtTime(start),
                    onTap: enabled ? () => _pick(context, start, onStartChanged) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimeSelector(
                    label: 'ينتهي',
                    icon: Icons.wb_twilight_rounded,
                    value: _fmtTime(end),
                    onTap: enabled ? () => _pick(context, end, onEndChanged) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, TimeOfDay initial, ValueChanged<TimeOfDay> onChanged) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onChanged(picked);
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  const _TimeSelector({required this.label, required this.icon, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kLavender,
      borderRadius: BorderRadius.circular(AppRadius.cardSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
