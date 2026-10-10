import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_page_route.dart';
import '../../data/mock/meal_mock_data.dart';
import '../widgets/scroll_edge_fade.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/offline_banner.dart';
import '../widgets/connection_status_sheet.dart';
import 'meal_detail_screen.dart';
import 'notification_settings_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design tokens (local to this screen)
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static Color get teal => AppColors.primary;
  static const ink = Color(0xFF16303A);
  static const muted = Color(0xFF8795A0);
  static const mint = Color(0xFFD6F5E9);
  static const mintSoft = Color(0xFFE6F8F0);
  static const green = Color(0xFF1E9E6F);
  static const greyBox = Color(0xFFF3F5F6);
  static const line = Color(0xFFE6EBED);
  static const lavender = Color(0xFFD9DBF2);
  static const amber = Color(0xFFC98A1F);
  static const amberBg = Color(0xFFFDF3E4);
}

TextStyle _ts(double size, {FontWeight w = FontWeight.w600, Color? c, double? h}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c ?? _C.ink, height: h);

String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

// ─────────────────────────────────────────────────────────────────────────────
//  Display data (replace with your real Meal model when ready)
// ─────────────────────────────────────────────────────────────────────────────
enum _SlotKind { done, active, collapsed }

class _Item {
  final String name, qty;
  const _Item(this.name, this.qty);
}

class _Slot {
  final String title, time;
  final String? subtitle, alt;
  final IconData icon;
  final _SlotKind kind;
  final List<_Item> items;
  final int kcal;
  const _Slot({
    required this.title,
    required this.icon,
    required this.kind,
    required this.kcal,
    this.time = '',
    this.subtitle,
    this.alt,
    this.items = const [],
  });
}

const _slots = <_Slot>[
  _Slot(
    title: 'الفطور',
    time: '08:00 صباحاً',
    icon: Icons.free_breakfast_outlined,
    kind: _SlotKind.done,
    kcal: 350,
    alt: 'البديل المقترح: 100g جبنة قريش',
    items: [
      _Item('2 بيضة مسلوقة', '100g'),
      _Item('1 رغيف خبز شوفان', '60g'),
      _Item('خيار وطماطم كرزية', 'طازج'),
    ],
  ),
  _Slot(
    title: 'الغداء',
    time: '02:30 ظهراً',
    icon: Icons.restaurant_rounded,
    kind: _SlotKind.active,
    kcal: 520,
    items: [
      _Item('صدر دجاج مشوي', '150g'),
      _Item('أرز أسمر مطبوخ على البخار', '120g'),
      _Item('سلطة خضراء مع متبلة زيت زيتون', 'طبق كبير'),
    ],
  ),
  _Slot(
    title: 'العشاء - 08:00 مساءً',
    subtitle: 'خفيف وخالٍ - 320 سعرة حرارية تقريباً',
    icon: Icons.dinner_dining_rounded,
    kind: _SlotKind.collapsed,
    kcal: 320,
    items: [
      _Item('زبادي يوناني', '150g'),
      _Item('خضار سوتيه', '200g'),
      _Item('خبز توست أسمر', '40g'),
    ],
  ),
  _Slot(
    title: 'سناك المساء',
    subtitle: 'فاكهة موسمية (120g)',
    icon: Icons.eco_rounded,
    kind: _SlotKind.collapsed,
    kcal: 180,
  ),
];

