import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced form widgets with better UX
class EnhancedFormWidgets {
  /// Animated text field with validation feedback
  static Widget animatedTextField({
    required TextEditingController controller,
    required String Function(String) validator,
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    TextInputType? keyboardType,
    bool obscureText = false,
    FocusNode? focusNode,
    Color? backgroundColor,
    Color? borderColor,
    Color? errorColor,
    Color? focusColor,
    double? borderRadius,
    bool enableValidation = true,
    Duration? animationDuration,
    String? Function(String)? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return _AnimatedTextField(
      controller: controller,
      validator: validator,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconPressed: onSuffixIconPressed,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      errorColor: errorColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
      enableValidation: enableValidation,
      animationDuration: animationDuration,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
    );
  }

  /// Animated dropdown with search functionality
  static Widget animatedDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T> onChanged,
    String? hintText,
    IconData? prefixIcon,
    bool isSearchable = false,
    String Function(T)? searchFilter,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusColor,
    double? borderRadius,
    bool enableValidation = true,
    Duration? animationDuration,
  }) {
    return _AnimatedDropdown<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      hintText: hintText,
      prefixIcon: prefixIcon,
      isSearchable: isSearchable,
      searchFilter: searchFilter,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      focusColor: focusColor,
      borderRadius: borderRadius,
      enableValidation: enableValidation,
      animationDuration: animationDuration,
    );
  }

  /// Animated date picker with validation
  static Widget animatedDatePicker({
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
    String? labelText,
    DateTime? firstDate,
    DateTime? lastDate,
    bool isRequired = false,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusColor,
    double? borderRadius,
    bool enableValidation = true,
    Duration? animationDuration,
    String Function(DateTime)? validator,
  }) {
    return _AnimatedDatePicker(