import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

import '../../l10n/l10n.dart';

/// PulsingBreathingButton — M9: scale 0.9<->1.1, easeInOutSine, synced text.
class PulsingBreathingButton extends StatefulWidget {
  final Duration rhythm;
  const PulsingBreathingButton(
      {super.key, this.rhythm = const Duration(seconds: 4)});

  @override
  State<PulsingBreathingButton> createState() => _PulsingBreathingButtonState();
}

class _PulsingBreathingButtonState extends State<PulsingBreathingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.rhythm)
        ..repeat(reverse: true);
  late final Animation<double> _scale = Tween(begin: 0.9, end: 1.1)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final bool inhale =
            _c.status == AnimationStatus.forward || _c.value < 0.5;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.breathingGradient,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.breathingGradientEnd
                            .withValues(alpha: 0.4 * _scale.value),
                        blurRadius: 40 * _scale.value)
                  ],
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    color: Colors.white, size: 48),
              ),
            ),
            const SizedBox(height: 18),
            Text(
                inhale
                    ? context.l10n.breathingInhale
                    : context.l10n.breathingExhale,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        );
      },
    );
  }
}
