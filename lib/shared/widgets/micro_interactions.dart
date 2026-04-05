import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/modern_design_system.dart';
import '../constants/app_constants.dart';

class MicroInteractions {
  // Haptic Feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void notificationSuccess() {
    HapticFeedback.notificationSuccess();
  }

  static void notificationWarning() {
    HapticFeedback.notificationWarning();
  }

  static void notificationError() {
    HapticFeedback.notificationError();
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;
  final ButtonStyle? style;
  final bool isLoading;
  final bool showRipple;
  final bool showScale;
  final bool showShimmer;
  final Duration? animationDuration;
  final double? width;
  final double? height;

  const AnimatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.child,
    this.style,
    this.isLoading = false,
    this.showRipple = true,
    this.showScale = true,
    this.showShimmer = false,
    this.animationDuration,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovered ? _scaleAnimation.value : 1.0,
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return _buildButton(_shimmerAnimation.value);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(double shimmerValue) {
    final buttonStyle = widget.style ?? ModernButtonStyles.primaryButton;
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: widget.showShimmer && shimmerValue > 0
            ? LinearGradient(
                colors: [
                  buttonStyle.backgroundColor?.resolve({}) ?? ModernDesignSystem.primaryColor,
                  Colors.white.withOpacity(0.3),
                  buttonStyle.backgroundColor?.resolve({}) ?? ModernDesignSystem.primaryColor,
                ],
                stops: [0.0, shimmerValue, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isHovered ? ModernDesignSystem.mediumShadow : ModernDesignSystem.lightShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : () {
            MicroInteractions.mediumImpact();
            widget.onPressed?.call();
          },
          borderRadius: BorderRadius.circular(16),
          splashFactory: widget.showRipple ? InkRipple.splashFactory : NoSplash.splashFactory,
          highlightColor: Colors.black.withOpacity(0.05),
          child: Center(
            child: widget.isLoading
                ? _buildLoadingIndicator()
                : widget.child ??
                    Text(
                      widget.text,
                      style: buttonStyle.textStyle?.resolve({}) ?? ModernTextStyles.buttonMedium,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showHoverEffect;
  final bool showScaleEffect;
  final bool showShimmerEffect;
  final VoidCallback? onTap;
  final Duration? animationDuration;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.showHoverEffect = true,
    this.showScaleEffect = true,
    this.showShimmerEffect = false,
    this.onTap,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.showShimmerEffect) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered && widget.showScaleEffect ? _scaleAnimation.value : 1.0,
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return _buildCard(_shimmerAnimation.value);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(double shimmerValue) {
    final cardDecoration = ModernCardStyles.defaultCard;
    final borderRadius = widget.borderRadius ?? ModernDesignSystem.radius16;
    
    return AnimatedContainer(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? cardDecoration.color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _isHovered && widget.showHoverEffect
            ? ModernDesignSystem.mediumShadow
            : cardDecoration.boxShadow,
        border: _isHovered && widget.showHoverEffect
            ? Border.all(
                color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                width: 2,
              )
            : cardDecoration.border,
        gradient: widget.showShimmerEffect && shimmerValue > 0
            ? LinearGradient(
                colors: [
                  cardDecoration.color ?? Colors.white,
                  Colors.white.withOpacity(0.7),
                  cardDecoration.color ?? Colors.white,
                ],
                stops: [0.0, shimmerValue, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        child: child,
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }
}

class AnimatedInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool showAnimatedLabel;
  final bool showFloatingLabel;
  final bool showInputBorder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final Duration? animationDuration;

  const AnimatedInput({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.showAnimatedLabel = true,
    this.showFloatingLabel = false,
    this.showInputBorder = true,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<AnimatedInput> createState() => _AnimatedInputState();
}

class _AnimatedInputState extends State<AnimatedInput>
    with TickerProviderStateMixin {
  late AnimationController _labelController;
  late AnimationController _borderController;
  late Animation<double> _labelAnimation;
  late Animation<double> _borderAnimation;
  late TextEditingController _textController;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _textController.text.isNotEmpty;

    _labelController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );
    _borderController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: Curves.easeInOut,
    ));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    ));

    _textController.addListener(() {
      final hasText = _textController.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _borderController.dispose();
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.showAnimatedLabel) ...[
          AnimatedBuilder(
            animation: _labelAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _hasFocus ? -20 : 0),
                child: Transform.scale(
                  scale: _hasFocus ? _labelAnimation.value : 1.0,
                  child: child,
                ),
              );
            },
            child: Text(
              widget.label!,
              style: ModernTextStyles.overline.copyWith(
                color: _hasFocus
                    ? ModernDesignSystem.primaryColor
                    : ModernDesignSystem.grey600,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: _handleFocusChange,
          child: TextFormField(
            controller: _textController,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            decoration: _buildInputDecoration(),
            style: ModernTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration() {
    final baseDecoration = ModernInputStyles.defaultInput;
    
    return baseDecoration.copyWith(
      labelText: widget.showFloatingLabel ? widget.label : null,
      hintText: widget.hint,
      prefixIcon: widget.prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: widget.prefixIcon,
            )
          : null,
      suffixIcon: _buildSuffixIcon(),
      border: widget.showInputBorder ? baseDecoration.border : InputBorder.none,
      enabledBorder: widget.showInputBorder ? baseDecoration.enabledBorder : InputBorder.none,
      focusedBorder: widget.showInputBorder ? baseDecoration.focusedBorder : InputBorder.none,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null || widget.showClearButton) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showClearButton && _hasText) ...[
            GestureDetector(
              onTap: () {
                _textController.clear();
                MicroInteractions.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: ModernDesignSystem.grey500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.suffixIcon != null) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: widget.suffixIcon,
            ),
          ],
        ],
      );
    }
    return null;
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _hasFocus = hasFocus;
    });
    
    if (hasFocus) {
      _labelController.forward();
      _borderController.forward();
    } else {
      _labelController.reverse();
      _borderController.reverse();
    }
  }
}

