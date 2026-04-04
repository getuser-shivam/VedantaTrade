import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';

/// Enhanced UI Kit for VedantaTrade
/// Comprehensive collection of reusable UI components with glassmorphic design
class EnhancedUIKit {
  // Glassmorphic Container
  static Widget glassContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    double borderRadius = EnhancedTheme.radius16,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
    bool animate = true,
  }) {
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(EnhancedTheme.spacing16),
      decoration: EnhancedTheme.glassDecoration(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        boxShadow: boxShadow ?? EnhancedTheme.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      container = GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    if (animate) {
      container = _AnimatedGlassContainer(
        child: container,
      );
    }

    return container;
  }

  // Enhanced Button
  static Widget enhancedButton({
    required String text,
    required VoidCallback onPressed,
    ButtonType type = ButtonType.primary,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? icon,
    double? width,
    double? height,
  }) {
    return _EnhancedButton(
      text: text,
      onPressed: onPressed,
      type: type,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
      height: height,
    );
  }

  // Enhanced Card
  static Widget enhancedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    CardType type = CardType.glass,
    VoidCallback? onTap,
    Widget? header,
    Widget? footer,
    bool animate = true,
  }) {
    return _EnhancedCard(
      child: child,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      type: type,
      onTap: onTap,
      header: header,
      footer: footer,
      animate: animate,
    );
  }

  // Enhanced Input Field
  static Widget enhancedInput({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    String? errorText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconTap,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Function(String)? onSubmitted,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return _EnhancedInput(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixIconTap: onSuffixIconTap,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      maxLines: maxLines,
      validator: validator,
    );
  }

  // Enhanced Loading Indicator
  static Widget enhancedLoading({
    double? size,
    Color? color,
    String? message,
    LoadingType type = LoadingType.circular,
  }) {
    return _EnhancedLoading(
      size: size,
      color: color,
      message: message,
      type: type,
    );
  }

  // Enhanced Chip
  static Widget enhancedChip({
    required String label,
    ChipType type = ChipType.primary,
    VoidCallback? onTap,
    bool selected = false,
    Widget? avatar,
    IconData? icon,
    EdgeInsetsGeometry? padding,
  }) {
    return _EnhancedChip(
      label: label,
      type: type,
      onTap: onTap,
      selected: selected,
      avatar: avatar,
      icon: icon,
      padding: padding,
    );
  }

  // Enhanced Avatar
  static Widget enhancedAvatar({
    String? imageUrl,
    String? name,
    double size = 48,
    Color? backgroundColor,
    TextStyle? textStyle,
    VoidCallback? onTap,
    bool showBorder = true,
  }) {
    return _EnhancedAvatar(
      imageUrl: imageUrl,
      name: name,
      size: size,
      backgroundColor: backgroundColor,
      textStyle: textStyle,
      onTap: onTap,
      showBorder: showBorder,
    );
  }

  // Enhanced Badge
  static Widget enhancedBadge({
    required Widget child,
    required String count,
    BadgeType type = BadgeType.primary,
    bool showDot = false,
    EdgeInsetsGeometry? offset,
  }) {
    return _EnhancedBadge(
      child: child,
      count: count,
      type: type,
      showDot: showDot,
      offset: offset,
    );
  }

  // Enhanced Divider
  static Widget enhancedDivider({
    double height = 1,
    Color? color,
    double indent = 0,
    double endIndent = 0,
    DividerType type = DividerType.solid,
  }) {
    return _EnhancedDivider(
      height: height,
      color: color,
      indent: indent,
      endIndent: endIndent,
      type: type,
    );
  }

  // Enhanced Alert
  static Widget enhancedAlert({
    required String title,
    required String message,
    AlertType type = AlertType.info,
    List<Widget>? actions,
    bool showIcon = true,
    VoidCallback? onClose,
  }) {
    return _EnhancedAlert(
      title: title,
      message: message,
      type: type,
      actions: actions,
      showIcon: showIcon,
      onClose: onClose,
    );
  }

  // Enhanced Toast
  static void showEnhancedToast({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    _EnhancedToast.show(
      context: context,
      message: message,
      type: type,
      duration: duration,
      position: position,
    );
  }

  // Enhanced Bottom Sheet
  static Future<T?> showEnhancedBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool isScrollControlled = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedBottomSheet(
        title: title,
        actions: actions,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  // Enhanced Dialog
  static Future<T?> showEnhancedDialog<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _EnhancedDialog(
        title: title,
        actions: actions,
        child: child,
      ),
    );
  }
}

// Button Types
enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

