                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedMultiSelect<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final Function(List<T>) onChanged;
  final String Function(T)? itemLabel;
  final Widget Function(T)? itemWidget;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final double? borderRadius;
  final bool enableSearch;
  final Duration? animationDuration;

  const _AnimatedMultiSelect({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.itemLabel,
    this.itemWidget,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.borderRadius,
    this.enableSearch = false,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedMultiSelect<T>> createState() => _AnimatedMultiSelectState<T>();
}

class _AnimatedMultiSelectState<T> extends State<_AnimatedMultiSelect<T>>
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
      end: 0.95,
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
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                // Multi-select implementation would go here
                // This is a placeholder for the actual multi-select logic
              ],
            ),
          ),
        );
      },
    );
  }
}
