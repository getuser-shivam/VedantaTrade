            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.value
                      ? (widget.activeColor ?? Colors.blue)
                      : (widget.inactiveColor ?? Colors.grey),
                  width: 2.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      activeColor: widget.activeColor ?? Colors.blue,
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
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedRadioGroup<T> extends StatefulWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final List<RadioItem<T>> items;
  final String? title;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedRadioGroup({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.title,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedRadioGroup<T>> createState() => _AnimatedRadioGroupState<T>();
}

class _AnimatedRadioGroupState<T> extends State<_AnimatedRadioGroup<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();