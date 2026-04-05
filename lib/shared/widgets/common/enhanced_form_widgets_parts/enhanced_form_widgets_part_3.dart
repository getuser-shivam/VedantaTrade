      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }

  /// Animated slider with value display
  static Widget animatedSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 100.0,
    int? divisions,
    String Function(double)? valueLabel,
    Color? activeColor,
    Color? inactiveColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool showValue = true,
  }) {
    return _AnimatedSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      divisions: divisions,
      valueLabel: valueLabel,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      showValue: showValue,
    );
  }

  /// Animated switch with custom styling
  static Widget animatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? title,
    String? subtitle,
    Color? activeColor,
    Color? inactiveColor,
    double? width,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _AnimatedSwitch(
      value: value,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      width: width,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Animated checkbox with custom styling
  static Widget animatedCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? title,
    String? subtitle,
    Color? activeColor,
    Color? inactiveColor,
    double? size,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _AnimatedCheckbox(
      value: value,
      onChanged: onChanged,
      title: title,
      subtitle: subtitle,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Animated radio button group
  static Widget animatedRadioGroup<T>({
    required T value,
    required ValueChanged<T> onChanged,
    required List<RadioItem<T>> items,
    String? title,
    Color? activeColor,
    Color? inactiveColor,