// Replace with real values from your data layer.
const _loggedMeals = 2;
const _dailyTargetKcal = 1170;

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _loading = true;
  HomeConnectionState _conn = HomeConnectionState.online;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  /// Demo affordance: tap the pulsing status dot next to the greeting to
  /// preview the offline → syncing → online cycle.
  void _toggleConnection() {
    if (_conn == HomeConnectionState.online) {
      setState(() {
        _conn = HomeConnectionState.offline;
        _pendingCount = 1;
      });
      return;
    }
    if (_conn == HomeConnectionState.offline) {
      setState(() => _conn = HomeConnectionState.syncing);
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        final synced = _pendingCount;
        setState(() {
          _conn = HomeConnectionState.online;
          _pendingCount = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(synced > 0 ? 'تمت مزامنة $synced عنصر بنجاح' : 'أنت متصل الآن',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
      });
    }
  }

  void _openMeal(int i) {
    final meals = MockData.todayMeals;
    if (i >= meals.length) return;
    Navigator.of(context).push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meals[i])));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: HomeSkeleton()));
    }

    final offlineUi = _conn != HomeConnectionState.online;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SafeArea(
              child: ScrollEdgeFade(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
                  children: [
                    _Reveal(
                      child: _Header(
                        offline: offlineUi,
                        onBell: () => Navigator.of(context)
                            .push(AppPageRoute(builder: (_) => const NotificationSettingsScreen())),
                        onStatus: _toggleConnection,
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: offlineUi
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: OfflineBanner(
                                state: _conn,
                                pendingCount: _pendingCount,
                                onTap: () => ConnectionStatusSheet.show(context),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: 16),
                    const _Reveal(
                      delayMs: 120,
                      from: Offset(0, 0.12),
                      child: _ProgressCard(logged: _loggedMeals, total: 4),
                    ),
                    const SizedBox(height: 20),
                    const _Reveal(delayMs: 220, child: _SectionHeader()),
                    const SizedBox(height: 12),
                    for (int i = 0; i < _slots.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _Reveal(
                          delayMs: 280 + i * 110,
                          from: const Offset(0, 0.1),
                          child: _slots[i].kind == _SlotKind.collapsed
                              ? _CollapsedCard(slot: _slots[i])
                              : _MealCard(
                                  slot: _slots[i],
                                  syncPending: offlineUi && _pendingCount > 0 && i == 0,
                                  onLog: () => _openMeal(i),
                                ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    const _Reveal(delayMs: 760, child: _TipCard()),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Generic reveal (fade + slide, with delay)
// ─────────────────────────────────────────────────────────────────────────────
class _Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final int durationMs;
  final Offset from;
  const _Reveal({
    required this.child,
    this.delayMs = 0,
    this.durationMs = 500,
    this.from = const Offset(0, 0.08),
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: Duration(milliseconds: widget.durationMs));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  late final Animation<Offset> _s = Tween<Offset>(begin: widget.from, end: Offset.zero).animate(_a);
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _a, child: SlideTransition(position: _s, child: widget.child));
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool offline;
  final VoidCallback onBell, onStatus;
  const _Header({required this.offline, required this.onBell, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Tooltip(
                  message: offline ? 'اضغط للمزامنة والعودة للاتصال' : 'متصل — اضغط لمعاينة وضع عدم الاتصال',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onStatus,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                      child: _StatusDot(offline: offline),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('مرحباً سارة 👋',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: _ts(21, w: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: _C.muted),
                const SizedBox(width: 6),
                Text('الأحد، 21 سبتمبر 2025', style: _ts(12, c: _C.muted)),
              ]),
            ],
          ),
        ),
        _BellButton(onTap: onBell),
      ],
    );
  }
}

class _StatusDot extends StatefulWidget {
  final bool offline;
  const _StatusDot({required this.offline});
  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.offline ? _C.amber : _C.green;
    return SizedBox(
      width: 22,
      height: 22,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_c.value);
          return Stack(alignment: Alignment.center, children: [
            Container(
              width: 9 + 13 * t,
              height: 9 + 13 * t,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.35 * (1 - t))),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 9,
              height: 9,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ]);
        },
      ),
    );
  }
}

