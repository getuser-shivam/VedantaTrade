import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomButtonType {
  primary,
  secondary,
  outlined,
  text,
  gradient,
  success,
  warning,
  error,
}

enum CustomButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final CustomButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? child;
  final Color? customColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final double? elevation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.customColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration!,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
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

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && !widget.isDisabled) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && !widget.isDisabled) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  Future<void> _handlePress() async {
    if (widget.isLoading || widget.isDisabled) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    await widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: widget.isDisabled ? 0.5 : _opacityAnimation.value,
            child: SizedBox(
              width: widget.isFullWidth ? double.infinity : null,
              child: _buildButton(theme, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(ThemeData theme, bool isDark) {
    final colors = _getButtonColors(theme, isDark);
    final sizes = _getButtonSizes();

    switch (widget.type) {
      case CustomButtonType.primary:
        return _buildElevatedButton(colors, sizes, theme);
      case CustomButtonType.secondary:
        return _buildElevatedButton(colors, sizes, theme);
      case CustomButtonType.outlined:
        return _buildOutlinedButton(colors, sizes, theme);
      case CustomButtonType.text:
        return _buildTextButton(colors, sizes, theme);
      case CustomButtonType.gradient:
        return _buildGradientButton(colors, sizes, theme);
      case CustomButtonType.success:
        return _buildElevatedButton(colors, sizes, theme);
      case CustomButtonType.warning:
        return _buildElevatedButton(colors, sizes, theme);
      case CustomButtonType.error:
        return _buildElevatedButton(colors, sizes, theme);
    }
  }

  Widget _buildElevatedButton(
    Map<String, Color> colors,
    Map<String, double> sizes,
    ThemeData theme,
  ) {
    return ElevatedButton(
      onPressed: widget.isLoading || widget.isDisabled ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.customColor ?? colors['backgroundColor'],
        foregroundColor: colors['foregroundColor'],
        elevation: widget.elevation ?? 2,
        shadowColor: colors['shadowColor'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        ),
        padding: widget.padding ?? EdgeInsets.symmetric(
          horizontal: sizes['horizontalPadding']!,
          vertical: sizes['verticalPadding']!,
        ),
        minimumSize: Size(
          sizes['minWidth']!,
          sizes['minHeight']!,
        ),
      ),
      child: _buildButtonContent(sizes['fontSize']!),
    );
  }

  Widget _buildOutlinedButton(
    Map<String, Color> colors,
    Map<String, double> sizes,
    ThemeData theme,
  ) {
    return OutlinedButton(
      onPressed: widget.isLoading || widget.isDisabled ? null : _handlePress,
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.customColor ?? colors['foregroundColor'],
        side: BorderSide(
          color: widget.customColor ?? colors['foregroundColor']!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        ),
        padding: widget.padding ?? EdgeInsets.symmetric(
          horizontal: sizes['horizontalPadding']!,
          vertical: sizes['verticalPadding']!,
        ),
        minimumSize: Size(
          sizes['minWidth']!,
          sizes['minHeight']!,
        ),
      ),
      child: _buildButtonContent(sizes['fontSize']!),
    );
  }

  Widget _buildTextButton(
    Map<String, Color> colors,
    Map<String, double> sizes,
    ThemeData theme,
  ) {
    return TextButton(
      onPressed: widget.isLoading || widget.isDisabled ? null : _handlePress,
      style: TextButton.styleFrom(
        foregroundColor: widget.customColor ?? colors['foregroundColor'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        ),
        padding: widget.padding ?? EdgeInsets.symmetric(
          horizontal: sizes['horizontalPadding']!,
          vertical: sizes['verticalPadding']!,
        ),
        minimumSize: Size(
          sizes['minWidth']!,
          sizes['minHeight']!,
        ),
      ),
      child: _buildButtonContent(sizes['fontSize']!),
    );
  }

  Widget _buildGradientButton(
    Map<String, Color> colors,
    Map<String, double> sizes,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors['backgroundColor']!,
            colors['backgroundColor']!.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        boxShadow: [
          BoxShadow(
            color: colors['shadowColor']!.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading || widget.isDisabled ? null : _handlePress,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          child: Container(
            padding: widget.padding ?? EdgeInsets.symmetric(
              horizontal: sizes['horizontalPadding']!,
              vertical: sizes['verticalPadding']!,
            ),
            constraints: BoxConstraints(
              minWidth: sizes['minWidth']!,
              minHeight: sizes['minHeight']!,
            ),
            child: _buildButtonContent(sizes['fontSize']!),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(double fontSize) {
    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.type == CustomButtonType.outlined ||
                        widget.type == CustomButtonType.text
                    ? _getButtonColors(
                        Theme.of(context),
                        Theme.of(context).brightness == Brightness.dark,
                      )['foregroundColor']
                    : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Map<String, Color> _getButtonColors(ThemeData theme, bool isDark) {
    switch (widget.type) {
      case CustomButtonType.primary:
        return {
          'backgroundColor': widget.customColor ?? theme.colorScheme.primary,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.2),
        };
      case CustomButtonType.secondary:
        return {
          'backgroundColor': widget.customColor ?? theme.colorScheme.secondary,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.2),
        };
      case CustomButtonType.outlined:
        return {
          'backgroundColor': Colors.transparent,
          'foregroundColor': widget.customColor ?? theme.colorScheme.primary,
          'shadowColor': Colors.transparent,
        };
      case CustomButtonType.text:
        return {
          'backgroundColor': Colors.transparent,
          'foregroundColor': widget.customColor ?? theme.colorScheme.primary,
          'shadowColor': Colors.transparent,
        };
      case CustomButtonType.gradient:
        return {
          'backgroundColor': widget.customColor ?? theme.colorScheme.primary,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.3),
        };
      case CustomButtonType.success:
        return {
          'backgroundColor': AppTheme.successColor,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.2),
        };
      case CustomButtonType.warning:
        return {
          'backgroundColor': AppTheme.warningColor,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.2),
        };
      case CustomButtonType.error:
        return {
          'backgroundColor': AppTheme.errorColor,
          'foregroundColor': Colors.white,
          'shadowColor': Colors.black.withOpacity(0.2),
        };
    }
  }

  Map<String, double> _getButtonSizes() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return {
          'fontSize': 12.0,
          'horizontalPadding': 12.0,
          'verticalPadding': 8.0,
          'minWidth': 64.0,
          'minHeight': 32.0,
        };
      case CustomButtonSize.medium:
        return {
          'fontSize': 14.0,
          'horizontalPadding': 16.0,
          'verticalPadding': 10.0,
          'minWidth': 80.0,
          'minHeight': 40.0,
        };
      case CustomButtonSize.large:
        return {
          'fontSize': 16.0,
          'horizontalPadding': 20.0,
          'verticalPadding': 12.0,
          'minWidth': 96.0,
          'minHeight': 48.0,
        };
      case CustomButtonSize.extraLarge:
        return {
          'fontSize': 18.0,
          'horizontalPadding': 24.0,
          'verticalPadding': 14.0,
          'minWidth': 112.0,
          'minHeight': 56.0,
        };
    }
  }
}
