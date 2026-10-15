import 'package:flutter/material.dart';

/// M15 — Long-list scroll behavior: top items fade out progressively as
/// new ones fade in from below. Implemented as a ShaderMask edge-fade
/// driven by the viewport itself rather than a per-item rebuild/listener,
/// which is cheaper than tracking each item's RenderBox on every scroll tick.
class ScrollEdgeFade extends StatelessWidget {
  final Widget child;
  final double fadeHeight;
  const ScrollEdgeFade({super.key, required this.child, this.fadeHeight = 44});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        final double f = (fadeHeight / rect.height).clamp(0.0, 0.4);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent
          ],
          stops: [0.0, f, 1 - f, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
