
  const _GlassFloatingActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.enablePulse = false,
    this.enableGlow = false,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_GlassFloatingActionButton> createState() => _GlassFloatingActionButtonState();
}

class _GlassFloatingActionButtonState extends State<_GlassFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: widget.animationDuration ?? const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    final effectiveForegroundColor = widget.foregroundColor ?? Colors.white;
    final effectiveSize = widget.size ?? 56.0;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePulse ? _pulseAnimation.value : 1.0,
          child: Container(
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(effectiveSize / 2),
              border: Border.all(
                color: effectiveBackgroundColor.withOpacity(0.5),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
                if (widget.enableGlow)
                  BoxShadow(
                    color: effectiveBackgroundColor.withOpacity(0.3),
                    blurRadius: 20.0,
                    offset: const Offset(0, 0),
                    spreadRadius: 2.0,
                  ),
              ],
            ),
            child: Material(
              type: MaterialType.button,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(effectiveSize / 2),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPressed();
                },
                borderRadius: BorderRadius.circular(effectiveSize / 2),
                child: Center(
                  child: widget.child,
                ),
              ),
            ),
