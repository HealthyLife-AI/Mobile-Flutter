import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_router.dart';

import '../../l10n/l10n.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minimumSplashDuration = Duration(seconds: 3);
  static const Color _teal = Color(0xFF028090);

  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final AnimationController _progressController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _brandOffset;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: _minimumSplashDuration,
    )..forward();

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.0,
        0.30,
        curve: Curves.easeOut,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.0,
          0.48,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _brandOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.28,
        0.58,
        curve: Curves.easeOut,
      ),
    );

    _brandOffset = Tween<double>(
      begin: 18,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.28,
          0.62,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.48,
        0.75,
        curve: Curves.easeOut,
      ),
    );

    _footerOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(
        0.70,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _introController.forward();

    unawaited(_boot());
  }

  /// Runs start-up (restores the session, rotates the tokens, checks consent)
  /// while the splash animation plays. Then the splash opens the screen for the
  /// resulting status. The auth listener does not navigate during launch.
  Future<void> _boot() async {
    final auth = context.read<AuthCubit>();
    await Future.wait<void>([
      auth.start(),
      Future<void>.delayed(_minimumSplashDuration),
    ]);
    if (!mounted) return;
    auth.finishLaunch();
    AppRouter.showFor(auth.state);
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─────────────────────────────────────────────
          // Background
          // ─────────────────────────────────────────────

          const _PremiumBackground(),

          // ─────────────────────────────────────────────
          // Ambient organic light
          // ─────────────────────────────────────────────

          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              return CustomPaint(
                painter: _AmbientPainter(
                  progress: _ambientController.value,
                ),
              );
            },
          ),

          // ─────────────────────────────────────────────
          // Main content
          // ─────────────────────────────────────────────

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: const _LogoMark(),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Brand
                      AnimatedBuilder(
                        animation: _introController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _brandOpacity.value,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _brandOffset.value,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.97, end: 1).animate(
                            CurvedAnimation(
                                parent: _introController,
                                curve: Curves.easeOutCubic),
                          ),
                          child: const _BrandName(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Text(
                          context.l10n.splashTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Text(
                          context.l10n.splashSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.5),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tiny divider
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: Container(
                          width: 36,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _teal.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // Bottom area
          // ─────────────────────────────────────────────

          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: SafeArea(
              top: false,
              child: FadeTransition(
                opacity: _footerOpacity,
                child: _Footer(progress: _progressController),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BACKGROUND
// ═══════════════════════════════════════════════════════════

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AMBIENT LIGHT
// ═══════════════════════════════════════════════════════════

class _AmbientPainter extends CustomPainter {
  final double progress;

  const _AmbientPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final phase = progress * math.pi * 2;
    final pathPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var index = 0; index < 5; index++) {
      final y = size.height * (0.16 + index * 0.17);
      final path = Path()
        ..moveTo(-16, y)
        ..cubicTo(
          size.width * 0.25,
          y + math.sin(phase + index) * 18,
          size.width * 0.72,
          y - math.cos(phase + index) * 22,
          size.width + 16,
          y + math.sin(phase + index * 0.7) * 14,
        );
      canvas.drawPath(path, pathPaint);
    }

    final leafPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 7; index++) {
      final travel = (progress + index / 7) % 1;
      final x = size.width * (0.08 + travel * 0.84);
      final y = size.height * (0.12 + (index % 3) * 0.37) +
          math.sin(phase + index) * 5;
      final leaf = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x + 3, y - 8, x + 10, y - 6)
        ..quadraticBezierTo(x + 9, y + 1, x, y)
        ..moveTo(x + 1, y)
        ..lineTo(x + 8, y - 5);
      canvas.drawPath(leaf, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ═══════════════════════════════════════════════════════════
// LOGO
// ═══════════════════════════════════════════════════════════

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236,
      height: 104,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.favorite_rounded,
          size: 52,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BRAND NAME
// ═══════════════════════════════════════════════════════════

class _BrandName extends StatelessWidget {
  const _BrandName();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.splashCaringEveryDay,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 23,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FOOTER
// ═══════════════════════════════════════════════════════════

class _Footer extends StatelessWidget {
  final Animation<double> progress;
  const _Footer({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Minimal loading indicator
        SizedBox(
          width: 72,
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) => LinearProgressIndicator(
                value: progress.value,
                minHeight: 3,
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        Text(
          context.l10n.splashPreparing,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.72),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
