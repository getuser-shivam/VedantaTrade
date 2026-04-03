import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final ButtonType type;
  final ButtonSize size;
  final ButtonStyle style;
  final bool fullWidth;
  final bool isLoading;
  final Color? customColor;
  final double? customWidth;
  final double? customHeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool enableFeedback;
  final Duration animationDuration;
  final Curve animationCurve;

  const EnhancedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.style = ButtonStyle.solid,
    this.fullWidth = false,
    this.isLoading = false,
    this.customColor,
    this.customWidth,
    this.customHeight,
    this.padding,
    this.borderRadius,
    this.semanticLabel,
    this.enableFeedback = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buttonColor = widget.customColor ?? _getButtonColor(isDark);
    final textColor = _getTextColor(isDark);
    final effectivePadding = widget.padding ?? _getPadding();
    final effectiveBorderRadius = widget.borderRadius ?? _getBorderRadius();
    final effectiveHeight = widget.customHeight ?? _getHeight();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Semantics(
              button: true,
              label: widget.semanticLabel ?? widget.text,
              excludeSemantics: true,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.isLoading ? null : widget.onPressed,
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  width: widget.fullWidth ? double.infinity : widget.customWidth,
                  height: effectiveHeight,
                  padding: effectivePadding,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(buttonColor),
                    borderRadius: effectiveBorderRadius,
                    border: _getBorder(buttonColor),
                    boxShadow: _getBoxShadow(buttonColor),
                    gradient: _getGradient(buttonColor),
                  ),
                  child: _buildButtonContent(textColor, buttonColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(Color textColor, Color buttonColor) {
    if (widget.isLoading) {
      return _buildLoadingContent(textColor);
    }

    final hasIcon = widget.icon != null;
    final textWidget = Text(
      widget.text,
      style: _getTextStyle(textColor),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (hasIcon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.icon!,
          if (widget.text.isNotEmpty) ...[
            SizedBox(width: widget.size == ButtonSize.small ? AppSpacing.xs : AppSpacing.sm),
            Flexible(child: textWidget),
          ],
        ],
      );
    }

    return Center(child: textWidget);
  }

  Widget _buildLoadingContent(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getLoadingSize(),
          height: _getLoadingSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          'Loading...',
          style: _getTextStyle(textColor),
        ),
      ],
    );
  }

  Color _getButtonColor(bool isDark) {
    switch (widget.type) {
      case ButtonType.primary:
        return isDark ? AppColors.primary : AppColors.primary;
      case ButtonType.secondary:
        return isDark ? AppColors.secondary : AppColors.secondary;
      case ButtonType.success:
        return AppColors.success;
      case ButtonType.warning:
        return AppColors.warning;
      case ButtonType.error:
        return AppColors.error;
      case ButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDark) {
    if (widget.style == ButtonStyle.outline) {
      return widget.customColor ?? _getButtonColor(isDark);
    }
    return widget.style == ButtonStyle.ghost
        ? (widget.customColor ?? _getButtonColor(isDark))
        : Colors.white;
  }

  TextStyle _getTextStyle(Color textColor) {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.buttonTextSmall.copyWith(color: textColor);
      case ButtonSize.medium:
      case ButtonSize.large:
        return AppTypography.buttonText.copyWith(color: textColor);
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.paddingButtonSM;
      case ButtonSize.medium:
        return AppSpacing.paddingButton;
      case ButtonSize.large:
        return AppSpacing.paddingButtonLG;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppBorderRadius.radiusButtonSM;
      case ButtonSize.medium:
        return AppBorderRadius.radiusButton;
      case ButtonSize.large:
        return AppBorderRadius.radiusButtonLG;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSizes.buttonHeightSM;
      case ButtonSize.medium:
        return AppSizes.buttonHeightMD;
      case ButtonSize.large:
        return AppSizes.buttonHeightLG;
    }
  }

  double _getLoadingSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.0;
      case ButtonSize.medium:
        return 16.0;
      case ButtonSize.large:
        return 20.0;
    }
  }

  Color _getBackgroundColor(Color buttonColor) {
    switch (widget.style) {
      case ButtonStyle.solid:
        return buttonColor;
      case ButtonStyle.outline:
        return Colors.transparent;
      case ButtonStyle.ghost:
        return buttonColor.withOpacity(0.1);
    }
  }

  Border? _getBorder(Color buttonColor) {
    switch (widget.style) {
      case ButtonStyle.outline:
        return Border.all(color: buttonColor, width: 1.5);
      case ButtonStyle.ghost:
      case ButtonStyle.solid:
        return null;
    }
  }

  List<BoxShadow> _getBoxShadow(Color buttonColor) {
    if (widget.style == ButtonStyle.outline || widget.style == ButtonStyle.ghost) {
      return [];
    }

    return [
      BoxShadow(
        color: buttonColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  LinearGradient? _getGradient(Color buttonColor) {
    if (widget.style != ButtonStyle.solid) {
      return null;
    }

    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.primaryGradient;
      case ButtonType.secondary:
        return AppColors.secondaryGradient;
      case ButtonType.success:
        return AppColors.successGradient;
      case ButtonType.error:
        return AppColors.errorGradient;
      default:
        return null;
    }
  }
}

enum ButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  outline,
}

enum ButtonStyle {
  solid,
  outline,
  ghost,
}

enum ButtonSize {
  small,
  medium,
  large,
}