// Card Types
enum CardType {
  glass,
  elevated,
  outlined,
  gradient,
}

// Loading Types
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}

// Chip Types
enum ChipType {
  primary,
  secondary,
  outline,
  filter,
}

// Badge Types
enum BadgeType {
  primary,
  secondary,
  success,
  warning,
  danger,
}

// Divider Types
enum DividerType {
  solid,
  dashed,
  dotted,
}

// Alert Types
enum AlertType {
  info,
  success,
  warning,
  error,
}

// Toast Types
enum ToastType {
  info,
  success,
  warning,
  error,
}

// Toast Positions
enum ToastPosition {
  top,
  center,
  bottom,
}

// Animated Glass Container
class _AnimatedGlassContainer extends StatefulWidget {
  final Widget child;

  const _AnimatedGlassContainer({required this.child});

  @override
  State<_AnimatedGlassContainer> createState() => _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<_AnimatedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedTheme.durationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Enhanced Button Implementation
class _EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? width;
  final double? height;

  const _EnhancedButton({
    required this.text,
    required this.onPressed,
    required this.type,
    required this.size,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<_EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<_EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedTheme.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || widget.isLoading;
    final buttonStyle = _getButtonStyle();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? _getHeight(),
            child: ElevatedButton(
              onPressed: isDisabled ? null : _handlePressed,
              style: buttonStyle,
              child: widget.isLoading
                  ? _buildLoadingContent()
                  : _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (widget.type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: EnhancedTheme.primaryColor,
          foregroundColor: EnhancedTheme.textPrimary,
          elevation: EnhancedTheme.elevation4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          ),
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: EnhancedTheme.secondaryColor,
          foregroundColor: EnhancedTheme.textPrimary,
          elevation: EnhancedTheme.elevation4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          ),
        );
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: EnhancedTheme.primaryColor,
          side: const BorderSide(color: EnhancedTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          ),
        );
      case ButtonType.ghost:
        return TextButton.styleFrom(
          foregroundColor: EnhancedTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          ),
        );
      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: EnhancedTheme.errorColor,
          foregroundColor: EnhancedTheme.textPrimary,
          elevation: EnhancedTheme.elevation4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          ),
        );
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  Widget _buildButtonContent() {
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: EnhancedTheme.spacing8),
          Text(widget.text),
        ],
      );
    }
    return Text(widget.text);
  }

  Widget _buildLoadingContent() {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          EnhancedTheme.textPrimary,
        ),
      ),
    );
  }

  void _handlePressed() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed();
  }
}

// Enhanced Card Implementation
class _EnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final CardType type;
  final VoidCallback? onTap;
  final Widget? header;
  final Widget? footer;
  final bool animate;

  const _EnhancedCard({
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    required this.type,
    this.onTap,
    this.header,
    this.footer,
    this.animate = true,
  });

  @override
  State<_EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<_EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedTheme.durationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardDecoration = _getCardDecoration();

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) widget.header!,
          if (widget.header != null) const SizedBox(height: EnhancedTheme.spacing12),
          Flexible(
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(EnhancedTheme.spacing16),
              child: widget.child,
            ),
          ),
          if (widget.footer != null) const SizedBox(height: EnhancedTheme.spacing12),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    if (widget.animate) {
      card = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _getCardDecoration() {
    switch (widget.type) {
      case CardType.glass:
        return EnhancedTheme.glassDecoration(
          boxShadow: EnhancedTheme.softShadow,
        );
      case CardType.elevated:
        return BoxDecoration(
          color: EnhancedTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(EnhancedTheme.radius16),
          boxShadow: EnhancedTheme.mediumShadow,
        );
      case CardType.outlined:
        return BoxDecoration(
          color: EnhancedTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(EnhancedTheme.radius16),
          border: Border.all(color: EnhancedTheme.glassBorder),
        );
      case CardType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: EnhancedTheme.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedTheme.radius16),
          boxShadow: EnhancedTheme.mediumShadow,
        );
    }
  }
}

