    this.textColor,
    this.borderRadius,
    this.enableAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isSelected
            ? (widget.selectedColor ?? Colors.blue).withOpacity(0.2)
            : (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
        border: Border.all(
          color: widget.isSelected
              ? (widget.selectedColor ?? Colors.blue).withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.label,
            if (widget.onDeleted != null)
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onDeleted,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  final List<Tab> tabs;
  final TabController controller;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableGlow;

  const _GlassTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.height,
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
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs,
        indicatorColor: widget.indicatorColor,
        labelColor: widget.labelColor,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableBlur;