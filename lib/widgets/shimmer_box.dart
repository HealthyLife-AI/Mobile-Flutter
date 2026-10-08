import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A rounded box with a soft light sweep animating across it — the base
/// unit every loading skeleton in the app is built from, so a "loading"
/// moment always reads the same regardless of which screen is loading.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({super.key, this.width, required this.height, this.borderRadius = const BorderRadius.all(Radius.circular(8))});

  const ShimmerBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(1 - 3 * t, 0),
                  end: Alignment(2.2 - 3 * t, 0),
                  colors: const [AppColors.chipInactiveBg, Color(0xFFEDEBFA), AppColors.chipInactiveBg],
                  stops: const [0.25, 0.5, 0.75],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
