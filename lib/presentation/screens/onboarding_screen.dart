import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/gradient_cta_button.dart';
import 'login_screen.dart';
import '../../core/navigation/app_page_route.dart';

import '../widgets/directional_icon.dart';
import '../../l10n/l10n.dart';

class _BadgeItem {
  final IconData icon;
  final String label;
  const _BadgeItem(this.icon, this.label);
}

class _OnboardPage {
  final String image;
  final Alignment imageAlignment;
  final String title;
  final String description;
  final List<_BadgeItem> badge;
  const _OnboardPage({
    required this.image,
    required this.title,
    required this.description,
    required this.badge,
    this.imageAlignment = Alignment.center,
  });
}

/// Clips the hero image into a "dome": straight sides, half-ellipse bottom.
class _DomeClipper extends CustomClipper<Path> {
  const _DomeClipper();

  @override
  Path getClip(Size size) {
    final curve = size.height * 0.16;
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - curve)
      ..arcToPoint(
        Offset(0, size.height - curve),
        radius: Radius.elliptical(size.width / 2, curve),
        clockwise: true,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _DomeClipper old) => false;
}

/// 4.1 Onboarding — pre-signup carousel shown before a patient activates
/// their clinic invite. Large full-bleed hero image with a dome bottom,
/// parallax on swipe, a floating info badge that overlaps the dome edge,
/// animated page dots and a pill CTA ("التالي" → "ابدأ الآن").
/// "تخطي" and the last CTA both continue to [LoginScreen].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static List<_OnboardPage> _pages(AppLocalizations l10n) => <_OnboardPage>[
        _OnboardPage(
          image: 'assets/images/onboarding_track.jpg',
          imageAlignment: const Alignment(0, 0.2),
          title: l10n.onboardingTrackTitle,
          description: l10n.onboardingTrackDescription,
          badge: [
            _BadgeItem(
                Icons.auto_awesome_rounded, l10n.onboardingBadgeSmartScan),
            _BadgeItem(
                Icons.bar_chart_rounded, l10n.onboardingBadgeDetailedAccuracy),
          ],
        ),
        _OnboardPage(
          image: 'assets/images/onboarding_plan.jpg',
          title: l10n.onboardingPlanTitle,
          description: l10n.onboardingPlanDescription,
          badge: [
            _BadgeItem(Icons.verified_rounded, l10n.onboardingBadgeApproved),
          ],
        ),
      ];

  bool get _isLast => _index == _pages(context.l10n).length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context)
        .pushReplacement(AppPageRoute(builder: (_) => const LoginScreen()));
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final pages = _pages(context.l10n);
    // Big hero, but always leave room for text + dots + button.
    final heroHeight = (media.size.height * 0.56)
        .clamp(220.0, math.max(220.0, media.size.height - 340))
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _PageContent(
                    page: pages[i],
                    index: i,
                    controller: _controller,
                    heroHeight: heroHeight,
                  ),
                ),
              ),
              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(24, 16, 24, 20 + media.padding.bottom),
                child: _PillButton(
                  label: _isLast
                      ? context.l10n.onboardingStartNow
                      : context.l10n.commonNext,
                  showArrow: _isLast,
                  onPressed: _next,
                ),
              ),
            ],
          ),
          // Skip — top-left, floating over the image
          PositionedDirectional(
              top: media.padding.top + 10,
              end: 20,
              child: Material(
                color: Colors.white.withValues(alpha: 0.6),
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _finish,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    child: Text(
                      context.l10n.onboardingSkip,
                      style: AppTextStyles.secondary.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  final int index;
  final PageController controller;
  final double heroHeight;
  const _PageContent({
    required this.page,
    required this.index,
    required this.controller,
    required this.heroHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final width = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double current = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          current = controller.page ?? current;
        }
        final delta = (current - index).clamp(-1.0, 1.0);
        final dist = delta.abs();
        final dir = isRtl ? -1.0 : 1.0;

        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: const _DomeClipper(),
                  child: SizedBox(
                    height: heroHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax image
                        Transform.translate(
                          offset: Offset(dir * delta * width * 0.07, 0),
                          child: Transform.scale(
                            scale: 1.15,
                            child: Image.asset(page.image,
                                fit: BoxFit.cover,
                                alignment: page.imageAlignment),
                          ),
                        ),
                        // Soft top shade so the status bar / skip stay readable
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [Color(0x40000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Floating badge overlapping the dome edge
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -20,
                  child: Center(
                    child: Opacity(
                      opacity: 1 - dist,
                      child: _InfoBadge(items: page.badge),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Opacity(
                opacity: 1 - dist,
                child: Transform.translate(
                  offset: Offset(0, 24 * dist),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 34, 28, 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Centered when there is room; scrolls on short screens
                        // or at large text scales instead of overflowing.
                        final maxHeight = constraints.maxHeight;
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: maxHeight.isFinite
                                ? BoxConstraints(minHeight: maxHeight)
                                : const BoxConstraints(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 23,
                                    height: 1.3,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.secondary.copyWith(
                                    fontSize: 13.5,
                                    height: 1.65,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final List<_BadgeItem> items;
  const _InfoBadge({required this.items});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 1,
            height: 14,
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ));
      }
      children.add(Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(items[i].icon, size: 13, color: AppColors.primary),
      ));
      children.add(const SizedBox(width: 7));
      children.add(Flexible(
          child: Text(items[i].label,
              style: style, maxLines: 1, overflow: TextOverflow.ellipsis)));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173B36).withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final bool showArrow;
  final VoidCallback onPressed;
  const _PillButton(
      {required this.label, required this.onPressed, this.showArrow = false});

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.86)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ButtonShine(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
                padding: const EdgeInsets.symmetric(horizontal: 34),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: FittedBox(
                    key: ValueKey(widget.label),
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showArrow) ...[
                          Icon(
                              directionalIcon(context,
                                  rtl: Icons.arrow_back_rounded,
                                  ltr: Icons.arrow_forward_rounded),
                              color: Colors.white,
                              size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
