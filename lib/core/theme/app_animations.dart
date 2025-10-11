import 'package:flutter/material.dart';

/// Application animation constants
class AppAnimations {
  // Duration
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);
  
  // Curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  
  // Page Transition Durations
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration modalTransition = Duration(milliseconds: 400);
  
  // Animation Delays
  static const Duration delayShort = Duration(milliseconds: 100);
  static const Duration delayMedium = Duration(milliseconds: 200);
  static const Duration delayLong = Duration(milliseconds: 300);
  
  // Stagger Delays (for list animations)
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration staggerDelayShort = Duration(milliseconds: 30);
  
  // Common Tweens
  static Tween<double> opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  static Tween<double> scaleTween = Tween<double>(begin: 0.8, end: 1.0);
  static Tween<Offset> slideTween = Tween<Offset>(
    begin: const Offset(0.3, 0),
    end: Offset.zero,
  );
  
  // Button Animation
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
  static const double buttonPressScale = 0.95;
  
  // Shimmer Animation
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  
  // Pull to Refresh
  static const Duration refreshDuration = Duration(milliseconds: 800);
  
  // FAB Animation
  static const Duration fabAnimationDuration = Duration(milliseconds: 300);
  
  // Badge Pulse
  static const Duration badgePulseDuration = Duration(milliseconds: 1000);
  
  // Ripple Effect
  static const Duration rippleDuration = Duration(milliseconds: 300);
}

/// Page route transitions
class AppPageTransitions {
  // Slide from right
  static Route slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppAnimations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppAnimations.curveSmooth),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  // Slide from bottom
  static Route slideFromBottom(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppAnimations.modalTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: AppAnimations.curveSmooth),
        ));
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
  
  // Fade transition
  static Route fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppAnimations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
  
  // Scale transition
  static Route scale(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppAnimations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.curveSmooth,
          ),
        );
        
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.curveSmooth,
          ),
        );
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  // Slide and fade
  static Route slideAndFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppAnimations.pageTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.3, 0.0);
        const end = Offset.zero;
        final slideTween = Tween(begin: begin, end: end);
        final slideAnimation = animation.drive(slideTween.chain(
          CurveTween(curve: AppAnimations.curveSmooth),
        ));
        
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimations.curveSmooth,
          ),
        );
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
