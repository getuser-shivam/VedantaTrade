import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';

enum ButtonType { primary, secondary, outlined, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 48,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading;

    ButtonStyle buttonStyle = _getButtonStyle(context, type);

    if (effectiveDisabled) {
      buttonStyle = buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        ),
        foregroundColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveDisabled ? null : onPressed,
        style: buttonStyle.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.sm),
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTextColor(context, type),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: AppSizes.xs),
                  ],
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(context, type),
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: AppSizes.xs),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, ButtonType type) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 2,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
        );

      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          elevation: 1,
        );

      case ButtonType.outlined:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          elevation: 0,
        );

      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          elevation: 2,
        );
    }
  }

  Color _getTextColor(BuildContext context, ButtonType type) {
    switch (type) {
      case ButtonType.primary:
        return Theme.of(context).colorScheme.onPrimary;
      case ButtonType.secondary:
        return Theme.of(context).colorScheme.onSecondary;
      case ButtonType.outlined:
        return Theme.of(context).colorScheme.primary;
      case ButtonType.danger:
        return Theme.of(context).colorScheme.onError;
    }
  }
}
