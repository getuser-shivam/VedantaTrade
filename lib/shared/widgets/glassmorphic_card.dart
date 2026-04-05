import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'premium_glassmorphic_theme.dart';

/// Glassmorphic Card with Animations
/// Modern glassmorphic card with hover effects, animations, and micro-interactions
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? opacity;
  final double? blur;
  final double? borderRadius;
  final bool enableHover;
  final bool enableRipple;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHapticFeedback;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final List<BoxShadow>? customShadows;
  final bool isLoading;
  final Widget? loadingChild;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.opacity,
    this.blur,
    this.borderRadius,
    this.enableHover = true,
    this.enableRipple = true,
    this.onTap,
    this.onLongPress,
    this.enableHapticFeedback = true,
    this.animationDuration,
    this.animationCurve,
    this.customShadows,
    this.isLoading = false,
    this.loadingChild,
  }) : super(key: key);

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _rippleController;
  late AnimationController _loadingController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._mediumAnimation,
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: widget.animationCurve ?? Curves.easeOutCubic,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: widget.animationCurve ?? Curves.easeOutCubic,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _rippleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.light);
      }
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.medium);
      }
      
      _rippleController.reset();
      _rippleController.forward();
      
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.heavy);
      }
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOpacity = widget.opacity ?? PremiumGlassmorphicTheme._glassOpacity;
    final effectiveBlur = widget.blur ?? PremiumGlassmorphicTheme._glassBlur;
    final effectiveRadius = widget.borderRadius ?? PremiumGlassmorphicTheme._cardBorderRadius;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(effectiveRadius),
                border: Border.all(
                  color: widget.borderColor ?? Colors.white.withOpacity(PremiumGlassmorphicTheme._glassBorderOpacity),
                  width: 1,
                ),
                boxShadow: widget.customShadows ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: effectiveBlur,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: PremiumGlassmorphicTheme._primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glassmorphic overlay
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: widget.isLoading ? 0.3 : effectiveOpacity,
                      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._shortAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(effectiveRadius),
                          border: Border.all(
                            color: widget.borderColor ?? Colors.white.withOpacity(PremiumGlassmorphicTheme._glassBorderOpacity),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Ripple effect
                  if (widget.enableRipple)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(effectiveRadius),
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: _rippleAnimation.value * 100,
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(_rippleAnimation.value * 0.3),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Loading shimmer effect
                  if (widget.isLoading)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(effectiveRadius),
                              gradient: LinearGradient(
                                begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                                end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Content
                  Positioned.fill(
                    child: Container(
                      padding: widget.padding ?? EdgeInsets.all(PremiumGlassmorphicTheme._spacingMD),
                      child: widget.isLoading 
                          ? (widget.loadingChild ?? _buildDefaultLoadingWidget())
                          : widget.child,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultLoadingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: PremiumGlassmorphicTheme._bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Interactive Glassmorphic Card with State Management
/// Enhanced card with state-aware animations and interactions
class InteractiveGlassmorphicCard extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onHoverChanged;
  final ValueChanged<bool>? onFocusChanged;
  final bool autoHover;
  final bool enableFocusEffects;
  final bool enableScaleOnHover;
  final double? scaleFactor;
  final Duration? hoverDuration;
  final Duration? focusDuration;

  const InteractiveGlassmorphicCard({
    Key? key,
    required this.child,
    this.onHoverChanged,
    this.onFocusChanged,
    this.autoHover = true,
    this.enableFocusEffects = true,
    this.enableScaleOnHover = true,
    this.scaleFactor,
    this.hoverDuration,
    this.focusDuration,
  }) : super(key: key);

  @override
  State<InteractiveGlassmorphicCard> createState() => _InteractiveGlassmorphicCardState();
}

class _InteractiveGlassmorphicCardState extends State<InteractiveGlassmorphicCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _focusController;
  late AnimationController _scaleController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _focusAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.hoverDuration ?? PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );
    
    _focusController = AnimationController(
      duration: widget.focusDuration ?? PremiumGlassmorphicTheme._mediumAnimation,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: widget.hoverDuration ?? PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor ?? 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() {
        _isHovered = isHovered;
      });

      widget.onHoverChanged?.call(isHovered);

      if (isHovered) {
        _hoverController.forward();
        if (widget.enableScaleOnHover) {
          _scaleController.forward();
        }
      } else {
        _hoverController.reverse();
        if (widget.enableScaleOnHover) {
          _scaleController.reverse();
        }
      }
    }
  }

  void _handleFocus(bool isFocused) {
    if (_isFocused != isFocused) {
      setState(() {
        _isFocused = isFocused;
      });

      widget.onFocusChanged?.call(isFocused);

      if (isFocused) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: Focus(
        onFocusChange: (hasFocus) => _handleFocus(hasFocus),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GlassmorphicCard(
                backgroundColor: Colors.white.withOpacity(
                  0.1 + (_hoverAnimation.value * 0.1) + (_focusAnimation.value * 0.1),
                ),
                opacity: 0.9 + (_hoverAnimation.value * 0.1) + (_focusAnimation.value * 0.1),
                blur: PremiumGlassmorphicTheme._glassBlur + (_focusAnimation.value * 5),
                child: AnimatedBuilder(
                  animation: _hoverAnimation,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _focusAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isFocused 
                                  ? PremiumGlassmorphicTheme._primaryColor.withOpacity(0.8)
                                  : Colors.white.withOpacity(PremiumGlassmorphicTheme._glassBorderOpacity),
                              width: _isFocused ? 2 : 1,
                            ),
                          ),
                          child: widget.child,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Glassmorphic Button
/// Modern button with glassmorphic styling and animations
class GlassmorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool enableHover;
  final bool enableRipple;
  final bool enableScale;
  final Duration? animationDuration;
  final bool enableHapticFeedback;
  final ButtonSize size;
  final ButtonVariant variant;

  const GlassmorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.enableHover = true,
    this.enableRipple = true,
    this.enableScale = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
  }) : super(key: key);

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );
    
    _pressController = AnimationController(
      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._shortAnimation,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: widget.animationDuration ?? PremiumGlassmorphicTheme._mediumAnimation,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.light);
      }
    } else {
      _hoverController.reverse();
    }
  }

  void _handlePress(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });

    if (isPressed) {
      _pressController.forward();
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.medium);
      }
    } else {
      _pressController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _rippleController.reset();
      _rippleController.forward();
      
      if (widget.enableHapticFeedback) {
        PremiumGlassmorphicTheme.triggerHapticFeedback(HapticFeedbackType.success);
      }
      
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = widget.borderRadius ?? PremiumGlassmorphicTheme._buttonBorderRadius;
    final buttonHeight = _getButtonHeight();
    final buttonPadding = _getButtonPadding();

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => _handlePress(true),
        onTapUp: (_) => _handlePress(false),
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _pressAnimation,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: widget.width,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? _getButtonColor(),
                        borderRadius: BorderRadius.circular(effectiveRadius),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            _isHovered ? 0.3 : 0.2,
                          ),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: PremiumGlassmorphicTheme._glassBlur,
                            offset: const Offset(0, 4),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: (widget.backgroundColor ?? _getButtonColor()).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Glassmorphic overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(effectiveRadius),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Ripple effect
                          if (widget.enableRipple)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(effectiveRadius),
                                  gradient: RadialGradient(
                                    center: Alignment.center,
                                    radius: _rippleAnimation.value * 50,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(_rippleAnimation.value * 0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          // Content
                          Positioned.fill(
                            child: Container(
                              padding: buttonPadding,
                              child: DefaultTextStyle.merge(
                                style: PremiumGlassmorphicTheme._bodyMedium.copyWith(
                                  color: widget.foregroundColor ?? Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: widget.child,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return PremiumGlassmorphicTheme._primaryColor;
      case ButtonVariant.secondary:
        return PremiumGlassmorphicTheme._secondaryColor;
      case ButtonVariant.success:
        return PremiumGlassmorphicTheme._successColor;
      case ButtonVariant.warning:
        return PremiumGlassmorphicTheme._warningColor;
      case ButtonVariant.error:
        return PremiumGlassmorphicTheme._errorColor;
    }
  }

  double _getButtonHeight() {
    if (widget.height != null) return widget.height!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _getButtonPadding() {
    if (widget.padding != null) return widget.padding!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
}

/// Button Size Enum
enum ButtonSize {
  small,
  medium,
  large,
}

/// Button Variant Enum
enum ButtonVariant {
  primary,
  secondary,
  success,
  warning,
  error,
}
