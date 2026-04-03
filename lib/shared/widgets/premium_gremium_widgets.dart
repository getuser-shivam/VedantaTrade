import 'dart:ui';
import 'package:flutter/material.dart';

// Enhanced glassmorphic widgets with improved animations and effects
class PremiumGlassmorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isHoverable;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? surfaceColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool enableBlur;
  final double blurSigma;
  final bool enableShimmer;
  final bool enableGradient;

  const PremiumGlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.isHoverable = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.surfaceColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.enableBlur = true,
    this.blurSigma = 10.0,
    this.enableShimmer = false,
    this.enableGradient = true,
  }) : super(key: key);

  @override
  State<PremiumGlassmorphicCard> createState() => _PremiumGlassmorphicCardState();
}

class _PremiumGlassmorphicCardState extends State<PremiumGlassmorphicCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: widget.animationCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: widget.animationCurve,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableShimmer) {
      _shimmerController.repeat();
    }
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    if (!widget.isHoverable) return;
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _hoverController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    if (_isHovered) {
      _hoverController.forward();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    if (_isHovered) {
      _hoverController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.surfaceColor ?? const Color(0x1AFFFFFF);
    final borderColor = widget.borderColor ?? const Color(0x33FFFFFF);
    final borderWidth = widget.borderWidth ?? 1.0;
    final borderRadius = widget.borderRadius ?? 20.0;

    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _shimmerController, _pulseController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.96 : _scaleAnimation.value,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  gradient: widget.enableGradient ? (widget.gradient ?? LinearGradient(
                    colors: [
                      surfaceColor.withOpacity(_opacityAnimation.value * _pulseAnimation.value),
                      const Color(0x0DFFFFFF),
                      surfaceColor.withOpacity(_opacityAnimation.value * 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.5, 1.0],
                  )) : null,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor.withOpacity(_isHovered ? 0.8 : 0.4),
                    width: borderWidth,
                  ),
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.15),
                      blurRadius: _isHovered ? 25 : 15,
                      offset: Offset(0, _isHovered ? 10 : 5),
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Stack(
                    children: [
                      // Blur effect
                      if (widget.enableBlur)
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: widget.blurSigma * (_isHovered ? 1.5 : 1.0),
                              sigmaY: widget.blurSigma * (_isHovered ? 1.5 : 1.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    surfaceColor.withOpacity(_opacityAnimation.value * 0.3),
                                    const Color(0x0AFFFFFF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Shimmer effect
                      if (widget.enableShimmer)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(borderRadius),
                            child: AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment(_shimmerAnimation.value, 0),
                                  child: Container(
                                    width: 0.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      // Content
                      Container(
                        padding: widget.padding,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              surfaceColor.withOpacity(_opacityAnimation.value * 0.2),
                              const Color(0x05FFFFFF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Premium glassmorphic button with advanced animations
class PremiumGlassmorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isLoading;
  final Widget? loadingWidget;
  final Duration animationDuration;
  final Curve animationCurve;
  final Gradient? gradient;
  final bool enableRipple;
  final bool enableGlow;
  final double? width;
  final double? height;

  const PremiumGlassmorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.isLoading = false,
    this.loadingWidget,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.gradient,
    this.enableRipple = true,
    this.enableGlow = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<PremiumGlassmorphicButton> createState() => _PremiumGlassmorphicButtonState();
}

class _PremiumGlassmorphicButtonState extends State<PremiumGlassmorphicButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: widget.animationCurve,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() {
      _isPressed = true;
    });
    _pressController.forward();
    if (widget.enableRipple) {
      _rippleController.forward(from: 0.0);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
    widget.onPressed!();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? const Color(0x1AFFFFFF);
    final foregroundColor = widget.foregroundColor ?? Colors.white;
    final borderColor = widget.borderColor ?? const Color(0x4DFFFFFF);
    final borderRadius = widget.borderRadius ?? 16.0;
    final isEnabled = !widget.isLoading && widget.onPressed != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressController, _rippleController, _glowController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              width: widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? LinearGradient(
                  colors: [
                    backgroundColor.withOpacity(0.6),
                    backgroundColor.withOpacity(0.3),
                    backgroundColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor.withOpacity(isEnabled ? 0.8 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isEnabled ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  if (widget.enableGlow && isEnabled)
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(_glowAnimation.value),
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    // Ripple effect
                    if (widget.enableRipple && _isPressed)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.center,
                                child: Container(
                                  width: _rippleAnimation.value * 2.0,
                                  height: _rippleAnimation.value * 2.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2 * (1.0 - _rippleAnimation.value)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Button content
                    Center(
                      child: widget.isLoading
                          ? widget.loadingWidget ??
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: foregroundColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.text,
                                    style: widget.textStyle ??
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Premium glassmorphic text field with focus animations
class PremiumGlassmorphicTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableFloatingLabel;
  final bool enableBorderAnimation;

  const PremiumGlassmorphicTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.padding,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.inputFormatters,
    this.enableFloatingLabel = true,
    this.enableBorderAnimation = true,
  }) : super(key: key);

  @override
  State<PremiumGlassmorphicTextField> createState() => _PremiumGlassmorphicTextFieldState();
}

class _PremiumGlassmorphicTextFieldState extends State<PremiumGlassmorphicTextField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _labelController;
  
  late Animation<double> _borderAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _labelScaleAnimation;
  late Animation<double> _labelTranslationAnimation;
  
  FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    _focusController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _labelController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: widget.animationCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.2,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: widget.animationCurve,
    ));
    
    _labelScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: widget.animationCurve,
    ));
    
    _labelTranslationAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: widget.animationCurve,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _focusController.forward();
        if (widget.enableFloatingLabel && widget.labelText != null) {
          _labelController.forward();
        }
      } else {
        _focusController.reverse();
        if (!_hasText && widget.enableFloatingLabel && widget.labelText != null) {
          _labelController.reverse();
        }
      }
    });

    // Check initial text state
    _hasText = widget.controller?.text.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _focusController.dispose();
    _labelController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _hasText = value.isNotEmpty;
    });
    if (widget.enableFloatingLabel && widget.labelText != null && !_isFocused) {
      if (_hasText) {
        _labelController.forward();
      } else {
        _labelController.reverse();
      }
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.fillColor ?? const Color(0x1AFFFFFF);
    final borderColor = widget.borderColor ?? const Color(0x4DFFFFFF);
    final focusBorderColor = widget.focusBorderColor ?? const Color(0xFF4F46E5);
    final errorBorderColor = widget.errorBorderColor ?? const Color(0xFFEF4444);
    final borderRadius = widget.borderRadius ?? 16.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_focusController, _labelController]),
      builder: (context, child) {
        return AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                fillColor.withOpacity(_opacityAnimation.value),
                const Color(0x0DFFFFFF),
                fillColor.withOpacity(_opacityAnimation.value * 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: _isFocused
                  ? focusBorderColor
                  : borderColor.withOpacity(_isFocused ? 0.8 : 0.4),
              width: widget.enableBorderAnimation ? _borderAnimation.value : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isFocused ? 0.3 : 0.1),
                blurRadius: _isFocused ? 20 : 10,
                offset: Offset(0, _isFocused ? 8 : 4),
              ),
              if (_isFocused)
                BoxShadow(
                  color: focusBorderColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 0),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isFocused ? 3.0 : 1.5,
                sigmaY: _isFocused ? 3.0 : 1.5,
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: _onChanged,
                    onSubmitted: widget.onSubmitted,
                    onTap: widget.onTap,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    style: widget.textStyle ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                    decoration: InputDecoration(
                      hintText: widget.enableFloatingLabel && widget.labelText != null 
                          ? null 
                          : widget.hintText,
                      labelText: widget.enableFloatingLabel ? null : widget.labelText,
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(
                              widget.prefixIcon,
                              color: Colors.white.withOpacity(_isFocused ? 0.9 : 0.6),
                              size: 22,
                            )
                          : null,
                      suffixIcon: widget.suffixIcon != null
                          ? GestureDetector(
                              onTap: widget.onSuffixIconTap,
                              child: Icon(
                                widget.suffixIcon,
                                color: Colors.white.withOpacity(_isFocused ? 0.9 : 0.6),
                                size: 22,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      hintStyle: widget.hintStyle ??
                          const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                      labelStyle: widget.labelStyle ??
                          const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                      counterText: '',
                      floatingLabelBehavior: widget.enableFloatingLabel 
                          ? FloatingLabelBehavior.never 
                          : FloatingLabelBehavior.auto,
                    ),
                    inputFormatters: widget.inputFormatters,
                  ),
                  // Floating label
                  if (widget.enableFloatingLabel && widget.labelText != null)
                    Positioned(
                      left: widget.prefixIcon != null ? 60 : 20,
                      top: widget.enableFloatingLabel && (_isFocused || _hasText)
                          ? _labelTranslationAnimation.value
                          : 20,
                      child: AnimatedBuilder(
                        animation: _labelController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _labelScaleAnimation.value,
                            child: Text(
                              widget.labelText!,
                              style: widget.labelStyle?.copyWith(
                                color: Colors.white.withOpacity(_isFocused ? 0.9 : 0.6),
                                fontSize: (widget.labelStyle?.fontSize ?? 14) * _labelScaleAnimation.value,
                              ) ??
                              TextStyle(
                                color: Colors.white.withOpacity(_isFocused ? 0.9 : 0.6),
                                fontSize: 14 * _labelScaleAnimation.value,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