class _BellButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BellButton({required this.onTap});
  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat();
  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _C.teal, width: 1.4),
          ),
          child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final t = _c.value;
                // a quick "ring" every few seconds
                final angle = t < 0.14 ? math.sin(t / 0.14 * math.pi * 4) * 0.28 * (1 - t / 0.14) : 0.0;
                return Transform.rotate(angle: angle, alignment: Alignment.topCenter, child: child);
              },
              child: Icon(Icons.notifications_none_rounded, color: _C.teal, size: 23),
            ),
            Positioned(
              top: 10,
              left: 11,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _C.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Progress card
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatefulWidget {
  final int logged, total;
  const _ProgressCard({required this.logged, required this.total});
  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> with SingleTickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.logged / widget.total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.mint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _C.teal.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                AnimatedBuilder(
                  animation: _loop,
                  builder: (context, child) =>
                      Transform.scale(scale: 1 + 0.07 * math.sin(_loop.value * 2 * math.pi), child: child),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: _C.teal, borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Text('الالتزام اليوم', style: _ts(17, w: FontWeight.w800)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${(v * 100).round()}%', style: _ts(13, w: FontWeight.w800, c: _C.teal)),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Text('المسار اليومي للوجبات', style: _ts(11.5, c: _C.muted)),
                const Spacer(),
                Text('${widget.logged} من ${widget.total} وجبات مسجلة', style: _ts(11.5, c: _C.muted)),
              ]),
              const SizedBox(height: 8),
              _ProgressBar(value: v, loop: _loop),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Animation<double> loop;
  const _ProgressBar({required this.value, required this.loop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(children: [
          const Positioned.fill(child: ColoredBox(color: _C.lavender)),
          // Fill starts from the right (RTL).
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              heightFactor: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_C.teal, _C.teal.withValues(alpha: 0.82)]),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: loop,
                      builder: (context, _) => Align(
                        alignment: Alignment(1.6 - 3.2 * loop.value, 0),
                        child: FractionallySizedBox(
                          widthFactor: 0.4,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('جدول الوجبات', style: _ts(17, w: FontWeight.w800)),
      const Spacer(),
      Icon(Icons.local_fire_department_outlined, size: 15, color: _C.teal),
      const SizedBox(width: 4),
      TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: _dailyTargetKcal),
        duration: const Duration(milliseconds: 1300),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) =>
            Text('${_fmt(v)} سعرة مستهدفة', style: _ts(11.5, w: FontWeight.w700, c: _C.teal)),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Meal card (done / active)
// ─────────────────────────────────────────────────────────────────────────────
class _MealCard extends StatefulWidget {
  final _Slot slot;
  final bool syncPending;
  final VoidCallback onLog;
  const _MealCard({required this.slot, required this.syncPending, required this.onLog});
  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> with SingleTickerProviderStateMixin {
  late final AnimationController _glow =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  bool get _active => widget.slot.kind == _SlotKind.active;

  @override
  void initState() {
    super.initState();
    if (_active) _glow.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slot;
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final g = _active ? Curves.easeInOut.transform(_glow.value) : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _active ? _C.teal.withValues(alpha: 0.14) : _C.line),
            gradient: _active
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white, Color(0xFFD3F0E6)],
                    stops: [0, 0.55, 1],
                  )
                : null,
            color: _active ? null : Colors.white,
            boxShadow: [
              BoxShadow(
                color: _active
                    ? _C.teal.withValues(alpha: 0.10 + 0.12 * g)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _active ? 18 + 12 * g : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_active)
            SizedBox(
              height: 3.5,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: v,
                    heightFactor: 1,
                    child: ColoredBox(color: _C.teal),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _header(s),
              const SizedBox(height: 12),
              _itemsBox(s),
              if (s.alt != null) _altRow(s.alt!),
              const SizedBox(height: 12),
              _footer(s),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _header(_Slot s) {
    final Widget chip;
    if (widget.syncPending) {
      chip = _StatusChip(
          key: const ValueKey('sync'),
          label: 'بانتظار المزامنة',
          icon: Icons.hourglass_bottom_rounded,
          bg: _C.amberBg,
          fg: _C.amber);
    } else if (_active) {
      chip = const _StatusChip(
          key: ValueKey('wait'),
          label: 'بانتظار التسجيل',
          icon: Icons.schedule_rounded,
          bg: Colors.white,
          fg: _C.muted,
          bordered: true);
    } else {
      chip = _StatusChip(
          key: const ValueKey('done'),
          label: 'تم التسجيل',
          icon: Icons.check_circle_rounded,
          bg: _C.mint,
          fg: _C.green);
    }

    return Row(children: [
      _IconTile(icon: s.icon),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: _C.teal, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(s.title, style: _ts(16, w: FontWeight.w800)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.schedule_rounded, size: 11, color: _C.muted),
            const SizedBox(width: 4),
            Text(s.time, style: _ts(11, c: _C.muted)),
          ]),
        ]),
      ),
      AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: chip),
    ]);
  }

  Widget _itemsBox(_Slot s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _C.greyBox, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        for (int i = 0; i < s.items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == s.items.length - 1 ? 0 : 10),
            child: _Reveal(
              delayMs: 500 + i * 90,
              from: const Offset(0.06, 0),
              child: _ItemRow(item: s.items[i]),
            ),
          ),
      ]),
    );
  }

  Widget _altRow(String alt) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _C.line),
      ),
      child: Row(children: [
        Icon(Icons.swap_horiz_rounded, size: 16, color: _C.teal),
        const SizedBox(width: 6),
        Expanded(child: Text(alt, style: _ts(11.5))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _C.mint, borderRadius: BorderRadius.circular(20)),
          child: Text('بديل متاح', style: _ts(10, w: FontWeight.w700, c: _C.teal)),
        ),
      ]),
    );
  }

  Widget _footer(_Slot s) {
    final kcal = Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.bolt_rounded, size: 15, color: _C.muted),
      const SizedBox(width: 3),
      TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: s.kcal),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text('$v سعرة حرارية', style: _ts(12, c: _C.muted)),
      ),
    ]);

    if (_active) {
      return Row(children: [kcal, const Spacer(), _LogButton(onTap: widget.onLog)]);
    }
    return Row(children: [
      kcal,
      const Spacer(),
      const Icon(Icons.check_rounded, size: 15, color: _C.green),
      const SizedBox(width: 4),
      Text('مكتمل في الموعد', style: _ts(11.5, w: FontWeight.w700, c: _C.green)),
    ]);
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  final bool soft;
  const _IconTile({required this.icon, this.soft = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: soft ? 38 : 42,
      height: soft ? 38 : 42,
      decoration: BoxDecoration(
        color: soft ? _C.greyBox : null,
        gradient: soft ? null : const LinearGradient(colors: [_C.mint, _C.mintSoft]),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: soft ? 19 : 21, color: _C.teal),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final _Item item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 5, height: 5, decoration: BoxDecoration(color: _C.teal, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(item.name, style: _ts(12.5))),
      Text(item.qty, style: _ts(11, c: _C.muted)),
    ]);
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg, fg;
  final bool bordered;
  const _StatusChip({
    super.key,
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: bordered ? Border.all(color: _C.line) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: _ts(11, w: FontWeight.w700, c: fg)),
        ]),
      ),
    );
  }
}

