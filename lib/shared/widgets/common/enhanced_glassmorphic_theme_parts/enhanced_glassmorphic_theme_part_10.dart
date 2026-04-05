        color: effectiveBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: effectiveBorderColor,
            width: 1.0,
          ),
        ),
        boxShadow: widget.enableGlow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        children: widget.children,
      ),
    );

    if (widget.enableBlur) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurAmount ?? 5.0,
            sigmaY: widget.blurAmount ?? 5.0,
          ),
          child: navBar,
        ),
      );
    }

    return navBar;
  }
}

/// Placeholder implementations for other components
class _GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool enableDragHandle;
  final bool enableBlur;
  final Duration? animationDuration;

  const _GlassBottomSheet({
    Key? key,
    required this.child,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.enableDragHandle = true,
    this.enableBlur = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.borderRadius ?? 20.0),
        ),
        border: Border.all(
          color: (widget.borderColor ?? Colors.white).withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.enableDragHandle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _GlassDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;