import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';

/// Enhanced Animations System for VedantaTrade
/// Provides comprehensive micro-interactions and animations for seamless UX
class EnhancedAnimations {
  // Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = EnhancedTheme.durationNormal,
    Curve curve = EnhancedTheme.curveEaseInOut,
    Duration? delay,
  }) {
    return _FadeIn(
      child: child,
      duration: duration,
      curve: curve,
      delay: delay,
    );
  }

  // Slide In Animation
  static Widget slideIn({
    required Widget child,
    SlideDirection direction = SlideDirection.up,
    Duration duration = EnhancedTheme.durationNormal,
    Curve curve = EnhancedTheme.curveEaseOut,
    Duration? delay,
    double offset = 100.0,
  }) {
    return _SlideIn(
      child: child,
      direction: direction,
      duration: duration,
      curve: curve,
      delay: delay,
      offset: offset,
    );
  }

  // Scale In Animation
  static Widget scaleIn({
    required Widget child,
    Duration duration = EnhancedTheme.durationNormal,
    Curve curve = EnhancedTheme.curveElasticOut,
    Duration? delay,
    double beginScale = 0.0,
    double endScale = 1.0,
  }) {
    return _ScaleIn(
      child: child,
      duration: duration,
      curve: curve,
      delay: delay,
      beginScale: beginScale,
      endScale: endScale,
    );
  }

  // Rotation Animation
  static Widget rotation({
    required Widget child,
    Duration duration = EnhancedTheme.durationNormal,
    Curve curve = EnhancedTheme.curveEaseInOut,
    Duration? delay,
    double turns = 1.0,
  }) {
    return _Rotation(
      child: child,
      duration: duration,
      curve: curve,
      delay: delay,
      turns: turns,
    );
  }

  // Stagger Animation for Lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration duration = EnhancedTheme.durationNormal,
    Duration staggerDelay = const Duration(milliseconds: 100),
    SlideDirection direction = SlideDirection.up,
  }) {
    return _StaggeredList(
      children: children,
      duration: duration,
      staggerDelay: staggerDelay,
      direction: direction,
    );
  }

  // Pulse Animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    bool infinite = true,
  }) {
    return _Pulse(
      child: child,
      duration: duration,
      infinite: infinite,
    );
  }

  // Shimmer Loading Effect
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _Shimmer(
      child: child,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
    );
  }

  // Bounce Animation
  static Widget bounce({
    required Widget child,
    Duration duration = EnhancedTheme.durationNormal,
    int bounceCount = 3,
  }) {
    return _Bounce(
      child: child,
      duration: duration,
      bounceCount: bounceCount,
    );
  }

  // Parallax Effect
  static Widget parallax({
    required Widget child,
    required ScrollController scrollController,
    double offset = 0.5,
  }) {
    return _Parallax(
      child: child,
      scrollController: scrollController,
      offset: offset,
    );
  }

  // Morph Animation
  static Widget morph({
    required Widget child,
    required Widget morphChild,
    Duration duration = EnhancedTheme.durationNormal,
    Curve curve = EnhancedTheme.curveEaseInOut,
  }) {
    return _Morph(
      child: child,
      morphChild: morphChild,
      duration: duration,
      curve: curve,
    );
  }
}

// Slide Direction Enum
enum SlideDirection {
  up,
  down,
  left,
  right,
}

// Fade In Animation Implementation
class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? delay;

  const _FadeIn({
    required this.child,
    required this.duration,
    required this.curve,
    this.delay,
  });

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

// Slide In Animation Implementation
class _SlideIn extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Curve curve;
  final Duration? delay;
  final double offset;

  const _SlideIn({
    required this.child,
    required this.direction,
    required this.duration,
    required this.curve,
    this.delay,
    required this.offset,
  });

  @override
  State<_SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<_SlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final begin = _getBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.up:
        return Offset(0.0, widget.offset);
      case SlideDirection.down:
        return Offset(0.0, -widget.offset);
      case SlideDirection.left:
        return Offset(widget.offset, 0.0);
      case SlideDirection.right:
        return Offset(-widget.offset, 0.0);
    }
  }
}

// Scale In Animation Implementation
class _ScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? delay;
  final double beginScale;
  final double endScale;

  const _ScaleIn({
    required this.child,
    required this.duration,
    required this.curve,
    this.delay,
    required this.beginScale,
    required this.endScale,
  });

  @override
  State<_ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<_ScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

// Rotation Animation Implementation
class _Rotation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? delay;
  final double turns;

  const _Rotation({
    required this.child,
    required this.duration,
    required this.curve,
    this.delay,
    required this.turns,
  });

  @override
  State<_Rotation> createState() => _RotationState();
}

class _RotationState extends State<_Rotation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.turns,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationAnimation,
      child: widget.child,
    );
  }
}

// Staggered List Animation Implementation
class _StaggeredList extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final SlideDirection direction;

  const _StaggeredList({
    required this.children,
    required this.duration,
    required this.staggerDelay,
    required this.direction,
  });

  @override
  State<_StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<_StaggeredList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = Duration(milliseconds: widget.staggerDelay.inMilliseconds * index);

        return EnhancedAnimations.slideIn(
          child: child,
          direction: widget.direction,
          duration: widget.duration,
          delay: delay,
        );
      }).toList(),
    );
  }
}

