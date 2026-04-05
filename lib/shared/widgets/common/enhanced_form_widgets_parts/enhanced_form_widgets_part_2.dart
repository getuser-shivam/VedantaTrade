      value: value,
      onChanged: onChanged,
      labelText: labelText,
      firstDate: firstDate,
      lastDate: lastDate,
      isRequired: isRequired,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
      enableValidation: enableValidation,
      animationDuration: animationDuration,
      validator: validator,
    );
  }

  /// Animated file picker with preview
  static Widget animatedFilePicker({
    required String? filePath,
    required ValueChanged<String?> onChanged,
    String? labelText,
    String? hintText,
    List<String>? allowedExtensions,
    double? maxFileSize,
    bool isRequired = false,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusColor,
    double? borderRadius,
    bool enableValidation = true,
    Duration? animationDuration,
    String Function(String?)? validator,
  }) {
    return _AnimatedFilePicker(
      filePath: filePath,
      onChanged: onChanged,
      labelText: labelText,
      hintText: hintText,
      allowedExtensions: allowedExtensions,
      maxFileSize: maxFileSize,
      isRequired: isRequired,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
      enableValidation: enableValidation,
      animationDuration: animationDuration,
      validator: validator,
    );
  }

  /// Animated multi-select with chips
  static Widget animatedMultiSelect<T>({
    required List<T> items,
    required List<T> selectedItems,
    required Function(List<T>) onChanged,
    String Function(T)? itemLabel,
    Widget Function(T)? itemWidget,
    Color? backgroundColor,
    Color? borderColor,
    Color? selectedColor,
    double? borderRadius,
    bool enableSearch = false,
    Duration? animationDuration,
  }) {
    return _AnimatedMultiSelect<T>(
      items: items,
      selectedItems: selectedItems,
      onChanged: onChanged,
      itemLabel: itemLabel,
      itemWidget: itemWidget,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      selectedColor: selectedColor,
      borderRadius: borderRadius,
      enableSearch: enableSearch,
      animationDuration: animationDuration,
    );
  }

  /// Animated rating widget
  static Widget animatedRating({
    required double value,
    required ValueChanged<double> onChanged,
    int starCount = 5,
    double size = 24,
    Color? activeColor,
    Color? inactiveColor,
    bool allowHalfRating = false,
    bool enableAnimation = true,
    Duration? animationDuration,
  }) {
    return _AnimatedRating(
      value: value,
      onChanged: onChanged,
      starCount: starCount,
      size: size,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      allowHalfRating: allowHalfRating,