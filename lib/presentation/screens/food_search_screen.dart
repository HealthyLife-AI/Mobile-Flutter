import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entities.dart';
import '../../data/mock/meal_mock_data.dart';
import '../widgets/food_tag_icon.dart';
import '../widgets/clinical_trust_footer.dart';
import '../widgets/gradient_cta_button.dart';
import 'quantity_selector_screen.dart';
import 'barcode_scanner_screen.dart';
import '../../core/navigation/app_page_route.dart';

/// true = أرقام عربية-هندية (٥٢) زي التصميم. اجعليها false لو بدك 52.
const bool _kArabicIndicDigits = true;

const Color _softMint = Color(0xFFF1FAF7);

String _d(Object v) {
  final s = '$v';
  if (!_kArabicIndicDigits) return s;
  const west = '0123456789';
  const east = '٠١٢٣٤٥٦٧٨٩';
  return s.split('').map((c) {
    final i = west.indexOf(c);
    return i == -1 ? c : east[i];
  }).join();
}

String _foodsLabel(int n) {
  if (n == 1) return 'طعام واحد';
  if (n == 2) return 'طعامان';
  if (n >= 3 && n <= 10) return '${_d(n)} أطعمة';
  return '${_d(n)} طعاماً';
}

bool _reduceMotion(BuildContext c) => MediaQuery.of(c).disableAnimations;

