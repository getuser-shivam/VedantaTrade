/// Placeholder implementations for remaining widgets
class _AnimatedRating extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final bool enableAnimation;
  final Duration? animationDuration;

  const _AnimatedRating({
    Key? key,
    required this.value,
    required this.onChanged,
    this.starCount = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = false,
    this.enableAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedRating> createState() => _AnimatedRatingState();
}

class _AnimatedRatingState extends State<_AnimatedRating>
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
      end: 1.2,
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
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.starCount, (index) {
              final starValue = index + 1.0;
              final isActive = widget.value >= starValue;
              final isHalfActive = widget.allowHalfRating && 
                  widget.value >= starValue - 0.5 && 
                  widget.value < starValue;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onChanged(starValue.toDouble());
                },
                child: Icon(
                  isHalfActive ? Icons.star_half : Icons.star,
                  color: isActive
                      ? (widget.activeColor ?? Colors.amber)
                      : (widget.inactiveColor ?? Colors.grey),
                  size: widget.size,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
