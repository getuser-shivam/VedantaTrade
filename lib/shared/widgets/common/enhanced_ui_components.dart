import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';

/// Enhanced UI Components for VedantaTrade
/// Modern, accessible, and responsive components

// Enhanced Button Component
class EnhancedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Color? customColor;
  final String? semanticLabel;

  const EnhancedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getButtonColors(theme);

    Widget child = _buildButtonContent(theme);

    if (type == ButtonType.elevated) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: _getHeight(),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
            elevation: 2,
            shadowColor: EnhancedTheme.buttonShadow.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: _getPadding(),
          ),
          child: child,
        ),
      );
    } else if (type == ButtonType.outlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: _getHeight(),
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.foreground,
            side: BorderSide(color: colors.background, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: _getPadding(),
          ),
          child: child,
        ),
      );
    } else {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: _getHeight(),
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: _getPadding(),
          ),
          child: child,
        ),
      );
    }
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getButtonColors(theme).foreground,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(theme),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(theme),
    );
  }

  ButtonColors _getButtonColors(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return ButtonColors(
          background: customColor ?? theme.colorScheme.primary,
          foreground: Colors.white,
        );
      case ButtonType.secondary:
        return ButtonColors(
          background: customColor ?? theme.colorScheme.secondary,
          foreground: Colors.white,
        );
      case ButtonType.success:
        return ButtonColors(
          background: EnhancedTheme.successGreen,
          foreground: Colors.white,
        );
      case ButtonType.warning:
        return ButtonColors(
          background: EnhancedTheme.warningAmber,
          foreground: Colors.white,
        );
      case ButtonType.error:
        return ButtonColors(
          background: EnhancedTheme.errorRed,
          foreground: Colors.white,
        );
      case ButtonType.outlined:
        return ButtonColors(
          background: customColor ?? theme.colorScheme.primary,
          foreground: customColor ?? theme.colorScheme.primary,
        );
      case ButtonType.text:
        return ButtonColors(
          background: Colors.transparent,
          foreground: customColor ?? theme.colorScheme.primary,
        );
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final fontSize = _getFontSize();
    final fontWeight = _getFontWeight();
    
    return theme.textTheme.labelLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
    ) ?? TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: _getButtonColors(theme).foreground,
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 12;
      case ButtonSize.medium:
        return 14;
      case ButtonSize.large:
        return 16;
    }
  }

  FontWeight _getFontWeight() {
    switch (size) {
      case ButtonSize.small:
        return FontWeight.w500;
      case ButtonSize.medium:
        return FontWeight.w600;
      case ButtonSize.large:
        return FontWeight.w600;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}

// Enhanced Card Component
class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool isClickable;
  final Widget? header;
  final Widget? footer;
  final bool showShadow;

  const EnhancedCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isClickable = false,
    this.header,
    this.footer,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;

    Widget cardChild = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        Flexible(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
        if (footer != null) footer!,
      ],
    );

    if (isClickable || onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: cardChild,
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: elevation ?? 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: cardChild,
    );
  }
}

// Enhanced Input Field Component
class EnhancedInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final FocusNode? focusNode;
  final AutovalidateMode autovalidateMode;
  final String? semanticLabel;
  final bool isRequired;

  const EnhancedInputField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.controller,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.focusNode,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.semanticLabel,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<EnhancedInputField> createState() => _EnhancedInputFieldState();
}

