import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';

class AnimatedSlide extends StatelessWidget {
  final Widget child;
  final Offset offset;
  final Duration duration;
  final Curve curve;

  const AnimatedSlide({
    Key? key,
    required this.child,
    required this.offset,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: offset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

class MicroInteractionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final AnimationType animationType;

  const MicroInteractionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.animationType = AnimationType.scale,
  }) : super(key: key);

  @override
  _MicroInteractionButtonState createState() => _MicroInteractionButtonState();
}

enum AnimationType {
  scale,
  slide,
  fade,
  bounce,
  ripple,
}

class _MicroInteractionButtonState extends State<MicroInteractionButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    _rippleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    _rippleController.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
    _rippleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final textColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _rippleController]),
        builder: (context, child) {
          Widget buttonContent = _buildButtonContent(textColor);

          switch (widget.animationType) {
            case AnimationType.scale:
              buttonContent = Transform.scale(
                scale: _scaleAnimation.value,
                child: buttonContent,
              );
              break;
            case AnimationType.fade:
              buttonContent = Opacity(
                opacity: _fadeAnimation.value,
                child: buttonContent,
              );
              break;
            case AnimationType.slide:
              buttonContent = Transform.translate(
                offset: _slideAnimation.value,
                child: buttonContent,
              );
              break;
            case AnimationType.bounce:
              buttonContent = Transform.scale(
                scale: 1.0 + (1.0 - _scaleAnimation.value) * 0.1,
                child: buttonContent,
              );
              break;
            case AnimationType.ripple:
              buttonContent = Stack(
                children: [
                  buttonContent,
                  if (_rippleController.status == AnimationStatus.forward ||
                      _rippleController.status == AnimationStatus.completed)
                    Positioned.fill(
                      child: _buildRippleEffect(buttonColor),
                    ),
                ],
              );
              break;
          }

          return buttonContent;
        },
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    return GlassmorphicCard(
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      backgroundColor: widget.backgroundColor,
      borderColor: widget.borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: widget.isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRippleEffect(Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: _rippleController.value * 2,
                  colors: [
                    color.withOpacity(0.3 * (1 - _rippleController.value)),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final Curve animationCurve;
  final double hoverScale;
  final double pressScale;
  final Color? hoverColor;
  final Color? pressColor;
  final BorderRadius? borderRadius;
  final bool enableHoverEffect;
  final bool enablePressEffect;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.hoverScale = 1.02,
    this.pressScale = 0.98,
    this.hoverColor,
    this.pressColor,
    this.borderRadius,
    this.enableHoverEffect = true,
    this.enablePressEffect = true,
  }) : super(key: key);

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _colorAnimation = ColorTween(
      begin: null,
      end: null,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    double targetScale = 1.0;
    Color? targetColor;

    if (_isPressed && widget.enablePressEffect) {
      targetScale = widget.pressScale;
      targetColor = widget.pressColor;
    } else if (_isHovered && widget.enableHoverEffect) {
      targetScale = widget.hoverScale;
      targetColor = widget.hoverColor;
    }

    _scaleAnimation = Tween<double>(
      begin: _scaleAnimation.value,
      end: targetScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    if (targetColor != null) {
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value,
        end: targetColor,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
    }

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _updateAnimation();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _updateAnimation();
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
            _updateAnimation();
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
            _updateAnimation();
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
            _updateAnimation();
          });
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GlassmorphicCard(
                borderRadius: widget.borderRadius,
                backgroundColor: _colorAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SmoothPageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;

  const SmoothPageTransition({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.direction = SlideDirection.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.left:
        beginOffset = const Offset(-1.0, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(1.0, 0);
        break;
      case SlideDirection.up:
        beginOffset = const Offset(0, -1.0);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, 1.0);
        break;
    }

    return AnimatedSlide(
      offset: beginOffset,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
  down,
}

class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final Curve animationCurve;
  final SlideDirection slideDirection;

  const StaggeredAnimationList({
    Key? key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
    this.slideDirection = SlideDirection.up,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: animationDuration,
          curve: animationCurve,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return AnimatedOpacity(
              opacity: value,
              duration: animationDuration,
              curve: animationCurve,
              child: AnimatedSlide(
                offset: Offset(
                  0,
                  slideDirection == SlideDirection.up 
                      ? (1 - value) * 0.3
                      : slideDirection == SlideDirection.down
                          ? -(1 - value) * 0.3
                          : 0,
                ),
                duration: animationDuration,
                curve: animationCurve,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}
