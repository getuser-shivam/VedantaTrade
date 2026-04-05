  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? width;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.width,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.value ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.value
                  ? (widget.activeColor ?? Colors.blue).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.value
                    ? (widget.activeColor ?? Colors.blue)
                    : (widget.inactiveColor ?? Colors.grey),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                Switch(
                  value: widget.value,
                  onChanged: (value) {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onChanged(value);
                  },
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: TextStyle(