class AnimatedList extends StatefulWidget {
  final List<Widget> children;
  final ScrollDirection? scrollDirection;
  final bool shrinkWrap;
  final EdgeInsets? padding;
  final double? itemExtent;
  final Widget? separator;
  final bool showSlideInAnimation;
  final Duration? animationDuration;
  final double? animationOffset;

  const AnimatedList({
    Key? key,
    required this.children,
    this.scrollDirection,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.separator,
    this.showSlideInAnimation = true,
    this.animationDuration,
    this.animationOffset,
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
        duration: widget.animationDuration ?? ModernDesignSystem.normalAnimation,
        vsync: this,
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: widget.animationOffset ?? 50.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: ModernDesignSystem.smoothCurve,
      ));
    }).toList();

    // Start animations with stagger
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
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
    if (widget.showSlideInAnimation) {
      return ListView.separated(
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemCount: widget.children.length,
        separatorBuilder: widget.separator != null
            ? (context, index) => widget.separator!
            : null,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: child,
              );
            },
            child: widget.children[index],
          );
        },
      );
    } else {
      return ListView.separated(
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemCount: widget.children.length,
        separatorBuilder: widget.separator != null
            ? (context, index) => widget.separator!
            : null,
        itemBuilder: (context, index) => widget.children[index],
      );
    }
  }
}

class AnimatedChip extends StatefulWidget {
  final String label;
  final Widget? avatar;
  final bool selected;
  final VoidCallback? onTap;
  final bool showDeleteIcon;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Duration? animationDuration;

  const AnimatedChip({
    Key? key,
    required this.label,
    this.avatar,
    this.selected = false,
    this.onTap,
    this.showDeleteIcon = false,
    this.onDelete,
    this.backgroundColor,
    this.selectedColor,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<AnimatedChip>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );
    _colorController = AnimationController(
      duration: widget.animationDuration ?? ModernDesignSystem.fastAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? ModernDesignSystem.grey100,
      end: widget.selectedColor ?? ModernDesignSystem.primaryColor,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    if (widget.selected) {
      _colorController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _colorController.forward();
      } else {
        _colorController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: () {
          MicroInteractions.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? _scaleAnimation.value : 1.0,
              child: AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return _buildChip(_colorAnimation.value);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChip(Color? backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radius20),
        border: Border.all(
          color: backgroundColor ?? ModernDesignSystem.grey300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.avatar != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: widget.avatar,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              widget.label,
              style: ModernTextStyles.caption.copyWith(
                color: backgroundColor != null
                    ? ModernDesignSystem.getContrastColor(backgroundColor!)
                    : ModernDesignSystem.grey700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.showDeleteIcon) ...[
            GestureDetector(
              onTap: () {
                MicroInteractions.lightImpact();
                widget.onDelete?.call();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: backgroundColor != null
                      ? ModernDesignSystem.getContrastColor(backgroundColor!)
                      : ModernDesignSystem.grey700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }
}

class LoadingShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;
  final double? width;
  final double? height;

  const LoadingShimmer({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(_shimmerController);

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  widget.baseColor ?? ModernDesignSystem.grey100,
                  widget.highlightColor ?? ModernDesignSystem.grey200,
                  widget.baseColor ?? ModernDesignSystem.grey100,
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
