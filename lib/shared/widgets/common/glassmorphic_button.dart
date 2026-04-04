import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Glassmorphic button widget with consistent styling
class GlassmorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? child;
  final bool isOutlined;
  final bool isElevated;

  const GlassmorphicButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.padding,
    this.textStyle,
    this.child,
    this.isOutlined = false,
    this.isElevated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveHeight = height ?? 48.0;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    return SizedBox(
      width: width,
      height: effectiveHeight,
      child: Material(
        type: MaterialType.button,
        color: isOutlined ? Colors.transparent : effectiveBackgroundColor,
        elevation: isElevated ? 8.0 : 0.0,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: isOutlined ? Colors.transparent : effectiveBackgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: isOutlined ? Border.all(color: effectiveBorderColor) : null,
              boxShadow: isElevated && !isOutlined ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            padding: effectivePadding,
            child: child ?? _buildButtonContent(effectiveForegroundColor),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: foregroundColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle ?? TextStyle(
              color: foregroundColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle ?? TextStyle(
        color: foregroundColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Glassmorphic icon button
class GlassmorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? size;
  final double? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  const GlassmorphicIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.size,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.padding,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveSize = size ?? 48.0;
    final effectivePadding = padding ?? const EdgeInsets.all(12);

    Widget button = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Material(
        type: MaterialType.button,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: effectiveBackgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              border: Border.all(color: effectiveBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: effectivePadding,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: effectiveForegroundColor,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Glassmorphic text button
class GlassmorphicTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;

  const GlassmorphicTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.foregroundColor,
    this.textStyle,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForegroundColor = foregroundColor ?? theme.primaryColor;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return Material(
      type: MaterialType.button,
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled || isLoading ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveForegroundColor.withOpacity(0.3)),
          ),
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                  ),
                )
              : Text(
                  text,
                  style: textStyle ?? TextStyle(
                    color: effectiveForegroundColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
