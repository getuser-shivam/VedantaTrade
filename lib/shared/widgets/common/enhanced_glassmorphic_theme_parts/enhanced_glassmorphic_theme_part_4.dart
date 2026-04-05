      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic progress indicator with animated fill
  static Widget buildGlassProgressIndicator({
    required double value,
    String? label,
    Color? backgroundColor,
    Color? progressColor,
    double? height,
    double? borderRadius,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableGlow = false,
  }) {
    return _GlassProgressIndicator(
      value: value,
      label: label,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      height: height,
      borderRadius: borderRadius,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableGlow: enableGlow,
    );
  }

  /// Create glassmorphic chip with selection animation
  static Widget buildGlassChip({
    required Widget label,
    required bool isSelected,
    required VoidCallback? onSelected,
    VoidCallback? onDeleted,
    Color? backgroundColor,
    Color? selectedColor,
    Color? textColor,
    double? borderRadius,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _GlassChip(
      label: label,
      isSelected: isSelected,
      onSelected: onSelected,
      onDeleted: onDeleted,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      textColor: textColor,
      borderRadius: borderRadius,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic tab bar with indicator animation
  static Widget buildGlassTabBar({
    required List<Tab> tabs,
    required TabController controller,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? labelColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableGlow = false,
  }) {
    return _GlassTabBar(
      tabs: tabs,
      controller: controller,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableGlow: enableGlow,
    );
  }

  /// Create glassmorphic app bar with scroll effects
  static Widget buildGlassAppBar({
    String? title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool enableBlur = true,
    bool enableGlow = false,
    bool enableScrollAnimation = true,
  }) {
    return _GlassAppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,