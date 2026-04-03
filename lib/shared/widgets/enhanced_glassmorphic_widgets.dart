import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedGlassmorphicWidgets extends StatelessWidget {
  const EnhancedGlassmorphicWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Enhanced Glassmorphic Card with animations
class AnimatedGlassmorphicCard extends StatefulWidget {
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

  const AnimatedGlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.isHoverable = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.surfaceColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
  }) : super(key: key);

  @override
  State<AnimatedGlassmorphicCard> createState() => _AnimatedGlassmorphicCardState();
}

class _AnimatedGlassmorphicCardState extends State<AnimatedGlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    if (!widget.isHoverable) return;
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    HapticFeedback.lightImpact();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.surfaceColor ?? const Color(0x1FFFFFFF);
    final borderColor = widget.borderColor ?? const Color(0x33FFFFFF);
    final borderWidth = widget.borderWidth ?? 1.0;
    final borderRadius = widget.borderRadius ?? 16.0;

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
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.98 : _scaleAnimation.value,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? LinearGradient(
                    colors: [
                      surfaceColor.withOpacity(_opacityAnimation.value),
                      const Color(0x0AFFFFFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor.withOpacity(_isHovered ? 0.8 : 0.5),
                    width: borderWidth,
                  ),
                  boxShadow: widget.boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isHovered ? 2.0 : 1.0,
                      sigmaY: _isHovered ? 2.0 : 1.0,
                    ),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            surfaceColor.withOpacity(_opacityAnimation.value),
                            const Color(0x0AFFFFFF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: widget.child,
                    ),
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

// Enhanced Glassmorphic Button with ripple effect
class EnhancedGlassmorphicButton extends StatefulWidget {
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

  const EnhancedGlassmorphicButton({
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
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.gradient,
  }) : super(key: key);

  @override
  State<EnhancedGlassmorphicButton> createState() => _EnhancedGlassmorphicButtonState();
}

class _EnhancedGlassmorphicButtonState extends State<EnhancedGlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    _animationController.reverse();
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? const Color(0x1FFFFFFF);
    final foregroundColor = widget.foregroundColor ?? Colors.white;
    final borderColor = widget.borderColor ?? const Color(0x33FFFFFF);
    final borderRadius = widget.borderRadius ?? 12.0;
    final isEnabled = !widget.isLoading && widget.onPressed != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? LinearGradient(
                  colors: [
                    backgroundColor.withOpacity(0.6),
                    backgroundColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor.withOpacity(isEnabled ? 0.8 : 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isEnabled ? 0.2 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    // Shimmer effect
                    if (widget.isLoading)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment(_shimmerAnimation.value, 0),
                              child: Container(
                                width: 0.3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x00FFFFFF),
                                      Color(0x33FFFFFF),
                                      Color(0x00FFFFFF),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Button content
                    Center(
                      child: widget.isLoading
                          ? widget.loadingWidget ??
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
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
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.text,
                                    style: widget.textStyle ??
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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

// Enhanced Glassmorphic TextField with focus effects
class EnhancedGlassmorphicTextField extends StatefulWidget {
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
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final Duration animationDuration;
  final Curve animationCurve;
  final List<TextInputFormatter>? inputFormatters;

  const EnhancedGlassmorphicTextField({
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
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<EnhancedGlassmorphicTextField> createState() => _EnhancedGlassmorphicTextFieldState();
}

class _EnhancedGlassmorphicTextFieldState extends State<EnhancedGlassmorphicTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<double> _opacityAnimation;
  FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.fillColor ?? const Color(0x1FFFFFFF);
    final borderColor = widget.borderColor ?? const Color(0x33FFFFFF);
    final focusBorderColor = widget.focusBorderColor ?? const Color(0xFF4F46E5);
    final errorBorderColor = widget.errorBorderColor ?? const Color(0xFFEF4444);
    final borderRadius = widget.borderRadius ?? 12.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                fillColor.withOpacity(_opacityAnimation.value),
                const Color(0x0AFFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: _isFocused
                  ? focusBorderColor
                  : borderColor.withOpacity(_isFocused ? 0.8 : 0.5),
              width: _borderAnimation.value,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isFocused ? 0.2 : 0.1),
                blurRadius: _isFocused ? 10 : 5,
                offset: Offset(0, _isFocused ? 4 : 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isFocused ? 2.0 : 1.0,
                sigmaY: _isFocused ? 2.0 : 1.0,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                style: widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: Colors.white.withOpacity(0.7),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: widget.hintStyle ??
                      const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 16,
                      ),
                  labelStyle: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 14,
                  ),
                  counterText: '',
                ),
                inputFormatters: widget.inputFormatters,
              ),
            ),
          ),
        );
      },
    );
  }
}
