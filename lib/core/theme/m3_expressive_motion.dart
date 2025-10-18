import 'package:flutter/material.dart';

/// Material 3 Expressive Motion Durations
class M3Durations {
  // Duration scales for different motion types
  static const Duration emphasizedDecelerate = Duration(milliseconds: 400);
  static const Duration emphasizedAccelerate = Duration(milliseconds: 200);
  static const Duration emphasized = Duration(milliseconds: 500);
  
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration short1 = Duration(milliseconds: 50);
  static const Duration short2 = Duration(milliseconds: 100);
  static const Duration short3 = Duration(milliseconds: 150);
  static const Duration short4 = Duration(milliseconds: 200);
  
  static const Duration medium1 = Duration(milliseconds: 250);
  static const Duration medium2 = Duration(milliseconds: 300);
  static const Duration medium3 = Duration(milliseconds: 350);
  static const Duration medium4 = Duration(milliseconds: 400);
  
  static const Duration long1 = Duration(milliseconds: 450);
  static const Duration long2 = Duration(milliseconds: 500);
  static const Duration long3 = Duration(milliseconds: 550);
  static const Duration long4 = Duration(milliseconds: 600);
  
  static const Duration extraLong1 = Duration(milliseconds: 700);
  static const Duration extraLong2 = Duration(milliseconds: 800);
  static const Duration extraLong3 = Duration(milliseconds: 900);
  static const Duration extraLong4 = Duration(milliseconds: 1000);
}

/// Material 3 Expressive Easing Curves
class M3Easings {
  // Emphasized easing (for expressive motion)
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve emphasized = Cubic(0.2, 0.0, 0, 1.0);
  
  // Standard easing
  static const Curve standard = Cubic(0.2, 0.0, 0, 1.0);
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1, 1);
  static const Curve standardDecelerate = Cubic(0, 0.0, 0, 1);
  
  // Legacy easing (for compatibility)
  static const Curve legacy = Cubic(0.4, 0.0, 0.2, 1);
  static const Curve legacyAccelerate = Cubic(0.4, 0.0, 1, 1);
  static const Curve legacyDecelerate = Cubic(0.0, 0.0, 0.2, 1);
  
  // Expressive spring curves
  static const Curve expressiveSpring = Curves.easeOutBack;
  static const Curve expressiveBounce = Curves.elasticOut;
}

/// Material 3 Expressive Animations
class M3Animations {
  // Container Transform
  static Widget containerTransform({
    required Widget child,
    required Duration duration,
    Curve curve = M3Easings.emphasized,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
  
  // Shared Axis Transition
  static Widget sharedAxisTransition({
    required Widget child,
    required Animation<double> animation,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    late final Animation<Offset> offsetAnimation;
    
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: M3Easings.emphasized,
        ));
        break;
      case SharedAxisTransitionType.vertical:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: M3Easings.emphasized,
        ));
        break;
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: M3Easings.emphasized,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
    
    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
  
  // Fade Through Transition
  static Widget fadeThroughTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: M3Easings.emphasized,
      ),
      child: child,
    );
  }
  
  // Fade Transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: M3Easings.standard,
      ),
      child: child,
    );
  }
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Expressive Motion Extensions
extension ExpressiveMotionExtension on Widget {
  Widget animateOnPageLoad({
    Duration? delay,
    Duration? duration,
    Curve? curve,
    Offset? slideFrom,
    double? fadeFrom,
    double? scaleFrom,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? M3Durations.emphasized,
      curve: curve ?? M3Easings.emphasized,
      builder: (context, value, child) {
        return Transform.translate(
          offset: slideFrom != null
              ? Offset.lerp(slideFrom, Offset.zero, value)!
              : Offset.zero,
          child: Opacity(
            opacity: fadeFrom != null
                ? Tween<double>(begin: fadeFrom, end: 1.0).transform(value)
                : value,
            child: Transform.scale(
              scale: scaleFrom != null
                  ? Tween<double>(begin: scaleFrom, end: 1.0).transform(value)
                  : 1.0,
              child: child,
            ),
          ),
        );
      },
      child: this,
    );
  }
}

/// Hero Animation Controller
class HeroAnimationController {
  static const Duration duration = M3Durations.emphasized;
  
  static Widget createHeroAnimation({
    required String tag,
    required Widget child,
    bool enabled = true,
  }) {
    if (!enabled) return child;
    
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// Stagger Animation Helper
class StaggerAnimation {
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) {
    return List.generate(
      children.length,
      (index) {
        final itemDelay = (delay ?? M3Durations.short2) * index;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: (duration ?? M3Durations.medium2) + itemDelay,
          curve: curve ?? M3Easings.emphasizedDecelerate,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: children[index],
        );
      },
    );
  }
}
