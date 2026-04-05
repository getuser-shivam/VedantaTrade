  State<_GlassmorphicContainer> createState() => _GlassmorphicContainerState();
}

class _GlassmorphicContainerState extends State<_GlassmorphicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity ?? EnhancedGlassmorphicTheme.defaultOpacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isAnimated) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Colors.white;
    final effectiveBorderColor = widget.borderColor ?? Colors.white;
    final effectiveBorderRadius = widget.borderRadius ?? 12.0;
    final effectiveBlur = widget.blur ?? EnhancedGlassmorphicTheme.defaultBlur;
    final effectiveBorderWidth = widget.borderWidth ?? 1.0;
    
    Widget container = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isAnimated ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: widget.isAnimated ? _opacityAnimation.value : (widget.opacity ?? EnhancedGlassmorphicTheme.defaultOpacity),
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.enableGradient ? null : effectiveBackgroundColor.withOpacity(0.1),
                gradient: widget.enableGradient ? widget.gradient : null,
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                border: Border.all(
                  color: effectiveBorderColor.withOpacity(0.3),
                  width: effectiveBorderWidth,
                ),
                boxShadow: widget.boxShadow ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: effectiveBlur,
                    offset: const Offset(0, 4),
                    spreadRadius: 0.0,
                  ),
                  if (widget.enableGlow)
                    BoxShadow(
                      color: effectiveBackgroundColor.withOpacity(0.3),
                      blurRadius: effectiveBlur * 2,
                      offset: const Offset(0, 0),
                      spreadRadius: 2.0,
                    ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return Material(
        type: MaterialType.button,
        color: Colors.transparent,
        child: InkWell(