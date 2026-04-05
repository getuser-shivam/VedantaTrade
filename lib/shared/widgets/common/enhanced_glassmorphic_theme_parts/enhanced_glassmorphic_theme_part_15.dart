        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Slider(
        value: widget.value,
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
        activeColor: widget.activeColor,
        inactiveColor: widget.inactiveColor,
      ),
    );
  }
}

class _GlassProgressIndicator extends StatelessWidget {
  final double value;
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final double? borderRadius;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableGlow;

  const _GlassProgressIndicator({
    Key? key,
    required this.value,
    this.label,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.label!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: widget.value,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.progressColor ?? Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final Widget label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final double? borderRadius;
  final bool enableAnimation;
  final Duration? animationDuration;

  const _GlassChip({
    Key? key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.onDeleted,
    this.backgroundColor,
    this.selectedColor,