import 'package:flutter/material.dart';

class OnboardingReveal extends StatelessWidget {
  final Widget child;
  final double dy;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const OnboardingReveal({
    super.key,
    required this.child,
    this.dy = 0.12,
    this.duration = const Duration(milliseconds: 650),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + delay,
      curve: Curves.linear,
      builder: (context, value, child) {
        final delayed = (delay == Duration.zero
            ? value
            : ((value - delay.inMilliseconds / (duration + delay).inMilliseconds) /
                    (duration.inMilliseconds / (duration + delay).inMilliseconds))
                .clamp(0.0, 1.0))
            .toDouble();
        final eased = curve.transform(delayed);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, dy * (1 - eased) * 100),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
