import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class EnhancedTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final bool autofocus;
  final Color? fillColor;
  final bool filled;
  final bool showClearButton;
  final bool showPasswordToggle;
  final FieldType fieldType;
  final String? initialValue;

  const EnhancedTextField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.validator,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.autofocus = false,
    this.fillColor,
    this.filled = true,
    this.showClearButton = false,
    this.showPasswordToggle = false,
    this.fieldType = FieldType.text,
    this.initialValue,
  }) : super(key: key);

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                (isDark ? AppTypography.darkLabelMedium : AppTypography.labelMedium),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          validator: widget.validator,
          style: widget.style ??
              (isDark ? AppTypography.darkBodyMedium : AppTypography.bodyMedium),
          decoration: _getInputDecoration(isDark),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: isDark 
                ? AppTypography.darkCaption
                : AppTypography.caption,
          ),
        ],
      ],
    );
  }

  InputDecoration _getInputDecoration(bool isDark) {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.hintStyle ??
          (isDark ? AppTypography.darkBodyMedium : AppTypography.bodyMedium)
              .copyWith(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      prefix: widget.prefix,
      suffix: widget.suffix,
      contentPadding: widget.contentPadding ?? AppSpacing.paddingInput,
      filled: widget.filled,
      fillColor: widget.fillColor ?? (isDark ? AppColors.darkCard : AppColors.primarySurface),
      border: widget.border ??
          OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusInput,
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2),
            ),
          ),
      enabledBorder: widget.enabledBorder ??
          OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusInput,
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2),
            ),
          ),
      focusedBorder: widget.focusedBorder ??
          OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusInput,
            borderSide: BorderSide(
              color: _getFocusedColor(),
              width: 2,
            ),
          ),
      errorBorder: widget.errorBorder ??
          OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusInput,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
      focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusInput,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
      errorText: widget.errorText,
      errorStyle: widget.errorStyle ??
          AppTypography.labelSmall.copyWith(color: AppColors.error),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  Widget? _buildSuffixIcon() {
    final List<Widget> icons = [];

    if (widget.showClearButton && _controller.text.isNotEmpty && !widget.readOnly) {
      icons.add(
        IconButton(
          onPressed: _clearText,
          icon: Icon(
            Icons.clear,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    if (widget.showPasswordToggle && widget.obscureText) {
      icons.add(
        IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }

    if (icons.isEmpty) {
      return null;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  Color _getFocusedColor() {
    switch (widget.fieldType) {
      case FieldType.email:
        return AppColors.info;
      case FieldType.password:
        return AppColors.primary;
      case FieldType.phone:
        return AppColors.secondary;
      case FieldType.url:
        return AppColors.info;
      case FieldType.search:
        return AppColors.primary;
      case FieldType.number:
        return AppColors.success;
      case FieldType.currency:
        return AppColors.success;
      case FieldType.text:
      default:
        return AppColors.primary;
    }
  }
}

class EnhancedDropdown extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T?>? validator;
  final bool enabled;
  final bool isDense;
  final Widget? icon;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? buttonHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final InputDecoration? decoration;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const EnhancedDropdown({
    Key? key,
    required this.items,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isDense = false,
    this.icon,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.buttonHeight,
    this.buttonPadding,
    this.decoration,
    this.autofocus = false,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _EnhancedDropdownState<T> createState() => _EnhancedDropdownState<T>();
}

class _EnhancedDropdownState<T> extends State<EnhancedDropdown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: isDark ? AppTypography.darkLabelMedium : AppTypography.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DropdownButtonFormField<T>(
          value: widget.value,
          items: widget.items,
          onChanged: widget.enabled ? widget.onChanged : null,
          validator: widget.validator,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          isDense: widget.isDense,
          icon: widget.icon,
          iconEnabledColor: widget.iconEnabledColor,
          iconDisabledColor: widget.iconDisabledColor,
          buttonHeight: widget.buttonHeight,
          buttonPadding: widget.buttonPadding ?? AppSpacing.paddingInput,
          decoration: widget.decoration ??
              InputDecoration(
                hintText: widget.hint,
                hintStyle: (isDark ? AppTypography.darkBodyMedium : AppTypography.bodyMedium)
                    .copyWith(color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.primarySurface,
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.radiusInput,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.radiusInput,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.radiusInput,
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.radiusInput,
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.radiusInput,
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                errorText: widget.errorText,
                errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
                contentPadding: AppSpacing.paddingInput,
              ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: isDark ? AppTypography.darkCaption : AppTypography.caption,
          ),
        ],
      ],
    );
  }
}

class EnhancedCheckbox extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final Color? activeColor;
  final Color? checkColor;
  final OutlinedBorder? shape;
  final BorderSide? borderSide;
  final bool tristate;
  final MaterialTapTargetSize? materialTapTargetSize;
  final EdgeInsetsGeometry? contentPadding;

  const EnhancedCheckbox({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.checkColor,
    this.shape,
    this.borderSide,
    this.tristate = false,
    this.materialTapTargetSize,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: AppBorderRadius.radiusSM,
      child: Padding(
        padding: contentPadding ?? AppSpacing.paddingInput,
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? (bool? value) => onChanged?.call(value ?? false) : null,
              activeColor: activeColor ?? AppColors.primary,
              checkColor: checkColor ?? Colors.white,
              shape: shape ?? RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusXS),
              side: borderSide ?? BorderSide(color: isDark ? AppColors.darkBorder : AppColors.textTertiary),
              tristate: tristate,
              materialTapTargetSize: materialTapTargetSize,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: isDark ? AppTypography.darkBodyMedium : AppTypography.bodyMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: isDark ? AppTypography.darkCaption : AppTypography.caption,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final EdgeInsetsGeometry? contentPadding;

  const EnhancedSwitch({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.inactiveThumbColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: AppBorderRadius.radiusSM,
      child: Padding(
        padding: contentPadding ?? AppSpacing.paddingInput,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: isDark ? AppTypography.darkBodyMedium : AppTypography.bodyMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: isDark ? AppTypography.darkCaption : AppTypography.caption,
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? (bool value) => onChanged?.call(value) : null,
              activeColor: activeColor ?? AppColors.primary,
              inactiveThumbColor: inactiveThumbColor ?? (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
              activeTrackColor: activeTrackColor ?? AppColors.primary.withOpacity(0.3),
              inactiveTrackColor: inactiveTrackColor ?? (isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class FormValidator {
  static FormFieldValidator<String> required([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  static FormFieldValidator<String> email([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return message ?? 'Please enter a valid email address';
      }
      return null;
    };
  }

  static FormFieldValidator<String> phone([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
        return message ?? 'Please enter a valid phone number';
      }
      return null;
    };
  }

  static FormFieldValidator<String> minLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (value.trim().length < length) {
        return message ?? 'Minimum length is $length characters';
      }
      return null;
    };
  }

  static FormFieldValidator<String> maxLength(int length, [String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (value.trim().length > length) {
        return message ?? 'Maximum length is $length characters';
      }
      return null;
    };
  }

  static FormFieldValidator<String> number([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (double.tryParse(value) == null) {
        return message ?? 'Please enter a valid number';
      }
      return null;
    };
  }

  static FormFieldValidator<String> url([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (!Uri.tryParse(value).hasAbsolutePath) {
        return message ?? 'Please enter a valid URL';
      }
      return null;
    };
  }

  static FormFieldValidator<String> password([String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
        return 'Password must contain at least one lowercase letter';
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
        return 'Password must contain at least one number';
      }
      if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(value)) {
        return 'Password must contain at least one special character';
      }
      return null;
    };
  }

  static FormFieldValidator<String> match(String compareValue, [String? message]) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Let required validator handle empty
      }
      if (value != compareValue) {
        return message ?? 'Values do not match';
      }
      return null;
    };
  }

  static FormFieldValidator<String> combine(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}

enum FieldType {
  text,
  email,
  password,
  phone,
  url,
  search,
  number,
  currency,
}
