    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.isSearchable = false,
    this.searchFilter,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>>();
}

class _AnimatedDropdownState<T> extends State<_AnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
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
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            border: Border.all(
              color: widget.borderColor ?? Colors.grey,
              width: 1.0,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            onChanged: widget.onChanged,
            items: widget.items,
            hint: widget.hintText != null
                ? Text(widget.hintText!)
                : null,
            icon: widget.prefixIcon != null
                ? Transform.rotate(
                    angle: _iconAnimation.value,
                    child: Icon(widget.prefixIcon),
                  )
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedDatePicker extends StatefulWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? labelText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
