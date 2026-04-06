  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool enableScale;
  final bool enableBlur;
  final Duration? animationDuration;

  const _GlassDialog({
    Key? key,
    required this.child,
    this.title,
    this.actions,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.enableScale = true,
    this.enableBlur = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16.0),
          border: Border.all(
            color: (widget.borderColor ?? Colors.white).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.title != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Text(
                  widget.title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
            if (widget.actions != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool enableHover;
  final bool enableSeparators;
  final double? separatorHeight;

  const _GlassList({
    Key? key,
