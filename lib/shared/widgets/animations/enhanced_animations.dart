import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';
import '../accessibility/enhanced_accessibility.dart';

/// Enhanced Animation System for VedantaTrade
/// Provides smooth, performant animations and transitions

class EnhancedAnimations {
  // Animation Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);
  
  // Reduced Motion Check
  static bool get reducedMotion => EnhancedAccessibility.reducedMotion;
  
  // Animation Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve slowMiddleFast = Curves.slowMiddleFast;
  
  // Page Transitions
  static Widget slideTransition(
    Widget child,
    Animation<double> animation, {
    SlideDirection direction = SlideDirection.leftToRight,
    bool fade = true,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: fade ? FadeTransition(
        opacity: animation,
        child: child,
      ) : child,
    );
  }
  
  static Widget fadeTransition(
    Widget child,
    Animation<double> animation, {
    Curve curve = Curves.easeInOut,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: curve,
      ),
      child: child,
    );
  }
  
  static Widget scaleTransition(
    Widget child,
    Animation<double> animation, {
    double beginScale = 0.8,
    Curve curve = Curves.elasticOut,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: child,
    );
  }
  
  static Widget rotationTransition(
    Widget child,
    Animation<double> animation, {
    double turns = 0.5,
    bool fade = true,
  }) {
    return RotationTransition(
      turns: Tween<double>(
        begin: turns,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: fade ? FadeTransition(
        opacity: animation,
        child: child,
      ) : child,
    );
  }
}

// Animated Components
class AnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final bool animateOnFirstBuild;

  const AnimatedContainer({
    Key? key,
    required this.child,
    this.duration = EnhancedAnimations.medium,
    this.curve = EnhancedAnimations.easeInOut,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.animateOnFirstBuild = false,
  }) : super(key: key);

  @override
  State<AnimatedContainer> createState() => _AnimatedContainerState();
}

class _AnimatedContainerState extends State<AnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (!widget.animateOnFirstBuild) {
      _controller.value = 1.0;
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve) {
      _animation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      );
    }
    
    if (_isFirstBuild) {
      _isFirstBuild = false;
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: widget.padding,
          margin: widget.margin,
          color: widget.color,
          decoration: widget.decoration,
          foregroundDecoration: widget.foregroundDecoration,
          width: widget.width,
          height: widget.height,
          constraints: widget.constraints,
          alignment: widget.alignment,
          child: widget.child,
        );
      },
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? padding;
  final bool animateScale;
  final bool animateColor;
  final bool animateElevation;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.duration = EnhancedAnimations.fast,
    this.curve = EnhancedAnimations.easeInOut,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
    this.padding,
    this.animateScale = true,
    this.animateColor = true,
    this.animateElevation = true,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) * 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animateScale ? _scaleAnimation.value : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTapCancel: () => _controller.reverse(),
              borderRadius: widget.shape?.borderRadius ?? BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: widget.duration,
                curve: widget.curve,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? theme.colorScheme.primary,
                  shape: widget.shape ?? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  boxShadow: widget.animateElevation ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: _elevationAnimation.value,
                    ),
                  ] : null,
                ),
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool animateOnHover;
  final bool animateOnTap;
  final VoidCallback? onTap;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.duration = EnhancedAnimations.medium,
    this.curve = EnhancedAnimations.easeInOut,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.animateOnHover = true,
    this.animateOnTap = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (widget.animateOnHover) {
      setState(() {
        _isHovered = isHovered;
      });
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleTap() {
    if (widget.animateOnTap) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return AnimatedContainer(
              duration: widget.duration,
              curve: widget.curve,
              margin: widget.margin,
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: _elevationAnimation.value,
                  ),
                ],
              ),
              transform: Matrix4.identity()..scale(_scaleAnimation.value),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