class _LogButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogButton({required this.onTap});
  @override
  State<_LogButton> createState() => _LogButtonState();
}

class _LogButtonState extends State<_LogButton> with SingleTickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
  bool _down = false;

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _C.teal,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('تسجيل الوجبة', style: _ts(12.5, w: FontWeight.w700, c: Colors.white)),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _down ? 0.25 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                ),
              ]),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, _) {
                    final p = (_loop.value / 0.4).clamp(0.0, 1.0);
                    return Align(
                      alignment: Alignment(-1.6 + 3.2 * p, 0),
                      child: FractionallySizedBox(
                        widthFactor: 0.35,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.28),
                              Colors.white.withValues(alpha: 0),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Collapsed card (dinner / snack)
// ─────────────────────────────────────────────────────────────────────────────
class _CollapsedCard extends StatefulWidget {
  final _Slot slot;
  const _CollapsedCard({required this.slot});
  @override
  State<_CollapsedCard> createState() => _CollapsedCardState();
}

class _CollapsedCardState extends State<_CollapsedCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.slot;
    final expandable = s.items.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: expandable ? () => setState(() => _open = !_open) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _open ? _C.teal.withValues(alpha: 0.25) : _C.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _open ? 0.06 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            _IconTile(icon: s.icon, soft: true),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title, style: _ts(14.5, w: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(s.subtitle ?? '', style: _ts(11, c: _C.muted)),
              ]),
            ),
            if (expandable)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _open ? _C.teal : _C.greyBox,
                ),
                child: AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _open ? Colors.white : _C.teal),
                ),
              )
            else
              Text('${s.kcal} سعرة', style: _ts(10.5, c: _C.muted)),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _C.greyBox, borderRadius: BorderRadius.circular(15)),
                    child: Column(children: [
                      for (int i = 0; i < s.items.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == s.items.length - 1 ? 0 : 10),
                          child: _Reveal(
                            delayMs: 80 + i * 80,
                            from: const Offset(0.06, 0),
                            child: _ItemRow(item: s.items[i]),
                          ),
                        ),
                    ]),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tip card
// ─────────────────────────────────────────────────────────────────────────────
class _TipCard extends StatefulWidget {
  const _TipCard();
  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F5), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final g = (math.sin(_c.value * 2 * math.pi) + 1) / 2;
            return Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: _C.teal.withValues(alpha: 0.10 + 0.25 * g), blurRadius: 6 + 12 * g),
                ],
              ),
              child: child,
            );
          },
          child: Icon(Icons.lightbulb_outline_rounded, size: 20, color: _C.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'شرب كوبين من الماء قبل كل وجبة يدعم الحرق المنتظم ويساعدك على الشعور بالشبع الهادئ. أنت تسيرين بوتيرة ممتازة!',
            style: _ts(11.5, c: const Color(0xFF4B5F69), h: 1.7),
          ),
        ),
      ]),
    );
  }
}