class _EnhancedInputFieldState extends State<EnhancedInputField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: widget.enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: EnhancedTheme.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          focusNode: _focusNode,
          autovalidateMode: widget.autovalidateMode,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            counterText: widget.showCounter && widget.maxLength != null
                ? '${widget.controller?.text.length ?? 0}/${widget.maxLength}'
                : null,
            filled: true,
            fillColor: widget.enabled
                ? theme.colorScheme.surfaceVariant
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Chip Component
class EnhancedChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final ChipSize size;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final Widget? avatar;
  final Color? customColor;

  const EnhancedChip({
    Key? key,
    required this.label,
    this.type = ChipType.primary,
    this.size = ChipSize.medium,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.avatar,
    this.customColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColors = _getChipColors(theme);
    final chipSize = _getChipSize();

    Widget chip = RawChip(
      label: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColors.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      avatar: avatar,
      deleteIcon: onDelete != null
          ? Icon(
              Icons.close,
              size: chipSize.iconSize,
              color: chipColors.deleteColor,
            )
          : null,
      onDeleted: onDelete,
      onPressed: onTap,
      selected: isSelected,
      backgroundColor: chipColors.backgroundColor,
      selectedColor: chipColors.selectedColor,
      side: BorderSide(
        color: chipColors.borderColor,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(chipSize.borderRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: chipSize.horizontalPadding,
        vertical: chipSize.verticalPadding,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: chipSize.labelHorizontalPadding,
        vertical: chipSize.labelVerticalPadding,
      ),
    );

    return chip;
  }

  ChipColors _getChipColors(ThemeData theme) {
    switch (type) {
      case ChipType.primary:
        return ChipColors(
          backgroundColor: theme.colorScheme.primaryContainer,
          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
          textColor: theme.colorScheme.onPrimaryContainer,
          borderColor: theme.colorScheme.primary,
          deleteColor: theme.colorScheme.onPrimaryContainer,
        );
      case ChipType.secondary:
        return ChipColors(
          backgroundColor: theme.colorScheme.secondaryContainer,
          selectedColor: theme.colorScheme.secondary.withOpacity(0.2),
          textColor: theme.colorScheme.onSecondaryContainer,
          borderColor: theme.colorScheme.secondary,
          deleteColor: theme.colorScheme.onSecondaryContainer,
        );
      case ChipType.success:
        return ChipColors(
          backgroundColor: EnhancedTheme.successGreen.withOpacity(0.1),
          selectedColor: EnhancedTheme.successGreen.withOpacity(0.2),
          textColor: EnhancedTheme.successGreen,
          borderColor: EnhancedTheme.successGreen,
          deleteColor: EnhancedTheme.successGreen,
        );
      case ChipType.warning:
        return ChipColors(
          backgroundColor: EnhancedTheme.warningAmber.withOpacity(0.1),
          selectedColor: EnhancedTheme.warningAmber.withOpacity(0.2),
          textColor: EnhancedTheme.warningAmber,
          borderColor: EnhancedTheme.warningAmber,
          deleteColor: EnhancedTheme.warningAmber,
        );
      case ChipType.error:
        return ChipColors(
          backgroundColor: EnhancedTheme.errorRed.withOpacity(0.1),
          selectedColor: EnhancedTheme.errorRed.withOpacity(0.2),
          textColor: EnhancedTheme.errorRed,
          borderColor: EnhancedTheme.errorRed,
          deleteColor: EnhancedTheme.errorRed,
        );
      case ChipType.outline:
        return ChipColors(
          backgroundColor: Colors.transparent,
          selectedColor: theme.colorScheme.primary.withOpacity(0.1),
          textColor: theme.colorScheme.primary,
          borderColor: theme.colorScheme.primary,
          deleteColor: theme.colorScheme.primary,
        );
    }
  }

  ChipSizeData _getChipSize() {
    switch (size) {
      case ChipSize.small:
        return ChipSizeData(
          borderRadius: 12,
          iconSize: 16,
          horizontalPadding: 8,
          verticalPadding: 4,
          labelHorizontalPadding: 4,
          labelVerticalPadding: 2,
        );
      case ChipSize.medium:
        return ChipSizeData(
          borderRadius: 16,
          iconSize: 18,
          horizontalPadding: 12,
          verticalPadding: 6,
          labelHorizontalPadding: 6,
          labelVerticalPadding: 3,
        );
      case ChipSize.large:
        return ChipSizeData(
          borderRadius: 20,
          iconSize: 20,
          horizontalPadding: 16,
          verticalPadding: 8,
          labelHorizontalPadding: 8,
          labelVerticalPadding: 4,
        );
    }
  }
}

// Enhanced Loading Component
class EnhancedLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double? size;

  const EnhancedLoading({
    Key? key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.colorScheme.primary;
    final loadingSize = size ?? 24;

    Widget loadingWidget;
    switch (type) {
      case LoadingType.circular:
        loadingWidget = CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          strokeWidth: 3,
        );
        break;
      case LoadingType.linear:
        loadingWidget = LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          backgroundColor: loadingColor.withOpacity(0.1),
        );
        break;
      case LoadingType.dots:
        loadingWidget = _DotsLoading(
          color: loadingColor,
          size: loadingSize,
        );
        break;
      case LoadingType.pulse:
        loadingWidget = _PulseLoading(
          color: loadingColor,
          size: loadingSize,
        );
        break;
    }

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingWidget;
  }
}

// Custom loading widgets
class _DotsLoading extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoading({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final animation = (_controller.value - delay) % 1.0;
            final scale = 0.5 + (animation * 0.5);
            final opacity = animation;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scale(scale),
            );
          },
        );
      }),
    );
  }
}

class _PulseLoading extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoading({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// Enums and helper classes
enum ButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

enum ChipType {
  primary,
  secondary,
  success,
  warning,
  error,
  outline,
}

enum ChipSize {
  small,
  medium,
  large,
}

enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}

class ButtonColors {
  final Color background;
  final Color foreground;

  const ButtonColors({
    required this.background,
    required this.foreground,
  });
}

class ChipColors {
  final Color backgroundColor;
  final Color selectedColor;
  final Color textColor;
  final Color borderColor;
  final Color deleteColor;

  const ChipColors({
    required this.backgroundColor,
    required this.selectedColor,
    required this.textColor,
    required this.borderColor,
    required this.deleteColor,
  });
}

class ChipSizeData {
  final double borderRadius;
  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double labelHorizontalPadding;
  final double labelVerticalPadding;

  const ChipSizeData({
    required this.borderRadius,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.labelHorizontalPadding,
    required this.labelVerticalPadding,
  });
}
