  final bool enableGlow;
  final bool enableScrollAnimation;

  const _GlassAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.enableBlur = true,
    this.enableGlow = false,
    this.enableScrollAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
        boxShadow: widget.enableGlow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: AppBar(
        title: widget.title != null
            ? Text(
                widget.title!,
                style: TextStyle(
                  color: widget.foregroundColor ?? Colors.white,
                ),
              )
            : null,
        actions: widget.actions,
        leading: widget.leading,
        centerTitle: widget.centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: widget.foregroundColor ?? Colors.white,
        elevation: widget.elevation ?? 0,
      ),
    );
  }
}

class _GlassDrawer extends StatelessWidget {
  final Widget child;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool enableBlur;
  final bool enableAnimation;
  final Duration? animationDuration;

  const _GlassDrawer({
    Key? key,
    required this.child,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.enableBlur = true,
    this.enableAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: (widget.backgroundColor ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(widget.borderRadius ?? 20),
          bottomRight: Radius.circular(widget.borderRadius ?? 20),
        ),
        border: Border.all(
          color: (widget.borderColor ?? Colors.white).withOpacity(0.3),
        ),
      ),
      child: widget.child,
    );
  }
}

class _GlassFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;
  final bool enablePulse;
  final bool enableGlow;
  final Duration? animationDuration;