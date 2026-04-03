import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';
import 'package:vedanta_trade/shared/widgets/glassmorphic_widgets.dart';

class AccessibilityHelper {
  static bool isScreenReaderEnabled(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  static bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  static bool isReduceMotionEnabled(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  static double getPreferredFontSize(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  static bool isLargeTextMode(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.0;
  }
}

class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? semanticLabel;
  final String? hint;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;

  const AccessibleButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.semanticLabel,
    this.hint,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? Colors.white;

    Widget buttonContent = GlassmorphicCard(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      backgroundColor: buttonColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: buttonTextColor, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: buttonTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );

    if (isLoading) {
      buttonContent = GlassmorphicCard(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        backgroundColor: buttonColor.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading...',
              style: TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      hint: hint,
      excludeSemantics: true,
      child: Focus(
        focusNode: FocusNode(),
        child: GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: buttonContent,
        ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      excludeSemantics: true,
      child: Focus(
        focusNode: FocusNode(),
        child: GestureDetector(
          onTap: onTap,
          child: GlassmorphicCard(
            width: width,
            height: height,
            padding: padding,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderRadius: borderRadius,
            child: child,
          ),
        ),
      ),
    );
  }
}

class AccessibleFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  const AccessibleFormField({
    Key? key,
    required this.label,
    this.hint,
    this.errorText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          header: true,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.white : Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          textField: true,
          label: label,
          hint: hint,
          excludeSemantics: true,
          child: Focus(
            focusNode: FocusNode(),
            child: GlassmorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: enabled ? AppTheme.glassBg : AppTheme.glassBg.withOpacity(0.5),
              borderColor: errorText != null ? AppTheme.error : AppTheme.glassBorderLight,
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onChanged: onChanged,
                onFieldSubmitted: onSubmitted,
                onTap: onTap,
                validator: validator,
                enabled: enabled,
                maxLines: maxLines,
                maxLength: maxLength,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: AccessibilityHelper.getPreferredFontSize(context) * 16,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.white.withOpacity(0.7))
                      : null,
                  suffixIcon: suffixIcon != null
                      ? IconButton(
                          icon: Icon(suffixIcon, color: Colors.white.withOpacity(0.7)),
                          onPressed: onSuffixIconTap,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class AccessibleSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final String? semanticLabel;
  final String Function(double)? valueFormatter;

  const AccessibleSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions = 10,
    required this.label,
    this.semanticLabel,
    this.valueFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          header: true,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Semantics(
                slider: true,
                label: semanticLabel ?? label,
                value: valueFormatter?.call(value) ?? value.toStringAsFixed(1),
                excludeSemantics: true,
                child: Focus(
                  focusNode: FocusNode(),
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                    min: min,
                    max: max,
                    divisions: divisions,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                valueFormatter?.call(value) ?? value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? semanticLabel;
  final String? hint;

  const AccessibleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.semanticLabel,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: label,
            hint: hint,
            excludeSemantics: true,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Semantics(
          switch: true,
          label: semanticLabel ?? label,
          value: value ? 'on' : 'off',
          excludeSemantics: true,
          child: Focus(
            focusNode: FocusNode(),
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class AccessibleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String? semanticLabel;
  final String? hint;

  const AccessibleCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.semanticLabel,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          checkbox: true,
          label: semanticLabel ?? label,
          hint: hint,
          value: value ? 'checked' : 'unchecked',
          excludeSemantics: true,
          child: Focus(
            focusNode: FocusNode(),
            child: Checkbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AccessibleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  const AccessibleChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      excludeSemantics: true,
      child: Focus(
        focusNode: FocusNode(),
        child: GestureDetector(
          onTap: () => onSelected(!selected),
          child: GlassmorphicCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: selected ? selectedColor : backgroundColor,
            borderRadius: BorderRadius.circular(20),
            child: Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccessibleProgressIndicator extends StatelessWidget {
  final double value;
  final String label;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? progressColor;

  const AccessibleProgressIndicator({
    Key? key,
    required this.value,
    required this.label,
    this.semanticLabel,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: label,
          header: true,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          progressBar: true,
          label: semanticLabel ?? label,
          value: '${(value * 100).toInt()}%',
          excludeSemantics: true,
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Semantics(
          liveRegion: true,
          child: Text(
            '${(value * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
