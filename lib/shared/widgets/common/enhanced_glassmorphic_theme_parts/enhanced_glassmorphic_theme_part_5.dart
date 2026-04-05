      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      enableBlur: enableBlur,
      enableGlow: enableGlow,
      enableScrollAnimation: enableScrollAnimation,
    );
  }

  /// Create glassmorphic drawer with slide animation
  static Widget buildGlassDrawer({
    required Widget child,
    double? width,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    bool enableBlur = true,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _GlassDrawer(
      child: child,
      width: width,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      enableBlur: enableBlur,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic floating action button with pulse animation
  static Widget buildGlassFloatingActionButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    double? size,
    bool enablePulse = false,
    bool enableGlow = false,
    Duration? animationDuration,
  }) {
    return _GlassFloatingActionButton(
      child: child,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      size: size,
      enablePulse: enablePulse,
      enableGlow: enableGlow,
      animationDuration: animationDuration,
    );
  }
}

/// Private implementation classes for enhanced glassmorphic components
class _GlassmorphicContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? blur;
  final double? opacity;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isAnimated;
  final Duration? animationDuration;
  final bool enableGlow;
  final bool enableGradient;
  final Gradient? gradient;

  const _GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.blur,
    this.opacity,
    this.boxShadow,
    this.onTap,
    this.isAnimated = true,
    this.animationDuration,
    this.enableGlow = false,
    this.enableGradient = false,
    this.gradient,
  }) : super(key: key);

  @override