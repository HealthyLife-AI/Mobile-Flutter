import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// AutoRedirectCountdown — M13: a REAL countdown (not static text), with a
/// slowly, continuously rotating refresh icon for the countdown's duration.
/// Calls [onDone] once when it reaches zero.
class AutoRedirectCountdown extends StatefulWidget {
  final int seconds;
  final VoidCallback onDone;
  const AutoRedirectCountdown({super.key, this.seconds = 2, required this.onDone});

  @override
  State<AutoRedirectCountdown> createState() => _AutoRedirectCountdownState();
}

class _AutoRedirectCountdownState extends State<AutoRedirectCountdown> with SingleTickerProviderStateMixin {
  late int _remaining = widget.seconds;
  Timer? _timer;
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: Duration(milliseconds: widget.seconds * 1000))..repeat();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(turns: _spin, child: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Text('جاري نقلك تلقائياً خلال $_remaining ${_remaining == 1 ? "ثانية" : "ثوانٍ"}…', style: AppTextStyles.caption),
      ],
    );
  }
}
