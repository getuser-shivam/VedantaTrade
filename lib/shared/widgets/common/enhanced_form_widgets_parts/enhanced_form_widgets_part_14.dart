                            color: widget.value
                                ? (widget.activeColor ?? Colors.blue)
                                : (widget.inactiveColor ?? Colors.grey),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: widget.value
                                ? (widget.activeColor ?? Colors.blue).withOpacity(0.8)
                                : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
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
          scale: widget.value ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () {
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              widget.onChanged(!widget.value);