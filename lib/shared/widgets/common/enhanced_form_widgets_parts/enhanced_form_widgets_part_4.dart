    double? size,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _AnimatedRadioGroup<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      title: title,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      size: size,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Animated progress indicator with percentage
  static Widget animatedProgressIndicator({
    required double value,
    String? label,
    Color? backgroundColor,
    Color? progressColor,
    double? height,
    double? borderRadius,
    bool showPercentage = true,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enablePulse = false,
  }) {
    return _AnimatedProgressIndicator(
      value: value,
      label: label,
      backgroundColor: backgroundColor,
      progressColor: progressColor,
      height: height,
      borderRadius: borderRadius,
      showPercentage: showPercentage,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enablePulse: enablePulse,
    );
  }

  /// Animated stepper form
  static Widget animatedStepper({
    required int currentStep,
    required List<Step> steps,
    ValueChanged<int>? onStepTapped,
    ValueChanged<int>? onStepContinue,
    ValueChanged<int>? onStepCancel,
    Color? activeColor,
    Color? inactiveColor,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _AnimatedStepper(
      currentStep: currentStep,
      steps: steps,
      onStepTapped: onStepTapped,
      onStepContinue: onStepContinue,
      onStepCancel: onStepCancel,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
    );
  }
}

/// Radio item for animated radio group
class RadioItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const RadioItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}

/// Private implementation classes for enhanced form widgets
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String Function(String) validator;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final Color? backgroundColor;