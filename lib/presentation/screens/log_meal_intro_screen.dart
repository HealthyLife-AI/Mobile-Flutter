import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../data/mock/meal_mock_data.dart';
import 'meal_detail_screen.dart';
import 'food_search_screen.dart';
import '../../core/navigation/app_page_route.dart';

const Color _tipBg = Color(0xFFF3F5FC);
const Color _lavender = Color(0xFFEFF2FC);
const Color _lavenderSoft = Color(0xFFF5F7FD);

bool _reduceMotion(BuildContext c) => MediaQuery.of(c).disableAnimations;

/// "تسجيل وجبة" entry screen — branches into the two logging flows described
/// in the Mobile API Reference (POST /me/meal-logs with/without meal_item_id).
class LogMealIntroScreen extends StatefulWidget {
  const LogMealIntroScreen({super.key});

  @override
  State<LogMealIntroScreen> createState() => _LogMealIntroScreenState();
}

class _LogMealIntroScreenState extends State<LogMealIntroScreen> with TickerProviderStateMixin {
  /// حركة الدخول المتتابعة (مرة وحدة).
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  /// حركة مستمرة هادئة (طفو الأيقونات، توهج المصباح، لمعة الشارات...).
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion(context)) {
      _loop.stop();
      _intro.value = 1;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  Widget _reveal(double a, double b, Widget child, {double dy = 24}) {
    return AnimatedBuilder(
      animation: _intro,
      child: child,
      builder: (_, c) {
        final t = Interval(a, b, curve: Curves.easeOutCubic).transform(_intro.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: c),
        );
      },
    );
  }

  void _openPlannedMeal() {
    // لو ما في وجبة "حالية" بنرجع لأول وجبة بدل ما الشاشة تنهار.
    final meals = MockData.todayMeals;
    if (meals.isEmpty) return;
    final meal = meals.firstWhere((m) => m.status == MealStatus.current, orElse: () => meals.first);
    Navigator.of(context).push(AppPageRoute(builder: (_) => MealDetailScreen(meal: meal)));
  }

  void _openFoodSearch() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const FoodSearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          children: [
            _reveal(
              0,
              .35,
              Row(children: [
                if (canPop)
                  Semantics(
                    button: true,
                    label: 'رجوع',
                    child: _PressScale(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsetsDirectional.only(end: 10, top: 4, bottom: 4),
                        child: Icon(Icons.arrow_back_rounded, size: 26, color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                const Expanded(child: Text('تسجيل وجبة', style: AppTextStyles.h1)),
              ]),
              dy: -12,
            ),
            const SizedBox(height: 14),
            _reveal(
              .08,
              .42,
              const Text(
                'تسجيل ما تناولته بصدق هو خطوتك الأولى نحو نتائج مستدامة. أخصائيتك هنا لدعمك دائماً دون أي تقييم.',
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 16),
            _reveal(.16, .5, _buildTipCard()),
            const SizedBox(height: 22),
            _IntroOptionCard(
              delayMs: 420,
              phase: 0,
              loop: _loop,
              badge: 'الوجبات المعتمدة',
              badgeColor: AppColors.primary,
              icon: Icons.restaurant_rounded,
              iconTint: _lavender,
              notesTint: _lavenderSoft,
              blobTint: _lavender,
              title: 'سجّلت وجبة من خطتي',
              description: 'تأكيد سريع لتناول إحدى وجباتك المجدولة في جدول اليوم (فطور، سناك، غداء، عشاء) مع إمكانية تعديل البدائل المعتمدة.',
              note: 'مطابقة تلقائية للسعرات والمكونات المجدولة',
              noteIcon: Icons.check_circle_outline_rounded,
              note2: 'استبدال ذكي للبدائل المتكافئة بنقرة واحدة',
              note2Icon: Icons.sync_alt_rounded,
              footer: 'المتابعة لاختيار الوجبة (P-21)',
              onTap: _openPlannedMeal,
            ),
            const SizedBox(height: 16),
            _IntroOptionCard(
              delayMs: 640,
              phase: .5,
              loop: _loop,
              badge: 'بحث وتوثيق مرن',
              badgeColor: AppColors.accentGreen,
              icon: Icons.apple,
              iconTint: AppColors.accentGreenBg,
              notesTint: AppColors.accentGreenBg.withOpacity(.5),
              blobTint: AppColors.accentGreenBg,
              title: 'أكلت شيئاً خارج الخطة',
              description: 'تناولت طعاماً أو وجبة خفيفة لم تكن مدرجة في جدولك؟ سجّلها بسهولة بالبحث المباشر أو تحديد الغرامات التقريبية.',
              note: 'قاعدة بيانات غنية بالأطعمة العربية والوجبات الشائعة',
              noteIcon: Icons.storage_rounded,
              note2: 'لا داعي للشعور بالذنب، المرونة جزء أساسي من النجاح',
              note2Icon: Icons.favorite_border_rounded,
              footer: 'المتابعة للبحث وحساب الغرامات (P-22)',
              onTap: _openFoodSearch,
            ),
            const SizedBox(height: 20),
            _reveal(
              .8,
              1,
              AnimatedBuilder(
                animation: _loop,
                builder: (_, __) {
                  final s = 1 + .08 * math.pow(math.max(0, math.sin(_loop.value * 2 * math.pi)), 6);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(scale: s.toDouble(), child: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary)),
                      const SizedBox(width: 6),
                      const Flexible(child: Text('بياناتك الغذائية مشفرة وتُعامل بخصوصية طبية تامة', style: AppTextStyles.caption)),
                    ],
                  );
                },
              ),
              dy: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Tip card ─────────────────────────

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _tipBg, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // المصباح "ينوّر" بوميض عند الدخول، وبعدها يتنفّس بتوهج ناعم
        AnimatedBuilder(
          animation: Listenable.merge([_intro, _loop]),
          builder: (_, __) {
            final on = Interval(.35, .62).transform(_intro.value);
            final flicker = on >= 1 ? 1.0 : (on <= 0 ? 0.0 : math.sin(on * math.pi * 7).abs());
            final breathe = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
            final glow = flicker * (.18 + .3 * breathe);
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.3),
                boxShadow: [BoxShadow(color: const Color(0xFFFFC15A).withOpacity(glow), blurRadius: 12 + 10 * breathe, spreadRadius: 1 + 2 * breathe)],
              ),
              child: Icon(Icons.lightbulb_outline_rounded, color: AppColors.textPrimary.withOpacity(.55 + .45 * flicker), size: 22),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: 'إضاءة تشجيعية: ', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const TextSpan(text: 'التسجيل الدقيق يساعد أخصائيتك على ضبط سعراتك وملاءمة الوجبات القادمة حسب استجابة جسمك الطبيعية وتفضيلاتك اليومية.'),
            ]),
            style: AppTextStyles.caption.copyWith(height: 1.7),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────────── Option card ─────────────────────────────

class _IntroOptionCard extends StatefulWidget {
  final int delayMs;
  final double phase;
  final Animation<double> loop;
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final Color iconTint;
  final Color notesTint;
  final Color blobTint;
  final String title;
  final String description;
  final String note;
  final IconData noteIcon;
  final String note2;
  final IconData note2Icon;
  final String footer;
  final VoidCallback onTap;

  const _IntroOptionCard({
    required this.delayMs,
    required this.phase,
    required this.loop,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.iconTint,
    required this.notesTint,
    required this.blobTint,
    required this.title,
    required this.description,
    required this.note,
    required this.noteIcon,
    required this.note2,
    required this.note2Icon,
    required this.footer,
    required this.onTap,
  });

  @override
  State<_IntroOptionCard> createState() => _IntroOptionCardState();
}

class _IntroOptionCardState extends State<_IntroOptionCard> {
  static const int _span = 1150;
  bool _down = false;

  void _setDown(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    final reduce = _reduceMotion(context);
    final total = widget.delayMs + _span;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduce ? Duration.zero : Duration(milliseconds: total),
      builder: (context, t, _) {
        // مقطع زمني بالميلي ثانية داخل حركة هذه البطاقة
        double seg(int a, int b, [Curve curve = Curves.easeOutCubic]) =>
            Interval((widget.delayMs + a) / total, (widget.delayMs + b) / total, curve: curve).transform(t);

        final enter = seg(0, 650);
        final iconPop = seg(150, 800, Curves.elasticOut);

        return Opacity(
          opacity: enter.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 40),
            child: Transform(
              alignment: Alignment.bottomCenter,
              // ميلان خفيف عند الدخول يهدى لحد ما تستوي البطاقة
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0008)
                ..rotateX((1 - enter) * .18),
              child: _buildCard(context, seg, iconPop),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, double Function(int, int, [Curve]) seg, double iconPop) {
    final w = widget;

    return Semantics(
      button: true,
      label: w.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setDown(true),
        onTapUp: (_) => _setDown(false),
        onTapCancel: () => _setDown(false),
        onTap: () {
          HapticFeedback.selectionClick();
          w.onTap();
        },
        child: AnimatedScale(
          scale: _down ? .975 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_down ? .03 : .07),
                  blurRadius: _down ? 10 : 22,
                  offset: Offset(0, _down ? 3 : 9),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Stack(
                children: [
                  // بقعة الزاوية: تتنفّس وتنجرف ببطء
                  Positioned(
                    top: 0,
                    left: 0,
                    child: AnimatedBuilder(
                      animation: w.loop,
                      builder: (_, __) {
                        final v = 2 * math.pi * (w.loop.value + w.phase);
                        return Transform.translate(
                          offset: Offset(-52 + 6 * math.sin(v), -52 + 6 * math.cos(v)),
                          child: Transform.scale(
                            scale: 1 + .06 * math.sin(v),
                            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: w.blobTint, shape: BoxShape.circle)),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopRow(seg, iconPop),
                        const SizedBox(height: 16),
                        _fade(seg(350, 800), Text(w.description, style: AppTextStyles.caption.copyWith(height: 1.8))),
                        const SizedBox(height: 14),
                        _fade(
                          seg(450, 900),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: w.notesTint, borderRadius: BorderRadius.circular(16)),
                            child: Column(children: [
                              _fade(seg(560, 960), _noteRow(w.noteIcon, w.note), dx: 10),
                              const SizedBox(height: 8),
                              _fade(seg(680, 1080), _noteRow(w.note2Icon, w.note2), dx: 10),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _fade(seg(780, 1150), _buildFooter()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fade(double t, Widget child, {double dx = 0}) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(offset: Offset(dx * (1 - t), 10 * (1 - t)), child: child),
    );
  }

  Widget _buildTopRow(double Function(int, int, [Curve]) seg, double iconPop) {
    final w = widget;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // الأيقونة تطفو وتميل بخفّة
        AnimatedBuilder(
          animation: w.loop,
          builder: (_, child) {
            final v = 2 * math.pi * (w.loop.value + w.phase);
            return Transform.translate(
              offset: Offset(0, 3 * math.sin(v)),
              child: Transform.rotate(angle: .05 * math.sin(v), child: child),
            );
          },
          child: Transform.scale(
            scale: iconPop.clamp(0.0, 1.3).toDouble(),
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(color: w.iconTint, borderRadius: BorderRadius.circular(18)),
              child: Icon(w.icon, color: AppColors.primary, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fade(seg(200, 650), _buildBadge()),
              const SizedBox(height: 8),
              _fade(seg(260, 710), Text(w.title, style: AppTextStyles.h1.copyWith(fontSize: 19))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildChevron(),
      ],
    );
  }

  /// الشارة: لمعة تمرّ فوقها كل دورة.
  Widget _buildBadge() {
    final w = widget;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: w.badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text(w.badge, style: AppTextStyles.caption.copyWith(color: w.badgeColor, fontWeight: FontWeight.w700)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: w.loop,
                builder: (_, __) {
                  final v = ((w.loop.value + w.phase) % 1.0) * 1.6;
                  final x = -1.8 + 3.6 * v.clamp(0.0, 1.0);
                  return Align(
                    alignment: Alignment(x, 0),
                    child: FractionallySizedBox(
                      widthFactor: .35,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(.55), Colors.white.withOpacity(0)]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// دائرة السهم: تلمّح بحركة لليسار كل دورة، وعند الضغط تمتلئ باللون وتنزلق.
  Widget _buildChevron() {
    final w = widget;
    return AnimatedBuilder(
      animation: w.loop,
      builder: (_, __) {
        final n = math.pow(math.max(0, math.sin(2 * math.pi * (w.loop.value + w.phase))), 8).toDouble();
        final dx = -5 * n + (_down ? -4 : 0);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: _down ? AppColors.primary : w.iconTint, shape: BoxShape.circle),
            // chevron_right بينعكس تلقائياً في RTL ويشاور لليسار (اتجاه التقدّم)
            child: Icon(Icons.chevron_right_rounded, color: _down ? Colors.white : AppColors.textPrimary, size: 24),
          ),
        );
      },
    );
  }

  Widget _noteRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 17, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary))),
    ]);
  }

  Widget _buildFooter() {
    final w = widget;
    return AnimatedBuilder(
      animation: w.loop,
      builder: (_, __) {
        final n = math.pow(math.max(0, math.sin(2 * math.pi * (w.loop.value + w.phase))), 8).toDouble();
        return Row(children: [
          Expanded(
            child: Text(w.footer, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          Transform.translate(
            offset: Offset(-6 * n + (_down ? -6 : 0), 0),
            // arrow_forward بينعكس في RTL ويشاور لليسار
            child: const Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.primary),
          ),
        ]);
      },
    );
  }
}

// ───────────────────────────── Helpers ─────────────────────────────

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScale({required this.child, required this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(scale: _down ? .9 : 1, duration: const Duration(milliseconds: 110), child: widget.child),
    );
  }
}