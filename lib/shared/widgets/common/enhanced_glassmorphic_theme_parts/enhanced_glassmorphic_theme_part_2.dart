    bool enableShadow = true,
    bool enableReflection = false,
  }) {
    return _FloatingGlassCard(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      elevation: elevation,
      enableShadow: enableShadow,
      enableReflection: enableReflection,
      child: child,
    );
  }

  /// Create glassmorphic navigation bar with blur effect
  static Widget buildGlassNavigationBar({
    required List<Widget> children,
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    bool enableBlur = true,
    bool enableGlow = false,
    double? blurAmount,
  }) {
    return _GlassNavigationBar(
      children: children,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      enableBlur: enableBlur,
      enableGlow: enableGlow,
      blurAmount: blurAmount,
    );
  }

  /// Create glassmorphic bottom sheet with slide animation
  static Widget buildGlassBottomSheet({
    required Widget child,
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    bool enableDragHandle = true,
    bool enableBlur = true,
    Duration? animationDuration,
  }) {
    return _GlassBottomSheet(
      child: child,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      enableDragHandle: enableDragHandle,
      enableBlur: enableBlur,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic dialog with scale animation
  static Widget buildGlassDialog({
    required Widget child,
    String? title,
    List<Widget>? actions,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    bool enableScale = true,
    bool enableBlur = true,
    Duration? animationDuration,
  }) {
    return _GlassDialog(
      child: child,
      title: title,
      actions: actions,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      enableScale: enableScale,
      enableBlur: enableBlur,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic list with hover effects
  static Widget buildGlassList({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    bool enableHover = true,
    bool enableSeparators = true,