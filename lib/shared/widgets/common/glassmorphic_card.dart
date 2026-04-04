import 'package:flutter/material.dart';

/// Glassmorphic card widget with consistent styling
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool isClickable;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.onTap,
    this.isClickable = false,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveBorderWidth = borderWidth ?? 1.0;
    final effectiveBoxShadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10.0,
        offset: const Offset(0, 4),
        spreadRadius: 0.0,
      ),
    ];

    Widget card = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        boxShadow: effectiveBoxShadow,
      ),
      child: child,
    );

    if (isClickable || onTap != null) {
      card = Material(
        type: MaterialType.button,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Glassmorphic list tile widget
class GlassmorphicListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool isThreeLine;
  final bool isDense;

  const GlassmorphicListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.isThreeLine = false,
    this.isDense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveContentPadding = contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    return GlassmorphicCard(
      onTap: onTap,
      backgroundColor: effectiveBackgroundColor,
      borderColor: effectiveBorderColor,
      borderRadius: effectiveBorderRadius,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: Padding(
          padding: effectiveContentPadding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      DefaultTextStyle.merge(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        child: title!,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic container for sections
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.white.withOpacity(0.05);
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveBorderWidth = borderWidth ?? 1.0;
    final effectiveBoxShadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 5.0,
        offset: const Offset(0, 2),
        spreadRadius: 0.0,
      ),
    ];

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        boxShadow: effectiveBoxShadow,
      ),
      child: child,
    );
  }
}

/// Glassmorphic header widget
class GlassmorphicHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const GlassmorphicHeader({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.white.withOpacity(0.1);
    final effectiveBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    final effectiveBorderRadius = borderRadius ?? 12.0;
    final effectiveHeight = height ?? kToolbarHeight;
    final effectiveBoxShadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10.0,
        offset: const Offset(0, 4),
        spreadRadius: 0.0,
      ),
    ];

    return Container(
      height: effectiveHeight,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.0,
        ),
        boxShadow: effectiveBoxShadow,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            GlassmorphicIconButton(
              icon: Icons.arrow_back,
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
            const SizedBox(width: 16),
          ],
          Expanded(child: child),
          if (actions != null) ...[
            const SizedBox(width: 16),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

/// Glassmorphic status indicator
class GlassmorphicStatusIndicator extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? textStyle;

  const GlassmorphicStatusIndicator({
    Key? key,
    required this.text,
    required this.color,
    this.icon,
    this.showIcon = true,
    this.padding,
    this.borderRadius,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? 20.0;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: textStyle ?? TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphic divider
class GlassmorphicDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;
  final EdgeInsetsGeometry? indent;
  final EdgeInsetsGeometry? endIndent;

  const GlassmorphicDivider({
    Key? key,
    this.height,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white.withOpacity(0.3);
    final effectiveThickness = thickness ?? 1.0;
    final effectiveHeight = height ?? 16.0;

    return Container(
      height: effectiveHeight,
      child: Row(
        children: [
          if (indent != null) ...[
            Expanded(flex: (indent as EdgeInsets).horizontal ~/ 16, child: const SizedBox()),
          ],
          Expanded(
            child: Container(
              height: effectiveThickness,
              color: effectiveColor,
            ),
          ),
          if (endIndent != null) ...[
            Expanded(flex: (endIndent as EdgeInsets).horizontal ~/ 16, child: const SizedBox()),
          ],
        ],
      ),
    );
  }
}
