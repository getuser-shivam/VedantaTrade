  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(_floatController);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = widget.borderRadius ?? 12.0;
    final effectiveElevation = widget.elevation ?? 8.0;
    
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            margin: widget.margin,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: 1.0,
              ),
              boxShadow: widget.enableShadow ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20.0,
                  offset: const Offset(0, 10),
                  spreadRadius: 0.0,
                ),
                if (widget.enableReflection)
                  BoxShadow(
                    color: effectiveBackgroundColor.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, -5),
                    spreadRadius: 0.0,
                  ),
              ] : null,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Glass Navigation Bar Implementation
class _GlassNavigationBar extends StatelessWidget {
  final List<Widget> children;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableBlur;
  final bool enableGlow;
  final double? blurAmount;

  const _GlassNavigationBar({
    Key? key,
    required this.children,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.enableBlur = true,
    this.enableGlow = false,
    this.blurAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderColor = widget.borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveHeight = widget.height ?? kToolbarHeight;
    
    Widget navBar = Container(
      height: effectiveHeight,
      decoration: BoxDecoration(
