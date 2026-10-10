import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

enum CtaGradientType { primary, voice }

class ButtonShine extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ButtonShine(
      {super.key, required this.child, required this.borderRadius});

  @override
  State<ButtonShine> createState() => _ButtonShineState();
}

class _ButtonShineState extends State<ButtonShine>
    with SingleTickerProviderStateMixin {
  // Created on first use, never from dispose(): the controller's constructor
  // looks up the TickerMode ancestor, which is already deactivated by then.
  AnimationController? _controllerOrNull;

  AnimationController get _controller => _controllerOrNull ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat();

  @override
  void dispose() {
    _controllerOrNull?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        // `passthrough` keeps tight incoming constraints (a parent-sized
        // button box) but never turns an unbounded axis into an infinite
        // constraint, which `StackFit.expand` would. It also stays measurable
        // with a dry layout, unlike the `LayoutBuilder` this replaces — chip
        // labels ask for exactly that.
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final s = ((t - 0.45) / 0.35).clamp(0.0, 1.0).toDouble();
                  return Align(
                    alignment: Alignment(-1.3 + 2.6 * s, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.3,
                      heightFactor: 1,
                      child: Transform(
                        transform: Matrix4.skewX(-0.35),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(0),
                                Colors.white.withAlpha(60),
                                Colors.white.withAlpha(0),
                              ],
                            ),
                          ),
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
}

/// GradientCtaButton — pill button, selectable gradient, loading + disabled states.
/// Voice gradient is reserved for BeetAI / voice / sharing contexts only (section 2.1).
class GradientCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CtaGradientType gradient;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  const GradientCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient = CtaGradientType.primary,
    this.loading = false,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedGradientCtaButton(
      label: label,
      onPressed: onPressed,
      gradient: gradient,
      loading: loading,
      icon: icon,
      outlined: outlined,
    );
  }
}

class _AnimatedGradientCtaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final CtaGradientType gradient;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  const _AnimatedGradientCtaButton({
    required this.label,
    required this.onPressed,
    required this.gradient,
    required this.loading,
    required this.icon,
    required this.outlined,
  });

  @override
  State<_AnimatedGradientCtaButton> createState() => _AnimatedGradientCtaButtonState();
}

class _AnimatedGradientCtaButtonState extends State<_AnimatedGradientCtaButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  // The outlined variant never animates the glow, so `_loop` may never be
  // read. A `late final` field would then be constructed by the read inside
  // dispose(), and AnimationController's constructor looks up the TickerMode
  // ancestor — which is already deactivated in dispose() → "Looking up a
  // deactivated widget's ancestor is unsafe".
  AnimationController? _loopOrNull;

  AnimationController get _loop => _loopOrNull ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat();

  @override
  void dispose() {
    _loopOrNull?.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.loading;
    final LinearGradient grad = widget.gradient == CtaGradientType.primary
        ? AppColors.primaryGradient
        : AppColors.ctaVoiceGradient;

    if (widget.outlined) {
      return SizedBox(
        height: 54,
        child: GestureDetector(
          onTapDown: disabled ? null : (_) => _setPressed(true),
          onTapCancel: disabled ? null : () => _setPressed(false),
          onTapUp: disabled ? null : (_) => _setPressed(false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: OutlinedButton(
              onPressed: disabled ? null : _handleTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              child: ButtonShine(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Center(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.ctaText.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final glow = 0.5 + 0.5 * math.sin(_loop.value * 2 * math.pi);
        return Opacity(
          opacity: disabled && !widget.loading ? 0.5 : 1,
          child: GestureDetector(
            onTapDown: disabled ? null : (_) => _setPressed(true),
            onTapCancel: disabled ? null : () => _setPressed(false),
            onTapUp: disabled ? null : (_) => _setPressed(false),
            onTap: disabled ? null : _handleTap,
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: grad.colors.last.withValues(alpha: 0.28 + 0.12 * glow),
                      blurRadius: 16 + 8 * glow,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ButtonShine(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Center(
                    child: widget.loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                              ],
                              Text(widget.label, style: AppTextStyles.ctaText),
                            ],
                          ),
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