// Placeholder implementations for other components
class _EnhancedInput extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final int maxLines;
  final String? Function(String?)? validator;

  const _EnhancedInput({
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedUIKit.glassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixIconTap,
                  child: Icon(suffixIcon),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(EnhancedTheme.spacing12),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        enabled: enabled,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}

class _EnhancedLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? message;
  final LoadingType type;

  const _EnhancedLoading({
    this.size,
    this.color,
    this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size ?? 24,
          height: size ?? 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? EnhancedTheme.primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: EnhancedTheme.spacing8),
          Text(
            message!,
            style: EnhancedTheme.bodySmall.copyWith(
              color: EnhancedTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _EnhancedChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final VoidCallback? onTap;
  final bool selected;
  final Widget? avatar;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const _EnhancedChip({
    required this.label,
    required this.type,
    this.onTap,
    this.selected = false,
    this.avatar,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: EnhancedTheme.spacing12,
          vertical: EnhancedTheme.spacing6,
        ),
        decoration: BoxDecoration(
          color: _getChipColor(),
          borderRadius: BorderRadius.circular(EnhancedTheme.radius20),
          border: Border.all(color: _getChipBorderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) avatar!,
            if (icon != null) Icon(icon, size: 16),
            if (avatar != null || icon != null)
              const SizedBox(width: EnhancedTheme.spacing4),
            Text(
              label,
              style: EnhancedTheme.bodySmall.copyWith(
                color: _getChipTextColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getChipColor() {
    switch (type) {
      case ChipType.primary:
        return selected ? EnhancedTheme.primaryColor : EnhancedTheme.glassBackground;
      case ChipType.secondary:
        return selected ? EnhancedTheme.secondaryColor : EnhancedTheme.glassBackground;
      case ChipType.outline:
        return Colors.transparent;
      case ChipType.filter:
        return selected ? EnhancedTheme.accentColor : EnhancedTheme.glassBackground;
    }
  }

  Color _getChipBorderColor() {
    switch (type) {
      case ChipType.primary:
        return EnhancedTheme.primaryColor;
      case ChipType.secondary:
        return EnhancedTheme.secondaryColor;
      case ChipType.outline:
        return EnhancedTheme.glassBorder;
      case ChipType.filter:
        return EnhancedTheme.accentColor;
    }
  }

  Color _getChipTextColor() {
    switch (type) {
      case ChipType.primary:
        return selected ? EnhancedTheme.textPrimary : EnhancedTheme.primaryColor;
      case ChipType.secondary:
        return selected ? EnhancedTheme.textPrimary : EnhancedTheme.secondaryColor;
      case ChipType.outline:
        return EnhancedTheme.textPrimary;
      case ChipType.filter:
        return selected ? EnhancedTheme.textPrimary : EnhancedTheme.accentColor;
    }
  }
}

class _EnhancedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final bool showBorder;

  const _EnhancedAvatar({
    this.imageUrl,
    this.name,
    this.size = 48,
    this.backgroundColor,
    this.textStyle,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? EnhancedTheme.primaryColor,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && name != null
          ? Text(
              _getInitials(),
              style: textStyle ?? EnhancedTheme.bodyLarge.copyWith(
                color: EnhancedTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: EnhancedTheme.glassBorder,
            width: 2,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '';
    final parts = name!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name!.substring(0, 1).toUpperCase();
  }
}

class _EnhancedBadge extends StatelessWidget {
  final Widget child;
  final String count;
  final BadgeType type;
  final bool showDot;
  final EdgeInsetsGeometry? offset;

  const _EnhancedBadge({
    required this.child,
    required this.count,
    required this.type,
    this.showDot = false,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: offset?.resolve(const Offset(0, 0)).dy ?? -8,
          right: offset?.resolve(const Offset(0, 0)).dx ?? -8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: EnhancedTheme.spacing4,
              vertical: EnhancedTheme.spacing2,
            ),
            decoration: BoxDecoration(
              color: _getBadgeColor(),
              borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
              border: Border.all(
                color: EnhancedTheme.surfaceColor,
                width: 1.5,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: showDot
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(),
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
                    count,
                    style: EnhancedTheme.caption.copyWith(
                      color: EnhancedTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ],
    );
  }

  Color _getBadgeColor() {
    switch (type) {
      case BadgeType.primary:
        return EnhancedTheme.primaryColor;
      case BadgeType.secondary:
        return EnhancedTheme.secondaryColor;
      case BadgeType.success:
        return EnhancedTheme.successColor;
      case BadgeType.warning:
        return EnhancedTheme.warningColor;
      case BadgeType.danger:
        return EnhancedTheme.errorColor;
    }
  }
}

class _EnhancedDivider extends StatelessWidget {
  final double height;
  final Color? color;
  final double indent;
  final double endIndent;
  final DividerType type;

  const _EnhancedDivider({
    this.height = 1,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DividerType.solid:
        return Divider(
          height: height,
          color: color ?? EnhancedTheme.glassBorder,
          indent: indent,
          endIndent: endIndent,
        );
      case DividerType.dashed:
        return Container(
          height: height,
          margin: EdgeInsets.only(left: indent, right: endIndent),
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: color ?? EnhancedTheme.glassBorder,
            ),
          ),
        );
      case DividerType.dotted:
        return Container(
          height: height,
          margin: EdgeInsets.only(left: indent, right: endIndent),
          child: CustomPaint(
            painter: _DottedLinePainter(
              color: color ?? EnhancedTheme.glassBorder,
            ),
          ),
        );
    }
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const dotSpace = 6.0;
    double startX = dotRadius;

    while (startX < size.width) {
      canvas.drawCircle(
        Offset(startX, size.height / 2),
        dotRadius,
        paint,
      );
      startX += dotRadius * 2 + dotSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnhancedAlert extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final List<Widget>? actions;
  final bool showIcon;
  final VoidCallback? onClose;

  const _EnhancedAlert({
    required this.title,
    required this.message,
    required this.type,
    this.actions,
    this.showIcon = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedUIKit.glassContainer(
      padding: const EdgeInsets.all(EnhancedTheme.spacing20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showIcon) ...[
                Icon(
                  _getAlertIcon(),
                  color: _getAlertColor(),
                  size: 24,
                ),
                const SizedBox(width: EnhancedTheme.spacing12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: EnhancedTheme.heading5.copyWith(
                    color: _getAlertColor(),
                  ),
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    color: EnhancedTheme.textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: EnhancedTheme.spacing12),
          Text(
            message,
            style: EnhancedTheme.bodyMedium.copyWith(
              color: EnhancedTheme.textSecondary,
            ),
          ),
          if (actions != null) ...[
            const SizedBox(height: EnhancedTheme.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAlertIcon() {
    switch (type) {
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
        return Icons.warning_outline;
      case AlertType.error:
        return Icons.error_outline;
    }
  }

  Color _getAlertColor() {
    switch (type) {
      case AlertType.info:
        return EnhancedTheme.secondaryColor;
      case AlertType.success:
        return EnhancedTheme.successColor;
      case AlertType.warning:
        return EnhancedTheme.warningColor;
      case AlertType.error:
        return EnhancedTheme.errorColor;
    }
  }
}

class _EnhancedToast {
  static void show({
    required BuildContext context,
    required String message,
    required ToastType type,
    required Duration duration,
    required ToastPosition position,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedTheme.durationNormal,
      vsync: this,
    );

    final begin = _getBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveEaseInOut,
    ));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 50 : null,
      bottom: widget.position == ToastPosition.bottom ? 50 : null,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: EnhancedUIKit.glassContainer(
            padding: const EdgeInsets.all(EnhancedTheme.spacing16),
            child: Row(
              children: [
                Icon(
                  _getToastIcon(),
                  color: _getToastColor(),
                  size: 20,
                ),
                const SizedBox(width: EnhancedTheme.spacing12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: EnhancedTheme.bodyMedium.copyWith(
                      color: EnhancedTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _getBeginOffset() {
    switch (widget.position) {
      case ToastPosition.top:
        return const Offset(0, -1);
      case ToastPosition.center:
        return const Offset(0, 0);
      case ToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  IconData _getToastIcon() {
    switch (widget.type) {
      case ToastType.info:
        return Icons.info_outline;
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.warning:
        return Icons.warning_outline;
      case ToastType.error:
        return Icons.error_outline;
    }
  }

  Color _getToastColor() {
    switch (widget.type) {
      case ToastType.info:
        return EnhancedTheme.secondaryColor;
      case ToastType.success:
        return EnhancedTheme.successColor;
      case ToastType.warning:
        return EnhancedTheme.warningColor;
      case ToastType.error:
        return EnhancedTheme.errorColor;
    }
  }
}

class _EnhancedBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final double? maxHeight;
  final Widget child;

  const _EnhancedBottomSheet({
    this.title,
    this.actions,
    this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: EnhancedTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(EnhancedTheme.radius24),
          topRight: Radius.circular(EnhancedTheme.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(EnhancedTheme.spacing20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: EnhancedTheme.heading4,
                    ),
                  ),
                  if (actions != null) ...actions,
                ],
              ),
            ),
            EnhancedUIKit.enhancedDivider(),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EnhancedTheme.spacing20),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedDialog extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget child;

  const _EnhancedDialog({
    this.title,
    this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: EnhancedUIKit.glassContainer(
        padding: const EdgeInsets.all(EnhancedTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: EnhancedTheme.heading4,
              ),
              const SizedBox(height: EnhancedTheme.spacing16),
            ],
            child,
            if (actions != null) ...[
              const SizedBox(height: EnhancedTheme.spacing20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