/// 5.4 "Ate Something Off-Plan" — search & browse (fork & knife tab).
/// v2 correction: there is no AI chat here — search + manual estimate is
/// the confirmed baseline (section 0). BeetAI is left as an open question.
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with TickerProviderStateMixin {
  String _filter = 'الكل';
  String _query = '';
  // الترتيب زي التصميم: "الكل" أول واحد من اليمين.
  final List<String> _categories = const ['الكل', 'فواكه وخضار', 'نشويات وحبوب', 'بروتينات'];
  late final List<GlobalKey> _chipKeys = List.generate(_categories.length, (_) => GlobalKey());

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  /// حركة الدخول المتتابعة (مرة وحدة).
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  /// حركة مستمرة (نبض القلب، نقطة الإشعار، تنفّس الزر).
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();

  /// أول تحميل للقائمة فقط بيستنى انتهاء دخول الأقسام العلوية.
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _firstLoad = false);
  }

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
    _controller.dispose();
    _focus.dispose();
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _p(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      Interval(a, b, curve: curve).transform(_intro.value);

  Widget _reveal(double a, double b, Widget child, {double dy = 26}) {
    final t = _p(a, b);
    return Opacity(
      opacity: t.clamp(0.0, 1.0).toDouble(),
      child: Transform.translate(offset: Offset(0, (1 - t) * dy), child: child),
    );
  }

  // M16 — category filter toggle: solid-fill cross-fade (AnimatedContainer
  // below) + the row auto-scrolling to center the tapped chip, then M17
  // refreshes the results list immediately.
  void _selectFilter(String c) {
    if (c == _filter) return;
    HapticFeedback.selectionClick();
    setState(() => _filter = c);
    final i = _categories.indexOf(c);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _chipKeys[i].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
    });
  }

  List<SearchableFood> get _filtered {
    final q = _query.trim();
    return MockData.foodSearchResults.where((f) {
      final matchesQuery = q.isEmpty || f.name.contains(q);
      final matchesFilter = _filter == 'الكل' ||
          (_filter == 'بروتينات' && (f.category == 'cookedProtein' || f.category == 'dairy')) ||
          (_filter == 'نشويات وحبوب' && (f.category == 'carb' || f.category == 'naturalSugar')) ||
          (_filter == 'فواكه وخضار' && (f.category == 'redFruit' || f.category == 'greenFruit'));
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _openWhatsAppSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // M18 — bottom sheet enters via SlideUp with a scrim 0 -> 0.3.
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => const _WhatsAppRequestSheet(),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(AppPageRoute(builder: (_) => const BarcodeScannerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _intro,
          builder: (context, _) => Column(
            children: [
              _reveal(0, .2, _buildHeader(), dy: -14),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  children: [
                    // Reassurance card (section 1 tone): never judgmental.
                    _reveal(.06, .32, _buildReassurance()),
                    const SizedBox(height: 16),
                    _reveal(.16, .4, _buildSearchField()),
                    const SizedBox(height: 14),
                    _reveal(.24, .48, _buildChips()),
                    const SizedBox(height: 18),
                    _reveal(.32, .54, _buildResultsHeader(results.length)),
                    const SizedBox(height: 10),
                    // M17 — results fade out on mismatch, new ones enter staggered
                    // (never an instant jump/flicker). Keyed by filter+query so the
                    // whole result set restages when either changes.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        switchOutCurve: Curves.easeOut,
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: results.isEmpty
                            ? _NoResults(key: ValueKey('none-$_filter-$_query'), query: _query.trim())
                            : Column(
                                key: ValueKey('$_filter-$_query'),
                                children: [
                                  for (int i = 0; i < results.length; i++)
                                    _ResultRow(
                                      food: results[i],
                                      delay: Duration(milliseconds: (_firstLoad ? 380 : 0) + math.min(i, 8) * 45),
                                    ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _reveal(.6, .92, _CantFindItCard(onWhatsApp: _openWhatsAppSheet, loop: _loop)),
                    _reveal(.78, 1, const ClinicalTrustFooter(), dy: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 18, 6),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'رجوع',
            child: _PressScale(
              onTap: () => Navigator.of(context).maybePop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_rounded, size: 26, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 2),
          const Expanded(child: Text('أكلت شيئاً خارج الخطة', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.h1)),
          Semantics(
            button: true,
            label: 'الإشعارات',
            child: _PressScale(
              onTap: () {},
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 26, color: AppColors.textPrimary),
                    PositionedDirectional(
                      top: 9,
                      end: 9,
                      child: AnimatedBuilder(
                        animation: _loop,
                        builder: (_, __) {
                          final s = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
                          return Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5484D),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFFE5484D).withOpacity(.5 * s), blurRadius: 6, spreadRadius: 2 * s)],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Reassurance card ─────────────────────────

  Widget _buildReassurance() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softMint,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withOpacity(.06)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 8))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // القلب: نبضتان في كل دورة + توهج ناعم
        AnimatedBuilder(
          animation: _loop,
          builder: (_, __) {
            final x = (_loop.value * 2) % 1.0;
            final beat = 1 + .14 * math.pow(math.sin(math.pi * x), 14);
            final glow = .5 + .5 * math.sin(_loop.value * 2 * math.pi);
            return Transform.scale(
              scale: beat.toDouble(),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.18 + .16 * glow), blurRadius: 10 + 8 * glow, spreadRadius: 1)],
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 21),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                  child: Text(
                    'لا داعي للقلق، نحن معك',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.pill)),
                  child: const Text('متابعة آمنة', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 6),
              const Text(
                'تسجيل كل ما تناولته بصدق يمكّن أخصائيتك من المتابعة الدقيقة وضبط خطتك بسلاسة دون حرمان.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── Search field ─────────────────────────

  Widget _buildSearchField() {
    final focused = _focus.hasFocus;
    return AnimatedScale(
      scale: focused ? 1.012 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: focused ? AppColors.primary.withOpacity(.55) : Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: focused ? 0.16 : 0.05),
              blurRadius: focused ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: focused ? 1.18 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                  hintText: 'ابحث بالاسم العربي أو الإنجليزي',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
              child: _query.isEmpty
                  ? const SizedBox(key: ValueKey('noclear'))
                  : Semantics(
                      button: true,
                      label: 'مسح البحث',
                      child: _PressScale(
                        key: const ValueKey('clear'),
                        onTap: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
            ),
            Semantics(
              button: true,
              label: 'مسح الباركود',
              child: _PressScale(
                onTap: _openScanner,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.qr_code_scanner_rounded, size: 22, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Category chips ─────────────────────────

  Widget _buildChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _categories[i];
          final active = c == _filter;
          return _PressScale(
            key: _chipKeys[i],
            onTap: () => _selectFilter(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.chipInactiveBg,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: active ? [BoxShadow(color: AppColors.primary.withOpacity(.28), blurRadius: 12, offset: const Offset(0, 4))] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: AppTextStyles.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(c),
                  ),
                  // علامة الصح تنفتح بحركة بدل ما تظهر فجأة
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: active
                        ? const Padding(
                            padding: EdgeInsetsDirectional.only(start: 6),
                            child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────── Results header ─────────────────────────

  Widget _buildResultsHeader(int count) {
    return Row(
      children: [
        const Text('الأطعمة المقترحة', style: AppTextStyles.sectionHeading),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .6), end: Offset.zero).animate(a), child: c),
            ),
            child: Text(
              _foodsLabel(count),
              key: ValueKey(count),
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
        Text('لكل ${_d(100)} غ', style: AppTextStyles.caption),
      ],
    );
  }
}

// ───────────────────────────── Result row ─────────────────────────────

class _ResultRow extends StatefulWidget {
  final SearchableFood food;
  final Duration delay;
  const _ResultRow({required this.food, required this.delay});

  @override
  State<_ResultRow> createState() => _ResultRowState();
}

class _ResultRowState extends State<_ResultRow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  bool _down = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion(context)) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    final tagIcon = AppColors.foodTagIcon(f.category);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final enter = Curves.easeOutCubic.transform(Interval(0, .6).transform(_c.value));
        final pop = Curves.elasticOut.transform(Interval(.25, 1).transform(_c.value));
        final count = Curves.easeOutCubic.transform(Interval(.15, .9).transform(_c.value));

        return Opacity(
          opacity: enter.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 18),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => setState(() => _down = true),
              onTapUp: (_) => setState(() => _down = false),
              onTapCancel: () => setState(() => _down = false),
              onTap: () => Navigator.of(context).push(AppPageRoute(builder: (_) => QuantitySelectorScreen(food: f))),
              child: AnimatedScale(
                scale: _down ? .97 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.cardSmall),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Transform.scale(scale: pop.clamp(0.0, 1.4).toDouble(), child: FoodTagIcon(category: f.category)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(f.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.body)),
                      const SizedBox(width: 8),
                      // Calorie badge: light color per food CATEGORY (2.3), not macro.
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.foodTagBg(f.category), borderRadius: BorderRadius.circular(AppRadius.pill)),
                            child: Text(
                              '${_d((f.caloriesPer100g * count).round())} سعرة',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: tagIcon),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('${_d(100)} غرام', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(width: 4),
                      // السهم يتحرك باتجاه الانتقال عند الضغط
                      AnimatedSlide(
                        offset: _down ? const Offset(-.35, 0) : Offset.zero,
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        child: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (_, t, child) => Transform.scale(scale: t.clamp(0.0, 1.3).toDouble(), child: child),
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 12),
          Text(query.isEmpty ? 'لا توجد أطعمة في هذا التصنيف' : 'لا نتائج مطابقة لـ "$query"', style: AppTextStyles.secondary, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text('جرّبي كلمة أخرى أو اطلبي إضافة الصنف من الأسفل', style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ───────────────────────────── Can't find it card ─────────────────────────────

/// The "Can't find it" state — always at the bottom of the list, per spec,
/// not only as an empty state. Two buttons: WhatsApp request (M18 sheet)
/// and "Estimate manually" (opens 5.5 directly).
class _CantFindItCard extends StatelessWidget {
  final VoidCallback onWhatsApp;
  final Animation<double> loop;
  const _CantFindItCard({required this.onWhatsApp, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _softMint,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // الأفاتار + نقطة "متصلة" تنبض
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(radius: 24, backgroundColor: AppColors.primaryTint, child: Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 26)),
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: AnimatedBuilder(
                        animation: loop,
                        builder: (_, __) {
                          final s = .5 + .5 * math.sin(loop.value * 2 * math.pi);
                          return Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF19D3A2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [BoxShadow(color: const Color(0xFF19D3A2).withOpacity(.5 * s), blurRadius: 6, spreadRadius: 2 * s)],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('لم تجد ما تبحث عنه؟', style: AppTextStyles.cardTitle),
                    SizedBox(height: 2),
                    Text('أخصائيتك أ. خلود العربي بانتظارك', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'يمكنك إرسال اسم الصنف أو صورته لأخصائيتك لتضيفه إلى قاعدة بياناتك فوراً، أو لتقدير مكوناته الأساسية دون انقطاع عن أهدافك.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          // الزر الرئيسي يتنفّس بخفّة ليلفت الانتباه
          AnimatedBuilder(
            animation: loop,
            builder: (_, child) => Transform.scale(scale: 1 + .012 * math.sin(loop.value * 2 * math.pi), child: child),
            child: GradientCtaButton(label: 'طلب إضافة صنف جديد عبر واتساب', icon: Icons.chat_rounded, onPressed: onWhatsApp),
          ),
          const SizedBox(height: 10),
          GradientCtaButton(
            label: 'تقدير السعرات يدوياً (سريع)',
            outlined: true,
            onPressed: () => Navigator.of(context).push(
              AppPageRoute(builder: (_) => const QuantitySelectorScreen(food: SearchableFood(name: 'تقدير يدوي', caloriesPer100g: 100, macro: 'default'))),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── WhatsApp sheet ─────────────────────────────

class _WhatsAppRequestSheet extends StatelessWidget {
  const _WhatsAppRequestSheet();

  Widget _stagger(int index, Widget child) {
    final delay = 120 + index * 90;
    final total = delay + 450;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (_, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0).toDouble(),
        child: Transform.translate(offset: Offset(0, (1 - t) * 16), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 750),
            curve: Curves.elasticOut,
            builder: (_, t, child) => Transform.scale(scale: t.clamp(0.0, 1.3).toDouble(), child: child),
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
              child: const Icon(Icons.chat_rounded, color: AppColors.primary, size: 26),
            ),
          ),
          const SizedBox(height: 14),
          _stagger(0, const Text('طلب إضافة صنف جديد', style: AppTextStyles.h1)),
          const SizedBox(height: 10),
          _stagger(
            1,
            const Text(
              'أرسلي اسم الصنف أو صورته لأخصائيتك عبر واتساب، وستتم إضافته إلى قاعدة بياناتك بأسرع وقت ممكن.',
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary,
            ),
          ),
          const SizedBox(height: 20),
          _stagger(
            2,
            GradientCtaButton(gradient: CtaGradientType.voice, label: 'فتح واتساب', icon: Icons.chat_rounded, onPressed: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Helpers ─────────────────────────────

/// ضغطة بتصغّر العنصر قليلاً (إحساس لمسي).
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressScale({super.key, required this.child, required this.onTap});

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
      child: AnimatedScale(
        scale: _down ? .92 : 1,
        duration: const Duration(milliseconds: 110),
        child: widget.child,
      ),
    );
  }
}