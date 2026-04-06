          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap!();
          },
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Animated Glass Button Implementation
class _AnimatedGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final Duration? animationDuration;
  final bool enableRipple;
  final bool enableScale;
  final bool enableGlow;

  const _AnimatedGlassButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.animationDuration,
    this.enableRipple = true,
    this.enableScale = true,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  State<_AnimatedGlassButton> createState() => _AnimatedGlassButtonState();
}

class _AnimatedGlassButtonState extends State<_AnimatedGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    final effectiveForegroundColor = widget.foregroundColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = widget.borderRadius ?? 12.0;
    
    return Material(
      type: MaterialType.button,
      color: Colors.transparent,