class AnimatedList extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final SlideDirection slideDirection;
  final bool fade;
  final double slideDistance;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AnimatedList({
    Key? key,
    required this.children,
    this.duration = EnhancedAnimations.medium,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = EnhancedAnimations.easeInOut,
    this.slideDirection = SlideDirection.leftToRight,
    this.fade = true,
    this.slideDistance = 50.0,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  State<AnimatedList> createState() => _AnimatedListState();
}

class _AnimatedListState extends State<AnimatedList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: widget.curve,
      );
    }).toList();

    // Start animations with stagger
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisSize: widget.mainAxisSize,
            children: _buildAnimatedChildren(),
          )
        : Row(
            mainAxisAlignment: widget.mainAxisAlignment,
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisSize: widget.mainAxisSize,
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return List.generate(widget.children.length, (index) {
      return AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          Widget animatedChild = widget.children[index];
          
          if (widget.fade) {
            animatedChild = FadeTransition(
              opacity: _animations[index],
              child: animatedChild,
            );
          }
          
          if (widget.slideDistance > 0) {
            Offset beginOffset;
            switch (widget.slideDirection) {
              case SlideDirection.leftToRight:
                beginOffset = Offset(-widget.slideDistance, 0);
                break;
              case SlideDirection.rightToLeft:
                beginOffset = Offset(widget.slideDistance, 0);
                break;
              case SlideDirection.topToBottom:
                beginOffset = Offset(0, -widget.slideDistance);
                break;
              case SlideDirection.bottomToTop:
                beginOffset = Offset(0, widget.slideDistance);
                break;
            }
            
            animatedChild = SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(_animations[index]),
              child: animatedChild,
            );
          }
          
          return animatedChild;
        },
      );
    });
  }
}

class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final bool animateOnFirstBuild;

  const AnimatedCounter({
    Key? key,
    required this.value,
    this.duration = EnhancedAnimations.slow,
    this.curve = EnhancedAnimations.easeInOut,
    this.style,
    this.prefix,
    this.suffix,
    this.animateOnFirstBuild = true,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _animation.addListener(() {
      setState(() {
        _currentValue = _animation.value;
      });
    });

    if (widget.animateOnFirstBuild) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
      _currentValue = widget.value;
    }
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.reset();
      _animation = IntTween(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
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
    final theme = Theme.of(context);
    
    return Text(
      '${widget.prefix ?? ''}$_currentValue${widget.suffix ?? ''}',
      style: widget.style ?? theme.textTheme.headlineSmall,
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final Color? valueColor;
  final double? height;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;

  const AnimatedProgressIndicator({
    Key? key,
    required this.value,
    this.duration = EnhancedAnimations.medium,
    this.curve = EnhancedAnimations.easeInOut,
    this.backgroundColor,
    this.valueColor,
    this.height,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.reset();
      _animation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
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
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: widget.height ?? 8,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? theme.colorScheme.surfaceVariant,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.valueColor ?? theme.colorScheme.primary,
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                if (widget.showPercentage) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

// Page Route Builders
class EnhancedPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection slideDirection;
  final bool fade;
  final bool scale;

  EnhancedPageRoute({
    required this.child,
    this.duration = EnhancedAnimations.medium,
    this.curve = EnhancedAnimations.easeInOut,
    this.slideDirection = SlideDirection.leftToRight,
    this.fade = true,
    this.scale = false,
  });

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Offset begin;
    switch (slideDirection) {
      case SlideDirection.leftToRight:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.rightToLeft:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.topToBottom:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.bottomToTop:
        begin = const Offset(0.0, 1.0);
        break;
    }

    Widget animatedChild = child;
    
    if (fade) {
      animatedChild = FadeTransition(
        opacity: animation,
        child: animatedChild,
      );
    }
    
    if (scale) {
      animatedChild = ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        )),
        child: animatedChild,
      );
    }
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve,
      )),
      child: animatedChild,
    );
  }
}

// Enums
enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

// Extension Methods
extension WidgetAnimation on Widget {
  Widget animate({
    Duration duration = EnhancedAnimations.medium,
    Curve curve = EnhancedAnimations.easeInOut,
    SlideDirection slideDirection = SlideDirection.leftToRight,
    bool fade = true,
    bool scale = false,
  }) {
    return EnhancedPageRoute(
      child: this,
      duration: duration,
      curve: curve,
      slideDirection: slideDirection,
      fade: fade,
      scale: scale,
    );
  }
}
