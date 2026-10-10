import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/locked_feature_overlay.dart';
import 'achievements_screen.dart';
import 'notifications_center_screen.dart';
import 'notification_settings_screen.dart';
import 'health_sync_screen.dart';
import 'sleep_stress_mood_screen.dart';
import 'schedule_calls_screen.dart';
import 'measurements_screen.dart';
import 'specialist_profile_screen.dart';
import 'password_settings_screen.dart';
import 'language_settings_screen.dart';
import 'about_app_screen.dart';
import 'health_record_screen.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/navigation/logout_flow.dart';

// ───────────────────────── ألوان إضافية مأخوذة من التصميم ─────────────────────────
const Color _kMint = Color(0xFF5EE0B0);
const Color _kMintSoft = Color(0xFFE3F8F0);
const Color _kLavender = Color(0xFFF1F4FC);
const Color _kDivider = Color(0xFFEBEFF6);
const Color _kLogoutBg = Color(0xFFFFDCD8);
const Color _kLogoutText = Color(0xFFB3261E);

double _swing(double t, {double span = 0.2, double amp = 0.4, int waves = 5}) {
  if (t >= span) return 0;
  final u = t / span;
  return amp * (1 - u) * math.sin(u * math.pi * waves);
}

List<BoxShadow> _cardShadow() => [
      BoxShadow(color: Colors.black.withAlpha(14), blurRadius: 18, offset: const Offset(0, 5)),
    ];

class _NavItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget Function() screen;
  const _NavItem(this.icon, this.title, this.subtitle, this.screen);
}

