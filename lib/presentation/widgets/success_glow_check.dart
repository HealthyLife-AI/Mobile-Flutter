import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// SuccessGlowCheck — v2 replacement for the old SuccessConfettiScreen's
/// confetti burst. Corrected M6: "There is no confetti in the actual
/// design." A gradient circle (primary → a lighter shade) with a white ✓
/// enters via Scale+Fade (300ms, easeOutBack), surrounded by a soft glow
/// that pulses once slowly then settles. Calm clinical success, not a
/// loud celebration.
class SuccessGlowCheck extends StatefulWidget {
  final double size;
  const SuccessGlowCheck({super.key, this.size = 110});

  @override
  State<SuccessGlowCheck> createState() => _SuccessGlowCheckState();
}

class _SuccessGlowCheckState extends State<SuccessGlowCheck>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300))
    ..forward();
  late final AnimationController _glowController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale:
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: _scaleController,
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            // Pulses once (0 -> 1 -> settle at a low resting glow), never loops.
            final t = _glowController.value;
            final pulse =
                t < 1 ? (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0) : 0.3;
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.successGlowGradient,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: 0.25 + 0.25 * pulse),
                      blurRadius: 24 + 16 * pulse,
                      spreadRadius: 2 * pulse),
                ],
              ),
              child: child,
            );
          },
          child: Icon(Icons.check_rounded,
              color: Colors.white, size: widget.size * 0.5),
        ),
      ),
    );
  }
}
