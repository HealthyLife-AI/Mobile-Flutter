import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/app_dependencies.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_permissions.dart';
import '../bloc/measurements/measurements_cubit.dart';
import '../widgets/app_header_bar.dart';

import '../widgets/directional_icon.dart';
import '../../l10n/l10n.dart';

// ───────────────────────── ألوان إضافية مأخوذة من التصميم ─────────────────────────
const Color _kMint = Color(0xFF5EE0B0);
const Color _kLavender = Color(0xFFEEF2FD); // خلفية البطاقات الفاتحة
const Color _kIconBox = Color(0xFFF3F5FC); // مربع الأيقونة
const Color _kOffTrack = Color(0xFFB9C6C8);

/// "10:00 م" — صيغة 12 ساعة كما في التصميم.
String _fmtTime(BuildContext context, TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final l10n = context.l10n;
  return '$h:$m ${t.period == DayPeriod.am ? l10n.timeAm : l10n.timePm}';
}

/// اهتزاز مخمَّد في أول [span] من الدورة.
double _swing(double t, {double span = 0.2, double amp = 0.4, int waves = 5}) {
  if (t >= span) return 0;
  final u = t / span;
  return amp * (1 - u) * math.sin(u * math.pi * waves);
}

List<BoxShadow> _cardShadow() => [
      BoxShadow(
          color: Colors.black.withAlpha(14),
          blurRadius: 16,
          offset: const Offset(0, 4)),
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
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  /// The settings as the server holds them (API guide 10.5). The server's
  /// defaults show until the saved ones are read; a change shows at once and
  /// goes back if the server refuses it.
  NotificationPreferences _prefs = const NotificationPreferences();

  TimeOfDay get _quietStart => _timeOf(_prefs.quietStartMinute);
  TimeOfDay get _quietEnd => _timeOf(_prefs.quietEndMinute);

  static TimeOfDay _timeOf(int minute) =>
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60);

  static int _minuteOf(TimeOfDay time) => time.hour * 60 + time.minute;

  /// The real OS permission, read on open and again on every return to the
  /// foreground (the person may have changed it in the system settings we sent
  /// them to). Null while the first read is in flight, so no card flashes.
  NotificationPermissionStatus? _permission;

  /// Guards the enable button against a double tap while the prompt is open.
  bool _asking = false;

  late final AnimationController _enter;
  late final AnimationController _loop;
  late final Animation<double> _warn,
      _calm,
      _heading,
      _r1,
      _r2,
      _r3,
      _quiet,
      _note;

  Animation<double> _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(b, e, curve: c));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
    _loadPreferences();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..forward();
    _loop =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

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
    WidgetsBinding.instance.removeObserver(this);
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  /// The permission can change in the system settings while this screen is in
  /// the background, so it is read again on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final deps = context.read<AppDependencies>();
    final status = await deps.notificationPermissions.status();
    if (!mounted) return;
    // Allowed in the system settings while away: register the token as the
    // in-app button does (harmless if it already was).
    final wasGranted = _permission == NotificationPermissionStatus.granted;
    if (_permission != null &&
        !wasGranted &&
        status == NotificationPermissionStatus.granted) {
      unawaited(deps.push.start());
    }
    setState(() => _permission = status);
  }

  /// A denied permission can only be changed in the system settings, so the
  /// button opens them (the app cannot re-prompt once denied).
  Future<void> _openSystemSettings() async {
    await context
        .read<AppDependencies>()
        .notificationPermissions
        .openSystemSettings();
  }

  /// The first ask: shows the OS prompt. Whatever the person chooses is
  /// reflected right away.
  Future<void> _enableNotifications() async {
    if (_asking) return;
    setState(() => _asking = true);
    final permissions = context.read<AppDependencies>().notificationPermissions;
    final status = await permissions.request();
    if (!mounted) return;
    // The token can only be fetched once the permission allows it on iOS, so
    // register it again after a grant; harmless if it already was.
    if (status == NotificationPermissionStatus.granted) {
      unawaited(context.read<AppDependencies>().push.start());
    }
    setState(() {
      _permission = status;
      _asking = false;
    });
  }

  /// The copy kept on the device first, so the switches are right at once,
  /// then the server's.
  Future<void> _loadPreferences() async {
    final repository = context.read<AppDependencies>().notificationPreferences;
    final kept = await repository.known();
    if (!mounted) return;
    setState(() => _prefs = kept);
    final fresh = (await repository.get()).valueOrNull;
    if (!mounted || fresh == null) return;
    setState(() => _prefs = fresh);
  }

  /// Shows [next] at once and saves it. A refusal or no connection puts the
  /// previous settings back and says so. The weigh-in reminder follows the
  /// saved settings (10.6).
  Future<void> _save(NotificationPreferences next) async {
    final previous = _prefs;
    if (next == previous) return;
    setState(() => _prefs = next);
    final deps = context.read<AppDependencies>();
    final measurements = context.read<MeasurementsCubit>().state.snapshot;
    final result = await deps.notificationPreferences.update(next);
    if (!mounted) return;
    final saved = result.valueOrNull;
    if (saved == null) {
      setState(() => _prefs = previous);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.notificationSettingsSaveFailed)));
      return;
    }
    setState(() => _prefs = saved);
    if (measurements != null) {
      unawaited(deps.weighInReminder.plan(measurements));
    }
  }

  /// يفتح محرر ساعات الهدوء (مفتاح + اختيار البداية والنهاية) في Bottom Sheet.
  Future<void> _openQuietHours() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.fromLTRB(
              18, 12, 18, 18 + MediaQuery.of(ctx).viewInsets.bottom),
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
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
                _QuietHoursCard(
                  enabled: _prefs.quietHoursEnabled,
                  onToggle: (v) async {
                    final saving = _save(_prefs.copyWith(quietHoursEnabled: v));
                    setSheet(() {});
                    await saving;
                    if (ctx.mounted) setSheet(() {});
                  },
                  start: _quietStart,
                  end: _quietEnd,
                  onStartChanged: (v) async {
                    final saving =
                        _save(_prefs.copyWith(quietStartMinute: _minuteOf(v)));
                    setSheet(() {});
                    await saving;
                    if (ctx.mounted) setSheet(() {});
                  },
                  onEndChanged: (v) async {
                    final saving =
                        _save(_prefs.copyWith(quietEndMinute: _minuteOf(v)));
                    setSheet(() {});
                    await saving;
                    if (ctx.mounted) setSheet(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The permission card, when it should show: a hard "off" (only the system
  /// settings can fix it) or the first ask (the app can still prompt).
  Widget? _permissionCard() {
    switch (_permission) {
      case NotificationPermissionStatus.denied:
        return _PermissionCard(
          loop: _loop,
          icon: Icons.notifications_off_outlined,
          title: context.l10n.notificationSettingsPhoneDisabled,
          description: context.l10n.notificationSettingsPermissionOff,
          badge: context.l10n.notificationSettingsSystemSettings,
          buttonLabel: context.l10n.notificationSettingsOpenPhoneSettings,
          onPressed: _openSystemSettings,
        );
      case NotificationPermissionStatus.notDetermined:
        return _PermissionCard(
          loop: _loop,
          icon: Icons.notifications_none_rounded,
          title: context.l10n.notificationSettingsEnableTitle,
          description: context.l10n.notificationSettingsEnableDesc,
          buttonLabel: context.l10n.notificationSettingsEnable,
          onPressed: _enableNotifications,
        );
      case NotificationPermissionStatus.granted:
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeaderBar(title: context.l10n.commonNotifications),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            // ───────── بطاقة تحذير إشعارات الهاتف ─────────
            if (_permissionCard() != null) ...[
              _Reveal(animation: _warn, dy: 0.2, child: _permissionCard()!),
              const SizedBox(height: 16),
            ],

            // ───────── بطاقة الهدوء والتوازن ─────────
            _Reveal(animation: _calm, dy: 0.2, child: _CalmCard(loop: _loop)),
            const SizedBox(height: 22),

            // ───────── عنوان القسم ─────────
            _Reveal(
              animation: _heading,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.notificationSettingsHeading,
                        style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.notificationSettingsIntro,
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
                title: context.l10n.notificationSettingsMeals,
                subtitle: context.l10n.notificationSettingsMealsDesc,
                value: _prefs.meals,
                onChanged: (v) => _save(_prefs.copyWith(meals: v)),
              ),
            ),
            const SizedBox(height: 12),
            _Reveal(
              animation: _r2,
              dy: 0.25,
              child: _ToggleCard(
                icon: Icons.monitor_weight_outlined,
                title: context.l10n.notificationSettingsMeasurements,
                subtitle: context.l10n.notificationSettingsMeasurementsDesc,
                value: _prefs.measurements,
                onChanged: (v) => _save(_prefs.copyWith(measurements: v)),
              ),
            ),
            const SizedBox(height: 12),
            _Reveal(
              animation: _r3,
              dy: 0.25,
              child: _ToggleCard(
                icon: Icons.medical_services_outlined,
                title: context.l10n.notificationCategoryNutritionist,
                subtitle: context.l10n.notificationSettingsNutritionistDesc,
                value: _prefs.nutritionist,
                onChanged: (v) => _save(_prefs.copyWith(nutritionist: v)),
              ),
            ),
            const SizedBox(height: 12),
            _Reveal(
              animation: _r3,
              dy: 0.25,
              child: _ToggleCard(
                icon: Icons.auto_fix_high_rounded,
                title: context.l10n.notificationCategoryPlanUpdates,
                subtitle: context.l10n.notificationSettingsPlanUpdatesDesc,
                value: _prefs.plan,
                onChanged: (v) => _save(_prefs.copyWith(plan: v)),
              ),
            ),
            const SizedBox(height: 12),

            // ───────── أوقات عدم الإزعاج ─────────
            _Reveal(
              animation: _quiet,
              dy: 0.25,
              child: _QuietRow(
                loop: _loop,
                text: context.l10n.notificationSettingsQuietRange(
                    _fmtTime(context, _quietStart),
                    _fmtTime(context, _quietEnd)),
                onTap: _openQuietHours,
              ),
            ),
            const SizedBox(height: 16),

            // ───────── ملاحظة الالتزام ─────────
            _Reveal(
                animation: _note,
                dy: 0.25,
                child: _CommitmentNote(loop: _loop)),
          ],
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
        position: Tween<Offset>(begin: Offset(0, dy), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}

// ───────────────────────────── بطاقة التحذير ─────────────────────────────

class _PermissionCard extends StatelessWidget {
  final Animation<double> loop;
  final IconData icon;
  final String title;
  final String description;

  /// The small white tag next to the title (for example "system settings").
  /// Null hides it.
  final String? badge;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _PermissionCard({
    required this.loop,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: _kLavender, borderRadius: BorderRadius.circular(26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الجرس: تهتز + نبضة حلقية
              AnimatedBuilder(
                animation: loop,
                builder: (_, __) {
                  final t = loop.value;
                  final ping = (t * 2) % 1.0;
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 50 + 22 * ping,
                            height: 50 + 22 * ping,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(16 + 8 * ping),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withAlpha((70 * (1 - ping)).toInt()),
                                  width: 1.4),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Transform.rotate(
                              angle: _swing(t),
                              alignment: Alignment.topCenter,
                              child: Icon(icon,
                                  color: AppColors.primary, size: 24),
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
                        Expanded(
                            child: Text(title, style: AppTextStyles.cardTitle)),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill)),
                            child: Text(badge!,
                                style: AppTextStyles.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(description,
                        style: AppTextStyles.caption.copyWith(height: 1.7)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: _ShimmerPillButton(
              label: buttonLabel,
              loop: loop,
              onPressed: onPressed,
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

  const _ShimmerPillButton(
      {required this.label, required this.loop, required this.onPressed});

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
                    color:
                        AppColors.primary.withAlpha(35 + (45 * glow).toInt()),
                    blurRadius: 10 + 8 * glow,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Stack(alignment: Alignment.center, children: [
                  PositionedDirectional(
                      end: -w * 0.3 + s * w * 1.6,
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
                      )),
                  Text(widget.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
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
              child: Transform.scale(
                  scale: 1.06 + 0.07 * math.sin(loop.value * 2 * math.pi),
                  child: child),
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
              child: const Icon(Icons.self_improvement_rounded,
                  color: AppColors.primary, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.notificationSettingsCalm,
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(context.l10n.notificationSettingsRoutine,
                  style: AppTextStyles.caption),
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
              child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40 + 12 * b,
                      height: 40 + 12 * b,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kLavender.withAlpha((200 * (1 - b)).toInt())),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: _kLavender, shape: BoxShape.circle),
                      child: Transform.rotate(
                        angle: 0.12 * math.sin(loop.value * 2 * math.pi),
                        child: Transform.scale(
                          scale: 1 + 0.12 * b,
                          child: const Icon(Icons.spa_rounded,
                              color: AppColors.primary, size: 19),
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

class _ToggleCardState extends State<_ToggleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  static final Animatable<double> _pop = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30),
    TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70),
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
        border: Border.all(
            color: on ? AppColors.primary.withAlpha(30) : Colors.transparent),
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
              child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (active)
                      Container(
                        width: 50 + 30 * b,
                        height: 50 + 30 * b,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 + 10 * b),
                          border: Border.all(
                            color: (on ? _kMint : _kOffTrack)
                                .withAlpha((200 * (1 - b)).toInt()),
                            width: 2,
                          ),
                        ),
                      ),
                    Transform.scale(
                      scale: _pop.evaluate(_burst),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: _kIconBox,
                            borderRadius: BorderRadius.circular(16)),
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(
                              end: on
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          duration: const Duration(milliseconds: 300),
                          builder: (_, c, __) =>
                              Icon(widget.icon, color: c, size: 23),
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
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(widget.title,
                          style:
                              AppTextStyles.cardTitle.copyWith(fontSize: 15))),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(scale: a, child: child)),
                    child: on
                        ? const SizedBox.shrink(key: ValueKey('on'))
                        : Container(
                            key: const ValueKey('off'),
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: _kIconBox,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(context.l10n.commonOff,
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 10)),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(widget.subtitle,
                  style: AppTextStyles.caption.copyWith(height: 1.6)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _PillSwitch(
            value: on, onChanged: widget.onChanged, label: widget.title),
      ]),
    );
  }
}

/// مفتاح مخصص: مسار تيل عند التفعيل ورمادي عند الإيقاف، وقرص أبيض بارتداد.
/// (في RTL يتجه القرص إلى اليسار عند التفعيل كما في التصميم.)
class _PillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  /// What the switch turns on, for screen readers.
  final String label;

  const _PillSwitch(
      {required this.value, required this.onChanged, required this.label});

  void _toggle() {
    HapticFeedback.selectionClick();
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      onTap: _toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
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
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
              ),
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

  const _QuietRow(
      {required this.loop, required this.text, required this.onTap});

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
                  decoration: BoxDecoration(
                      color: _kIconBox,
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(13),
                  child: CustomPaint(
                      painter: _ClockPainter(
                          t * 2 * math.pi * 4, AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.notificationSettingsQuietHours,
                          style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(widget.text, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      color: _kLavender, shape: BoxShape.circle),
                  child: Transform.translate(
                    offset: Offset(-nudge * rtlDesignSign(context), 0),
                    child: Icon(
                        directionalIcon(context,
                            rtl: Icons.chevron_left_rounded,
                            ltr: Icons.chevron_right_rounded),
                        size: 22,
                        color: AppColors.primary),
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
  bool shouldRepaint(covariant _ClockPainter old) =>
      old.minuteAngle != minuteAngle || old.color != color;
}

// ───────────────────────────── ملاحظة الالتزام ─────────────────────────────

class _CommitmentNote extends StatelessWidget {
  final Animation<double> loop;
  const _CommitmentNote({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
          color: _kLavender, borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: loop,
            builder: (_, __) {
              final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
              return SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40 + 16 * p,
                        height: 40 + 16 * p,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white
                                .withAlpha((170 * (1 - p)).toInt())),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Transform.scale(
                          scale: 1 + 0.08 * p,
                          child: const Icon(Icons.verified_user_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                      ),
                    ]),
              );
            },
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 4),
                  child: Icon(Icons.lightbulb_outline_rounded,
                      size: 14, color: Color(0xFFF2B01E)),
                ),
              ),
              TextSpan(
                text: context.l10n.notificationSettingsPromise,
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
          border: Border.all(
              color:
                  enabled ? AppColors.primary.withAlpha(60) : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: _kIconBox,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.bedtime_outlined,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(context.l10n.notificationSettingsNightQuiet,
                        style: AppTextStyles.cardTitle)),
                _PillSwitch(
                    value: enabled,
                    onChanged: onToggle,
                    label: context.l10n.notificationSettingsQuietHours),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                context.l10n.commonFromTo(
                    _fmtTime(context, start), _fmtTime(context, end)),
                style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TimeSelector(
                    label: context.l10n.notificationSettingsStarts,
                    icon: Icons.nightlight_round,
                    value: _fmtTime(context, start),
                    onTap: enabled
                        ? () => _pick(context, start, onStartChanged)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimeSelector(
                    label: context.l10n.notificationSettingsEnds,
                    icon: Icons.wb_twilight_rounded,
                    value: _fmtTime(context, end),
                    onTap: enabled
                        ? () => _pick(context, end, onEndChanged)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, TimeOfDay initial,
      ValueChanged<TimeOfDay> onChanged) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onChanged(picked);
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  const _TimeSelector(
      {required this.label,
      required this.icon,
      required this.value,
      this.onTap});

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
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700),
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
