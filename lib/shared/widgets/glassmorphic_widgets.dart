import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:lottie/lottie.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool withAnimation;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: AnimatedContainer(
        duration: withAnimation ? const Duration(milliseconds: 300) : Duration.zero,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.glassBg,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppTheme.glassBorderLight,
            width: borderWidth ?? 1,
          ),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: AppTheme.glassShadow,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: AppTheme.glassGradient,
        ),
        child: child,
      ),
    );
  }
}

class GlassmorphicButton extends StatefulWidget {
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
  final bool withAnimation;

  const GlassmorphicButton({
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
    this.withAnimation = true,
  }) : super(key: key);

  @override
  _GlassmorphicButtonState createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.withAnimation && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.withAnimation && !widget.isLoading) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.withAnimation) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.withAnimation ? _scaleAnimation.value : 1.0,
            child: AnimatedOpacity(
              duration: widget.withAnimation ? const Duration(milliseconds: 200) : Duration.zero,
              opacity: widget.withAnimation ? _opacityAnimation.value : 1.0,
              child: Container(
                width: widget.width,
                height: widget.height ?? 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.backgroundColor ?? AppTheme.primary,
                      (widget.backgroundColor ?? AppTheme.primary).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.borderColor ?? AppTheme.glassBorderLight,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppTheme.primary).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
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
                              Icon(widget.icon, color: widget.textColor ?? Colors.white, size: 18),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: widget.textColor ?? Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GlassmorphicTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool withAnimation;

  const GlassmorphicTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  _GlassmorphicTextFieldState createState() => _GlassmorphicTextFieldState();
}

class _GlassmorphicTextFieldState extends State<GlassmorphicTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (widget.withAnimation) {
      if (hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.glassGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? AppTheme.primary : AppTheme.glassBorderLight,
              width: widget.withAnimation ? _borderAnimation.value : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.glassShadow,
                      blurRadius: 4,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: Colors.white38)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      onPressed: widget.onSuffixIconPressed,
                      icon: Icon(widget.suffixIcon, color: Colors.white38),
                    )
                  : null,
              labelStyle: TextStyle(
                color: _isFocused ? AppTheme.primary : Colors.white38,
              ),
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onTap: () => _onFocusChange(true),
            onEditingComplete: () => _onFocusChange(false),
          ),
        );
      },
    );
  }
}

class LottieAnimationWidget extends StatefulWidget {
  final String animationPath;
  final double? width;
  final double? height;
  final bool repeat;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const LottieAnimationWidget({
    Key? key,
    required this.animationPath,
    this.width,
    this.height,
    this.repeat = true,
    this.autoPlay = true,
    this.onComplete,
  }) : super(key: key);

  @override
  _LottieAnimationWidgetState createState() => _LottieAnimationWidgetState();
}

class _LottieAnimationWidgetState extends State<LottieAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.animationPath,
      width: widget.width,
      height: widget.height,
      controller: _lottieController,
      repeat: widget.repeat,
      autoPlay: widget.autoPlay,
      onLoaded: (composition) {
        _lottieController.duration = composition.duration;
        if (widget.autoPlay) {
          _lottieController.forward();
        }
      },
      onComplete: widget.onComplete != null
          ? () {
              if (widget.onComplete != null) {
                widget.onComplete!();
              }
              if (!widget.repeat) {
                _lottieController.stop();
              }
            }
          : null,
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final double? size;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    Key? key,
    this.size = 100,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LottieAnimationWidget(
      animationPath: 'assets/animations/success.json',
      width: size,
      height: size,
      repeat: false,
      onComplete: onComplete,
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  final double? size;

  const LoadingAnimation({
    Key? key,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LottieAnimationWidget(
      animationPath: 'assets/animations/loading.json',
      width: size,
      height: size,
      repeat: true,
    );
  }
}

class ErrorAnimation extends StatelessWidget {
  final double? size;
  final VoidCallback? onComplete;

  const ErrorAnimation({
    Key? key,
    this.size = 100,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LottieAnimationWidget(
      animationPath: 'assets/animations/error.json',
      width: size,
      height: size,
      repeat: false,
      onComplete: onComplete,
    );
  }
}

class CelebrationAnimation extends StatelessWidget {
  final double? size;
  final VoidCallback? onComplete;

  const CelebrationAnimation({
    Key? key,
    this.size = 200,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LottieAnimationWidget(
      animationPath: 'assets/animations/celebration.json',
      width: size,
      height: size,
      repeat: false,
      onComplete: onComplete,
    );
  }
}

class GlassmorphicStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool withAnimation;

  const GlassmorphicStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      withAnimation: withAnimation,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              if (onTap != null)
                Icon(Icons.arrow_forward_rounded, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassmorphicListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool withAnimation;

  const GlassmorphicListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.iconColor,
    this.onTap,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      withAnimation: withAnimation,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              color: iconColor ?? AppTheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              color: Colors.white38,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class GlassmorphicChip extends StatefulWidget {
  final String label;
  final bool selected;
  final Color? selectedColor;
  final VoidCallback? onTap;
  final bool withAnimation;

  const GlassmorphicChip({
    Key? key,
    required this.label,
    this.selected = false,
    this.selectedColor,
    this.onTap,
    this.withAnimation = true,
  }) : super(key: key);

  @override
  _GlassmorphicChipState createState() => _GlassmorphicChipState();
}

class _GlassmorphicChipState extends State<GlassmorphicChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.withAnimation) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.withAnimation) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.withAnimation) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.withAnimation ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: widget.withAnimation ? const Duration(milliseconds: 200) : Duration.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: widget.selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.selectedColor ?? AppTheme.primary,
                          (widget.selectedColor ?? AppTheme.primary).withOpacity(0.8),
                        ],
                      )
                    : AppTheme.glassGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.selected
                      ? (widget.selectedColor ?? AppTheme.primary)
                      : AppTheme.glassBorderLight,
                  width: 1,
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
