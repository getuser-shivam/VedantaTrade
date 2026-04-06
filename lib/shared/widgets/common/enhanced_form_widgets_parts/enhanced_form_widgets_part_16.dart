    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ...widget.items.map((item) => RadioListTile<T>(
                  title: Text(item.title),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  secondary: item.icon != null ? Icon(item.icon) : null,
                  value: item.value,
                  groupValue: widget.value,
                  onChanged: (value) {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onChanged(value);
                  },
                  activeColor: widget.activeColor ?? Colors.blue,
                  inactiveColor: widget.inactiveColor ?? Colors.grey,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final double? borderRadius;
  final bool showPercentage;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enablePulse;

  const _AnimatedProgressIndicator({
    Key? key,
    required this.value,
    this.label,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
    this.showPercentage = true,
    this.enableAnimation = true,
    this.animationDuration,
    this.enablePulse = false,
  }) : super(key: key);