/// الحساب — بطاقة الهوية، ثم "إعدادات الحساب والمتابعة"، ثم "المزيد" (قابلة للطي)،
/// ثم تسجيل الخروج.
///
/// الأنيميشن:
///  1) دخول متتابع: الهيدر ثم البطاقة ثم كل صف يدخل من اليمين بالتتابع.
///  2) بطاقة الهوية: هالتان نعناعيتان تنجرفان ببطء، حلقة متدرجة تدور حول الصورة،
///     شارة التوثيق بارتداد elastic، نقطة "نشط" تنبض، ولمعة تمر على كبسولة كود المريض.
///  3) صفوف الإعدادات: ضغط بتصغير + سهم ينزلق + أيقونة ترتدّ، وجرس الإشعارات يهتز دورياً.
///  4) "المزيد": يتمدد بسلاسة مع سهم يدور.
///  5) تسجيل الخروج: سهم يتحرك للإيحاء بالخروج وتوهج أحمر يتنفس.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final GlobalKey _settingsKey = GlobalKey();
  bool _moreOpen = false;
  bool _healthCvUnlocked = false;

  late final AnimationController _enter;
  late final AnimationController _loop;
  late final Animation<double> _header, _identity, _badgePop, _heading, _more, _logout, _caption;
  late final List<Animation<double>> _rows;

  Animation<double> _iv(double b, double e, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _enter, curve: Interval(b, e, curve: c));

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 2300))..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _header = _iv(0.00, 0.18);
    _identity = _iv(0.08, 0.38);
    _badgePop = _iv(0.30, 0.62, Curves.elasticOut);
    _heading = _iv(0.30, 0.48);
    _rows = [for (int k = 0; k < 5; k++) _iv(0.34 + k * 0.07, 0.60 + k * 0.07)];
    _more = _iv(0.70, 0.92);
    _logout = _iv(0.76, 0.96);
    _caption = _iv(0.86, 1.00);
  }

  @override
  void dispose() {
    _enter.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _go(Widget screen) => Navigator.of(context).push(AppPageRoute(builder: (_) => screen));

  /// يمرّر القائمة إلى كتلة إعدادات الحساب.
  void _jumpToSettings() {
    final ctx = _settingsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  List<_NavItem> get _moreItems => [
        _NavItem(Icons.straighten_rounded, 'الوزن ومحيط الجسم', 'سجّلي قياساتك وتابعي مسار تغيّرك',
            () => const MeasurementsScreen()),
        _NavItem(Icons.folder_shared_outlined, 'السجل الطبي', 'المستوى، الهدف، الأدوية والتشخيصات المعتمدة',
            () => const HealthRecordScreen()),
        _NavItem(Icons.emoji_events_outlined, 'إنجازاتي', null, () => const AchievementsScreen()),
        _NavItem(Icons.favorite_border_rounded, 'ربط تطبيق الصحة', null, () => const HealthSyncScreen()),
        _NavItem(Icons.bedtime_outlined, 'النوم والإجهاد والمزاج', null, () => const SleepStressMoodScreen()),
        _NavItem(Icons.event_available_outlined, 'المواعيد والمتابعة', null, () => const ScheduleCallsScreen()),
        _NavItem(Icons.mark_email_unread_outlined, 'سجل الإشعارات', null, () => const NotificationsCenterScreen()),
      ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(18, 14, 18, 132 + bottomInset),
            children: [
              // ───────── الهيدر ─────────
              _Reveal(
                animation: _header,
                dy: -0.4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: [
                      Text('الحساب', style: AppTextStyles.h1.copyWith(fontSize: 22)),
                      const Spacer(),
                      // الأيقونة تنقل إلى كتلة الإعدادات (نفس وظيفة زر الترس القديم)
                      Tooltip(
                        message: 'الإعدادات',
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _jumpToSettings();
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 23),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ───────── بطاقة الهوية ─────────
              _Reveal(animation: _identity, dy: 0.2, child: _IdentityCard(loop: _loop, badgePop: _badgePop)),
              const SizedBox(height: 22),

              // ───────── عنوان القسم ─────────
              _Reveal(
                animation: _heading,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('إعدادات الحساب والمتابعة', style: AppTextStyles.sectionHeading),
                ),
              ),
              const SizedBox(height: 12),

              // ───────── مجموعة الإعدادات (بطاقة واحدة) ─────────
              KeyedSubtree(
                key: _settingsKey,
                child: _GroupCard(
                  children: [
                    _Reveal(
                      animation: _rows[0],
                      dx: 0.12,
                      dy: 0,
                      child: _SettingsTile(
                        icon: Icons.assignment_ind_outlined,
                        title: 'الأخصائي الغذائي',
                        subtitle: 'أ. خلود العربي (أخصائية التغذية العلاجية)',
                        onTap: () => _go(const SpecialistProfileScreen()),
                      ),
                    ),
                    _Reveal(
                      animation: _rows[1],
                      dx: 0.12,
                      dy: 0,
                      child: _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        iconWidget: AnimatedBuilder(
                          animation: _loop,
                          builder: (_, __) => Transform.rotate(
                            angle: _swing(_loop.value),
                            alignment: Alignment.topCenter,
                            child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 25),
                          ),
                        ),
                        title: 'الإشعارات',
                        subtitle: 'التذكير بالوجبات والقياسات',
                        onTap: () => _go(const NotificationSettingsScreen()),
                      ),
                    ),
                    _Reveal(
                      animation: _rows[2],
                      dx: 0.12,
                      dy: 0,
                      child: _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'كلمة المرور',
                        subtitle: 'تحديث وحماية الحساب',
                        onTap: () => _go(const PasswordSettingsScreen()),
                      ),
                    ),
                    _Reveal(
                      animation: _rows[3],
                      dx: 0.12,
                      dy: 0,
                      child: _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: 'اللغة',
                        subtitle: 'العربية (الحالية)',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: const Text('عربي', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                        ),
                        onTap: () => _go(const LanguageSettingsScreen()),
                      ),
                    ),
                    _Reveal(
                      animation: _rows[4],
                      dx: 0.12,
                      dy: 0,
                      child: _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'حول التطبيق',
                        subtitle: 'الإصدار 1.0.0',
                        trailing: const Text('v1.0.0', style: AppTextStyles.caption),
                        onTap: () => _go(const AboutAppScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ───────── المزيد (قابلة للطي) ─────────
              _Reveal(
                animation: _more,
                dy: 0.2,
                child: _MoreCard(
                  open: _moreOpen,
                  onToggle: () => setState(() => _moreOpen = !_moreOpen),
                  items: _moreItems,
                  onOpen: _go,
                  lockedTile: LockedFeatureOverlay(
                    locked: !_healthCvUnlocked,
                    message: 'هذه الميزة تتطلب باقة أعلى — تواصلي مع أخصائيتك للترقية',
                    onContact: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _healthCvUnlocked = true;
                        _moreOpen = true;
                      });
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: _healthCvUnlocked ? 0 : 184),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _go(const HealthRecordScreen()),
                          child: _SettingsTile(
                            icon: Icons.medical_information_outlined,
                            title: 'الملف الصحي (Health CV)',
                            subtitle: 'سجل صحي شامل يعدّه أخصائيك',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ───────── تسجيل الخروج ─────────
              _Reveal(animation: _logout, dy: 0.3, child: _LogoutTile(loop: _loop)),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _caption,
                child: const Center(
                  child: Text(
                    'يتطلب تأكيد تسجيل الخروج لضمان مزامنة قياساتك الأخيرة',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
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
  final double dx;
  final double dy;

  const _Reveal({required this.animation, required this.child, this.dx = 0, this.dy = 0.15});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(dx, dy), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

// ───────────────────────────── بطاقة الهوية ─────────────────────────────

class _IdentityCard extends StatelessWidget {
  final Animation<double> loop;
  final Animation<double> badgePop;

  const _IdentityCard({required this.loop, required this.badgePop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _cardShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(children: [
          // هالتان نعناعيتان تنجرفان ببطء
          Positioned.fill(
            child: AnimatedBuilder(
              animation: loop,
              builder: (_, __) {
                final a = loop.value * 2 * math.pi;
                return Stack(clipBehavior: Clip.hardEdge, children: [
                  Positioned(
                    left: -70 + 16 * math.sin(a),
                    top: -60 + 10 * math.cos(a),
                    child: _blob(190, 95),
                  ),
                  Positioned(
                    right: -60 + 12 * math.cos(a),
                    top: -40 + 12 * math.sin(a),
                    child: _blob(160, 60),
                  ),
                ]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _Avatar(loop: loop, badgePop: badgePop),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('سارة أحمد',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.cardTitle.copyWith(fontSize: 21, fontWeight: FontWeight.w700)),
                              ),
                              _ActiveChip(loop: loop),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _CodePill(loop: loop),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _ClinicBlock(loop: loop),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _blob(double size, int alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [_kMint.withAlpha(alpha), _kMint.withAlpha(0)]),
        ),
      );
}

class _Avatar extends StatelessWidget {
  final Animation<double> loop;
  final Animation<double> badgePop;

  const _Avatar({required this.loop, required this.badgePop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        // حلقة متدرجة تدور
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) => Transform.rotate(
            angle: loop.value * 2 * math.pi,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [_kMint, Color(0x005EE0B0), _kMint],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 94,
          height: 94,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
        ClipOval(
          child: Image.asset(
            // TODO: ضعي مسار صورة المريضة الحقيقية.
            'assets/images/profile_avatar.jpg',
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 88,
              height: 88,
              color: AppColors.primaryTint,
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 44),
            ),
          ),
        ),
        // شارة التوثيق (تظهر بـ elastic)
        PositionedDirectional(
          bottom: -2,
          end: -2,
          child: ScaleTransition(
            scale: badgePop,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final Animation<double> loop;
  const _ActiveChip({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _kMintSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) {
            final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 3);
            return Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _kMint.withAlpha((150 * p).toInt()), blurRadius: 5, spreadRadius: 1.5 * p)],
              ),
            );
          },
        ),
        const SizedBox(width: 5),
        const Text('نشط', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// كبسولة كود المريض + لمعة تمر عليها.
class _CodePill extends StatelessWidget {
  final Animation<double> loop;
  const _CodePill({required this.loop});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: _kLavender,
          child: Text('كود المريض: HL-0042',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: loop,
              builder: (_, __) => LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;
                final s = ((loop.value - 0.3) / 0.3).clamp(0.0, 1.0);
                return Stack(children: [
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
                            Colors.white.withAlpha(150),
                            Colors.white.withAlpha(0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ClinicBlock extends StatelessWidget {
  final Animation<double> loop;
  const _ClinicBlock({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) {
            final p = 0.5 + 0.5 * math.sin(loop.value * 2 * math.pi * 2);
            return Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.primary.withAlpha((30 * p).toInt()), blurRadius: 10, spreadRadius: 1.5 * p)],
              ),
              child: Transform.scale(
                scale: 1 + 0.08 * p,
                child: const Icon(Icons.add_box_outlined, color: AppColors.primary, size: 24),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العيادة المتابعة', style: AppTextStyles.caption),
              SizedBox(height: 3),
              Text('عيادة التغذية العلاجية المتخصصة',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────── مجموعة الإعدادات ─────────────────────────────

class _GroupCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1) items.add(const Divider(height: 1, thickness: 1, color: _kDivider));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _cardShadow(),
      ),
      child: Column(children: items),
    );
  }
}

/// صف إعداد: مربع أيقونة لافندر يميناً، العنوان + الوصف، ثم (شارة/نص) وسهم يساراً.
class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconWidget,
    this.trailing,
    this.onTap,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
      onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
      onTap: tappable
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            AnimatedScale(
              scale: _pressed ? 0.88 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _pressed ? _kMintSoft : _kLavender,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: widget.iconWidget ?? Icon(widget.icon, color: AppColors.primary, size: 25),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15.5)),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(widget.subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
            if (tappable) ...[
              const SizedBox(width: 6),
              AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                offset: Offset(_pressed ? -0.5 : 0, 0),
                child: const Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.textSecondary),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

// ───────────────────────────── المزيد (قابلة للطي) ─────────────────────────────

class _MoreCard extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;
  final List<_NavItem> items;
  final void Function(Widget screen) onOpen;
  final Widget lockedTile;

  const _MoreCard({
    required this.open,
    required this.onToggle,
    required this.items,
    required this.onOpen,
    required this.lockedTile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: _kLavender, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.dashboard_customize_outlined, color: AppColors.primary, size: 25),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المزيد', style: AppTextStyles.cardTitle),
                      SizedBox(height: 4),
                      Text('القياسات، السجل الطبي، الإنجازات والمواعيد', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: const Icon(Icons.expand_more_rounded, size: 24, color: AppColors.textSecondary),
                ),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: open
                ? Column(
                    children: [
                      for (final it in items) ...[
                        const Divider(height: 1, thickness: 1, color: _kDivider),
                        _SettingsTile(
                          icon: it.icon,
                          title: it.title,
                          subtitle: it.subtitle,
                          onTap: () => onOpen(it.screen()),
                        ),
                      ],
                      const Divider(height: 1, thickness: 1, color: _kDivider),
                      lockedTile,
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── تسجيل الخروج ─────────────────────────────

class _LogoutTile extends StatefulWidget {
  final Animation<double> loop;
  const _LogoutTile({required this.loop});

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        performLogoutFlow(context);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: widget.loop,
          builder: (_, __) {
            final t = widget.loop.value;
            final p = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
            // سهم يتحرك يميناً ويساراً للإيحاء بالخروج
            final nudge = 5 * (0.5 + 0.5 * math.sin(t * 2 * math.pi * 2));
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kLogoutBg,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withAlpha(18 + (22 * p).toInt()),
                    blurRadius: 14 + 8 * p,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
                  child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تسجيل الخروج',
                          style: TextStyle(color: _kLogoutText, fontWeight: FontWeight.w800, fontSize: 15.5)),
                      const SizedBox(height: 4),
                      Text('إنهاء الجلسة بأمان من هذا الجهاز',
                          style: AppTextStyles.caption.copyWith(color: _kLogoutText.withAlpha(200))),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(nudge, 0),
                  child: const Icon(Icons.east_rounded, color: AppColors.danger, size: 24),
                ),
              ]),
            );
          },
        ),
      ),
    );
  }
}
