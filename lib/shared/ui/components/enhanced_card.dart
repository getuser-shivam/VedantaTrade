import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class EnhancedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final bool elevated;
  final bool animated;
  final bool interactive;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration animationDuration;
  final Curve animationCurve;
  final BoxShadow? customShadow;
  final Gradient? gradient;
  final bool glassmorphic;
  final double? opacity;
  final String? semanticLabel;
  final bool enableFeedback;

  const EnhancedCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.elevated = true,
    this.animated = true,
    this.interactive = false,
    this.onTap,
    this.onLongPress,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.customShadow,
    this.gradient,
    this.glassmorphic = false,
    this.opacity,
    this.semanticLabel,
    this.enableFeedback = true,
  }) : super(key: key);

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.interactive ? 0.98 : 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevated ? 8.0 : 0.0,
      end: widget.elevated ? 12.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));

    if (widget.color != null) {
      _colorAnimation = ColorTween(
        begin: widget.color,
        end: widget.color?.withOpacity(0.8),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.interactive && widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    if (widget.interactive) {
      setState(() => _isHovered = true);
      _animationController.forward();
    }
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = widget.color ?? _getDefaultColor(isDark);
    final effectivePadding = widget.padding ?? AppSpacing.paddingCard;
    final effectiveMargin = widget.margin ?? AppSpacing.marginBetweenCards;
    final effectiveBorderRadius = widget.borderRadius ?? AppBorderRadius.radiusCard;

    return Container(
      margin: effectiveMargin,
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.opacity ?? 1.0,
              child: Semantics(
                label: widget.semanticLabel,
                button: widget.interactive,
                child: MouseRegion(
                  onEnter: _handleMouseEnter,
                  onExit: _handleMouseExit,
                  child: GestureDetector(
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    onLongPress: widget.onLongPress,
                    child: AnimatedContainer(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      padding: effectivePadding,
                      decoration: BoxDecoration(
                        color: widget.glassmorphic 
                            ? effectiveColor.withOpacity(0.1)
                            : (_colorAnimation.value ?? effectiveColor),
                        borderRadius: effectiveBorderRadius,
                        border: _getBorder(effectiveColor, isDark),
                        gradient: widget.gradient ?? _getGradient(effectiveColor),
                        boxShadow: _getBoxShadow(effectiveColor),
                      ),
                      child: ClipRRect(
                        borderRadius: effectiveBorderRadius,
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDefaultColor(bool isDark) {
    if (widget.glassmorphic) {
      return isDark ? AppColors.glassBackground : AppColors.glassBackground;
    }
    return isDark ? AppColors.darkCard : Colors.white;
  }

  Border? _getBorder(Color color, bool isDark) {
    if (widget.borderColor != null) {
      return Border.all(
        color: widget.borderColor!,
        width: widget.borderWidth ?? 1.0,
      );
    }

    if (widget.glassmorphic) {
      return Border.all(
        color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
        width: 1.0,
      );
    }

    return null;
  }

  Gradient? _getGradient(Color color) {
    if (widget.gradient != null) {
      return widget.gradient;
    }

    if (widget.glassmorphic) {
      return AppColors.glassGradient;
    }

    return null;
  }

  List<BoxShadow> _getBoxShadow(Color color) {
    if (widget.customShadow != null) {
      return [widget.customShadow!];
    }

    if (!widget.elevated) {
      return [];
    }

    final elevation = _elevationAnimation.value;
    final shadowColor = widget.glassmorphic 
        ? AppColors.glassShadow 
        : color.withOpacity(0.1);

    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
      if (_isHovered || _isPressed)
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: elevation * 3,
          offset: Offset(0, elevation),
        ),
    ];
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onTap;
  final bool animated;
  final double? width;
  final double? height;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.valueColor,
    this.subtitle,
    this.action,
    this.onTap,
    this.animated = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return EnhancedCard(
      width: width,
      height: height,
      animated: animated,
      interactive: onTap != null,
      onTap: onTap,
      color: backgroundColor ?? (isDark ? AppColors.darkCard : Colors.white),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: AppSizes.iconLG,
                ),
                if (action != null) ...[
                  const Spacer(),
                  action!,
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            title,
            style: isDark 
                ? AppTypography.darkLabelSmall
                : AppTypography.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: (isDark 
                    ? AppTypography.darkHeading4
                    : AppTypography.heading4)
                .copyWith(
                  color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: isDark 
                  ? AppTypography.darkCaption
                  : AppTypography.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final String? description;
  final IconData? icon;
  final Color? statusColor;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progressValue;

  const StatusCard({
    Key? key,
    required this.title,
    required this.status,
    this.description,
    this.icon,
    this.statusColor,
    this.backgroundColor,
    this.actions,
    this.onTap,
    this.showProgress = false,
    this.progressValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveStatusColor = statusColor ?? AppColors.getStatusColor(status);

    return EnhancedCard(
      interactive: onTap != null,
      onTap: onTap,
      color: backgroundColor ?? (isDark ? AppColors.darkCard : Colors.white),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: effectiveStatusColor,
                  size: AppSizes.iconMD,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: isDark 
                          ? AppTypography.darkBodyLarge
                          : AppTypography.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: effectiveStatusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            status,
                            style: isDark 
                                ? AppTypography.darkLabelSmall.copyWith(color: effectiveStatusColor)
                                : AppTypography.labelSmall.copyWith(color: effectiveStatusColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (actions != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ],
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              description!,
              style: isDark 
                  ? AppTypography.darkBodySmall
                  : AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (showProgress && progressValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: isDark ? AppColors.darkBorder : AppColors.textTertiary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(effectiveStatusColor),
            ),
          ],
        ],
      ),
    );
  }
}
