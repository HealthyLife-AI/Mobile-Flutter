import 'package:flutter/material.dart';

/// Three distinct entrance patterns used across the app so every screen feels
/// premium while still keeping one shared design language. The route cycles
/// through them automatically, so each push feels thoughtful without needing a
/// custom transition per screen.
enum ScreenEntranceVariant {
  softLift,
  depthScale,
  driftIn,
}

/// The one page-transition the whole app uses: a soft fade, a gentle
/// upward slide and a barely-there scale-in, replacing Flutter's default
/// platform slide so every push/pop feels like the same, considered
/// product instead of a stock Android/iOS transition. Drop-in replacement
/// for `MaterialPageRoute(builder: ...)` — same constructor shape.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  static int _variantCounter = 0;

  final WidgetBuilder builder;

  static ScreenEntranceVariant _nextVariant() {
    final variant = ScreenEntranceVariant.values[_variantCounter % ScreenEntranceVariant.values.length];
    _variantCounter += 1;
    return variant;
  }

  AppPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    super.opaque,
    ScreenEntranceVariant? incomingVariant,
  }) : super(
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, animation, secondaryAnimation) => AnimatedScreen(
            animation: animation,
            variant: incomingVariant ?? _nextVariant(),
            child: builder(context),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}

class AnimatedScreen extends StatelessWidget {
  const AnimatedScreen({
    super.key,
    required this.child,
    required this.animation,
    this.variant = ScreenEntranceVariant.softLift,
  });

  final Widget child;
  final Animation<double> animation;
  final ScreenEntranceVariant variant;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final (Offset beginOffset, double beginScale, double beginRotate) = switch (variant) {
      ScreenEntranceVariant.softLift => (
          const Offset(0, 0.08),
          0.96,
          0.0,
        ),
      ScreenEntranceVariant.depthScale => (
          const Offset(0.08, 0),
          0.92,
          0.02,
        ),
      ScreenEntranceVariant.driftIn => (
          const Offset(-0.09, 0.03),
          1.0,
          -0.015,
        ),
    };

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
        child: Transform.scale(
          scale: Tween<double>(begin: beginScale, end: 1).chain(CurveTween(curve: Curves.easeOutCubic)).evaluate(animation),
          child: Transform.rotate(
            angle: Tween<double>(begin: beginRotate, end: 0).chain(CurveTween(curve: Curves.easeOutCubic)).evaluate(animation),
            child: child,
          ),
        ),
      ),
    );
  }
}
