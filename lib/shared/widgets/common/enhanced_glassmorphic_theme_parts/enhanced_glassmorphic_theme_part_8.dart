      child: InkWell(
        onTap: widget.isDisabled || widget.isLoading ? null : () {
          HapticFeedback.lightImpact();
          widget.onPressed();
        },
        onHighlightChanged: (highlighted) {
          if (highlighted) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enableScale ? _scaleAnimation.value : 1.0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                    if (widget.enableGlow)
                      BoxShadow(
                        color: effectiveBackgroundColor.withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 20.0,
                        offset: const Offset(0, 0),
                        spreadRadius: 2.0,
                      ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                          ),
                        )
                      : widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Floating Glass Card Implementation
class _FloatingGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final bool enableShadow;
  final bool enableReflection;

  const _FloatingGlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.enableShadow = true,
    this.enableReflection = false,
  }) : super(key: key);

  @override
  State<_FloatingGlassCard> createState() => _FloatingGlassCardState();
}

class _FloatingGlassCardState extends State<_FloatingGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;