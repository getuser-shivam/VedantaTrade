    double? separatorHeight,
  }) {
    return _GlassList(
      children: children,
      padding: padding,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      enableHover: enableHover,
      enableSeparators: enableSeparators,
      separatorHeight: separatorHeight,
    );
  }

  /// Create glassmorphic input field with focus effects
  static Widget buildGlassInput({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String)? validator,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusColor,
    double? borderRadius,
    bool enableFocusAnimation = true,
    Duration? animationDuration,
  }) {
    return _GlassInput(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
      enableFocusAnimation: enableFocusAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic switch with smooth animation
  static Widget buildGlassSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? title,
    Color? activeColor,
    Color? inactiveColor,
    double? width,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _GlassSwitch(
      value: value,
      onChanged: onChanged,
      title: title,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      width: width,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Create glassmorphic slider with track animation
  static Widget buildGlassSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double? min,
    double? max,
    int? divisions,
    String? label,
    Color? activeColor,
    Color? inactiveColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _GlassSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      height: height,