// Pulse Animation Implementation
class _Pulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool infinite;

  const _Pulse({
    required this.child,
    required this.duration,
    required this.infinite,
  });

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.infinite) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

// Shimmer Loading Effect Implementation
class _Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const _Shimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    required this.duration,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shader: LinearGradient(
            colors: [
              widget.baseColor ?? Colors.grey[300]!,
              widget.highlightColor ?? Colors.grey[100]!,
              widget.baseColor ?? Colors.grey[300]!,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
            end: Alignment(1.0 + _shimmerAnimation.value, 0),
          ).createShader(const Rect.fromLTWH(0, 0, 200, 100)),
          child: widget.child,
        );
      },
    );
  }
}

// Bounce Animation Implementation
class _Bounce extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int bounceCount;

  const _Bounce({
    required this.child,
    required this.duration,
    required this.bounceCount,
  });

  @override
  State<_Bounce> createState() => _BounceState();
}

class _BounceState extends State<_Bounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ widget.bounceCount),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -_bounceAnimation.value * 10),
      child: widget.child,
    );
  }
}

// Parallax Effect Implementation
class _Parallax extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;
  final double offset;

  const _Parallax({
    required this.child,
    required this.scrollController,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final scrollOffset = scrollController.hasClients ? scrollController.offset : 0.0;
        final parallaxOffset = scrollOffset * offset;

        return Transform.translate(
          offset: Offset(0, parallaxOffset),
          child: child,
        );
      },
      child: child,
    );
  }
}

// Morph Animation Implementation
class _Morph extends StatefulWidget {
  final Widget child;
  final Widget morphChild;
  final Duration duration;
  final Curve curve;

  const _Morph({
    required this.child,
    required this.morphChild,
    required this.duration,
    required this.curve,
  });

  @override
  State<_Morph> createState() => _MorphState();
}

class _MorphState extends State<_Morph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _morphAnimation;
  bool _isMorphed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  void _toggleMorph() {
    if (_isMorphed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isMorphed = !_isMorphed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleMorph,
      child: AnimatedBuilder(
        animation: _morphAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Opacity(
                opacity: 1.0 - _morphAnimation.value,
                child: widget.child,
              ),
              Opacity(
                opacity: _morphAnimation.value,
                child: widget.morphChild,
              ),
            ],
          );
        },
      ),
    );
  }
}

// Interactive Animation Controller
class InteractiveAnimationController {
  static final Map<String, AnimationController> _controllers = {};

  static AnimationController getController(
    String key, {
    required TickerProvider vsync,
    required Duration duration,
  }) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = AnimationController(
        duration: duration,
        vsync: vsync,
      );
    }
    return _controllers[key]!;
  }

  static void play(String key) {
    _controllers[key]?.forward();
  }

  static void reverse(String key) {
    _controllers[key]?.reverse();
  }

  static void repeat(String key) {
    _controllers[key]?.repeat();
  }

  static void stop(String key) {
    _controllers[key]?.stop();
  }

  static void dispose(String key) {
    _controllers[key]?.dispose();
    _controllers.remove(key);
  }

  static void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

// Gesture-based Animations
class GestureAnimations {
  // Tap Animation
  static Widget tapAnimation({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = EnhancedTheme.durationFast,
  }) {
    return _TapAnimation(
      child: child,
      onTap: onTap,
      scale: scale,
      duration: duration,
    );
  }

  // Hover Animation
  static Widget hoverAnimation({
    required Widget child,
    double scale = 1.05,
    Duration duration = EnhancedTheme.durationFast,
  }) {
    return _HoverAnimation(
      child: child,
      scale: scale,
      duration: duration,
    );
  }

  // Swipe Animation
  static Widget swipeAnimation({
    required Widget child,
    required VoidCallback onSwipeLeft,
    required VoidCallback onSwipeRight,
    double threshold = 100.0,
  }) {
    return _SwipeAnimation(
      child: child,
      onSwipeLeft: onSwipeLeft,
      onSwipeRight: onSwipeRight,
      threshold: threshold,
    );
  }
}

// Tap Animation Implementation
class _TapAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  const _TapAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
  });

  @override
  State<_TapAnimation> createState() => _TapAnimationState();
}

class _TapAnimationState extends State<_TapAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// Hover Animation Implementation
class _HoverAnimation extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;

  const _HoverAnimation({
    required this.child,
    required this.scale,
    required this.duration,
  });

  @override
  State<_HoverAnimation> createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<_HoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

// Swipe Animation Implementation
class _SwipeAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final double threshold;

  const _SwipeAnimation({
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.threshold,
  });

  @override
  State<_SwipeAnimation> createState() => _SwipeAnimationState();
}

class _SwipeAnimationState extends State<_SwipeAnimation> {
  double _dragStartX = 0.0;
  double _dragEndX = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _dragStartX = details.globalPosition.dx;
      },
      onPanEnd: (details) {
        _dragEndX = details.globalPosition.dx;
        final difference = _dragEndX - _dragStartX;

        if (difference.abs() > widget.threshold) {
          if (difference > 0) {
            widget.onSwipeRight();
          } else {
            widget.onSwipeLeft();
          }
        }
      },
      child: widget.child,
    );
  }
}
