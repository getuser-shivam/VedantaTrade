import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Enhanced page transitions for seamless navigation
class PageTransitions {
  /// Slide transition from right (for forward navigation)
  static Widget slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide transition from left (for back navigation)
  static Widget slideFromLeft(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Fade transition with scale
  static Widget fadeScale(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Hero-like shared element transition
  static Widget sharedAxis(Widget child, Animation<double> animation, Axis axis) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: axis == Axis.horizontal ? const Offset(1, 0) : const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
}

/// Custom page route with transitions
class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final TransitionType transitionType;

  AnimatedPageRoute({
    required this.child,
    this.transitionType = TransitionType.slideRight,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case TransitionType.slideRight:
          return PageTransitions.slideFromRight(child, animation);
        case TransitionType.slideLeft:
          return PageTransitions.slideFromLeft(child, animation);
        case TransitionType.fadeScale:
          return PageTransitions.fadeScale(child, animation);
        case TransitionType.sharedAxis:
          return PageTransitions.sharedAxis(child, animation, Axis.horizontal);
        default:
          return FadeTransition(opacity: animation, child: child);
      }
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

enum TransitionType { slideRight, slideLeft, fadeScale, sharedAxis, fade }

/// Smooth scroll behavior for lists
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}
