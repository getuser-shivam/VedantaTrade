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
  final Color? borderColor;
  final Color? errorColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
  final String Function(String)? onChanged;
  final VoidCallback? onEditingComplete;

  const _AnimatedTextField({
    Key? key,
    required this.controller,
    required this.validator,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.focusNode,
    this.backgroundColor,
    this.borderColor,
    this.errorColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
    this.onChanged,
    this.onEditingComplete,
  }) : super(key: key);

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<double> _labelAnimation;
  late Animation<Color> _borderColorAnimation;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _labelAnimation = Tween<double>(
      begin: 12.0,
      end: 14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? Colors.grey,
      end: widget.focusColor ?? Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused != _isFocused) {
      setState(() {
        _isFocused = isFocused;
      });
      
      if (isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _validateText(String value) {
    if (!widget.enableValidation) return;
    
    final error = widget.validator(value);
    setState(() {
      _errorText = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.validator(widget.controller.text);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            border: Border.all(
              color: _errorText != null
                  ? (widget.errorColor ?? Colors.red)
                  : _borderColorAnimation.value,
              width: _isFocused ? _borderAnimation.value : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (widget.focusColor ?? Colors.blue).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: _labelAnimation.value,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: Colors.black54)
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(widget.suffixIcon, color: Colors.black54),
                      onPressed: widget.onSuffixIconPressed,
                    )
                  : null,
              labelStyle: TextStyle(
                fontSize: _labelAnimation.value,
                color: _isFocused ? (widget.focusColor ?? Colors.blue) : Colors.black54,
              ),
              hintStyle: const TextStyle(color: Colors.black38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              _validateText(value);
              widget.onChanged?.call(value);
            },
            onEditingComplete: widget.onEditingComplete,
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for other enhanced form widgets
class _AnimatedDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isSearchable;
  final String Function(T)? searchFilter;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;

  const _AnimatedDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.isSearchable = false,
    this.searchFilter,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedDropdown<T>> createState() => _AnimatedDropdownState<T>>();
}

class _AnimatedDropdownState<T> extends State<_AnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            border: Border.all(
              color: widget.borderColor ?? Colors.grey,
              width: 1.0,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            onChanged: widget.onChanged,
            items: widget.items,
            hint: widget.hintText != null
                ? Text(widget.hintText!)
                : null,
            icon: widget.prefixIcon != null
                ? Transform.rotate(
                    angle: _iconAnimation.value,
                    child: Icon(widget.prefixIcon),
                  )
                : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedDatePicker extends StatefulWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? labelText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
  final String Function(DateTime)? validator;

  const _AnimatedDatePicker({
    Key? key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
    this.validator,
  }) : super(key: key);

  @override
  State<_AnimatedDatePicker> createState() => _AnimatedDatePickerState();
}

class _AnimatedDatePickerState extends State<_AnimatedDatePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: TextEditingController(text: widget.value.toString().split(' ')[0]),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: widget.value,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                );
                
                if (picked != null) {
                  widget.onChanged(picked!);
                }
              },
              decoration: InputDecoration(
                labelText: widget.labelText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedFilePicker extends StatefulWidget {
  final String? filePath;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final String? hintText;
  final List<String>? allowedExtensions;
  final double? maxFileSize;
  final bool isRequired;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusColor;
  final double? borderRadius;
  final bool enableValidation;
  final Duration? animationDuration;
  final String Function(String?)? validator;

  const _AnimatedFilePicker({
    Key? key,
    this.filePath,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.allowedExtensions,
    this.maxFileSize,
    this.isRequired = false,
    this.backgroundColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius,
    this.enableValidation = true,
    this.animationDuration,
    this.validator,
  }) : super(key: key);

  @override
  State<_AnimatedFilePicker> createState() => _AnimatedFilePickerState();
}

class _AnimatedFilePickerState extends State<_AnimatedFilePicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    // File picker implementation would go here
    // This is a placeholder for the actual file picker logic
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.black54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.filePath ?? widget.hintText ?? 'Select file',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedMultiSelect<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final Function(List<T>) onChanged;
  final String Function(T)? itemLabel;
  final Widget Function(T)? itemWidget;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final double? borderRadius;
  final bool enableSearch;
  final Duration? animationDuration;

  const _AnimatedMultiSelect({
    Key? key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.itemLabel,
    this.itemWidget,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.borderRadius,
    this.enableSearch = false,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedMultiSelect<T>> createState() => _AnimatedMultiSelectState<T>();
}

class _AnimatedMultiSelectState<T> extends State<_AnimatedMultiSelect<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey,
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                // Multi-select implementation would go here
                // This is a placeholder for the actual multi-select logic
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedRating extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final int starCount;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool allowHalfRating;
  final bool enableAnimation;
  final Duration? animationDuration;

  const _AnimatedRating({
    Key? key,
    required this.value,
    required this.onChanged,
    this.starCount = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.allowHalfRating = false,
    this.enableAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedRating> createState() => _AnimatedRatingState();
}

class _AnimatedRatingState extends State<_AnimatedRating>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.starCount, (index) {
              final starValue = index + 1.0;
              final isActive = widget.value >= starValue;
              final isHalfActive = widget.allowHalfRating && 
                  widget.value >= starValue - 0.5 && 
                  widget.value < starValue;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onChanged(starValue.toDouble());
                },
                child: Icon(
                  isHalfActive ? Icons.star_half : Icons.star,
                  color: isActive
                      ? (widget.activeColor ?? Colors.amber)
                      : (widget.inactiveColor ?? Colors.grey),
                  size: widget.size,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? valueLabel;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool showValue;

  const _AnimatedSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.valueLabel,
    this.activeColor,
    this.inactiveColor,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.showValue = true,
  }) : super(key: key);

  @override
  State<_AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<_AnimatedSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Slider(
                value: widget.value,
                onChanged: widget.onChanged,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                activeColor: widget.activeColor ?? Colors.blue,
                inactiveColor: widget.inactiveColor ?? Colors.grey,
              ),
              if (widget.showValue)
                Text(
                  widget.valueLabel?.call(_valueAnimation.value) ?? 
                      _valueAnimation.value.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.black87),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? width;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.width,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.value ? _scaleAnimation.value : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.value
                  ? (widget.activeColor ?? Colors.blue).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.value
                    ? (widget.activeColor ?? Colors.blue)
                    : (widget.inactiveColor ?? Colors.grey),
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                Switch(
                  value: widget.value,
                  onChanged: (value) {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onChanged(value);
                  },
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: TextStyle(
                            color: widget.value
                                ? (widget.activeColor ?? Colors.blue)
                                : (widget.inactiveColor ?? Colors.grey),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: widget.value
                                ? (widget.activeColor ?? Colors.blue).withOpacity(0.8)
                                : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.value ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () {
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              widget.onChanged(!widget.value);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.value
                      ? (widget.activeColor ?? Colors.blue)
                      : (widget.inactiveColor ?? Colors.grey),
                  width: 2.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: widget.value,
                      onChanged: widget.onChanged,
                      activeColor: widget.activeColor ?? Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title != null)
                            Text(
                              widget.title!,
                              style: TextStyle(
                                color: widget.value
                                    ? (widget.activeColor ?? Colors.blue)
                                    : (widget.inactiveColor ?? Colors.grey),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(
                                color: widget.value
                                    ? (widget.activeColor ?? Colors.blue).withOpacity(0.8)
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedRadioGroup<T> extends StatefulWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final List<RadioItem<T>> items;
  final String? title;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedRadioGroup({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.title,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedRadioGroup<T>> createState() => _AnimatedRadioGroupState<T>();
}

class _AnimatedRadioGroupState<T> extends State<_AnimatedRadioGroup<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ...widget.items.map((item) => RadioListTile<T>(
                  title: Text(item.title),
                  subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                  secondary: item.icon != null ? Icon(item.icon) : null,
                  value: item.value,
                  groupValue: widget.value,
                  onChanged: (value) {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onChanged(value);
                  },
                  activeColor: widget.activeColor ?? Colors.blue,
                  inactiveColor: widget.inactiveColor ?? Colors.grey,
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final double? borderRadius;
  final bool showPercentage;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enablePulse;

  const _AnimatedProgressIndicator({
    Key? key,
    required this.value,
    this.label,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
    this.showPercentage = true,
    this.enableAnimation = true,
    this.animationDuration,
    this.enablePulse = false,
  }) : super(key: key);

  @override
  State<_AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<_AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePulse ? _pulseAnimation.value : 1.0,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.label!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: widget.progressColor ?? Colors.blue,
                  ),
                ),
                if (widget.showPercentage)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder implementations for remaining widgets
class _AnimatedStepper extends StatefulWidget {
  final int currentStep;
  final List<Step> steps;
  final ValueChanged<int>? onStepTapped;
  final ValueChanged<int>? onStepContinue;
  final ValueChanged<int>? onStepCancel;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableAnimation;
  final Duration? animationDuration;

  const _AnimatedStepper({
    Key? key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.activeColor,
    this.inactiveColor,
    this.enableAnimation = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  State<_AnimatedStepper> createState() => _AnimatedStepperState();
}

class _AnimatedStepperState extends State<_AnimatedStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50),
          child: Stepper(
            currentStep: widget.currentStep,
            steps: widget.steps,
            onStepTapped: widget.onStepTapped,
            onStepContinue: widget.onStepContinue,
            onStepCancel: widget.onStepCancel,
            controlsBuilder: (context, details) {
              return Row(
                children: [
                  if (details.currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('BACK'),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.activeColor ?? Colors.blue,
                    ),
                    child: const Text('CONTINUE'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
