import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class EnhancedBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool showLabels;
  final NavigationType type;

  const EnhancedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.type = NavigationType.standard,
  }) : super(key: key);

  @override
  State<EnhancedBottomNavigationBar> createState() => _EnhancedBottomNavigationBarState();
}

class _EnhancedBottomNavigationBarState extends State<EnhancedBottomNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(controller))
        .toList();

    // Initialize animations
    for (int i = 0; i < widget.items.length; i++) {
      if (i == widget.currentIndex) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBgColor = widget.backgroundColor ?? 
        (isDark ? AppColors.darkSurface : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        boxShadow: widget.elevation != null && widget.elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: widget.elevation!,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: widget.showLabels ? AppSpacing.xs : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected && widget.type == NavigationType.pill
                  ? (widget.selectedItemColor ?? AppColors.primary).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: AppBorderRadius.radiusXL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                Transform.scale(
                  scale: 1.0 + (_animations[index].value * 0.2),
                  child: Icon(
                    item.icon,
                    size: widget.showLabels ? 24 : 28,
                    color: isSelected
                        ? (widget.selectedItemColor ?? AppColors.primary)
                        : (widget.unselectedItemColor ?? 
                           (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
                  ),
                ),
                if (widget.showLabels) ...[
                  const SizedBox(height: 4),
                  // Label with fade animation
                  Opacity(
                    opacity: _animations[index].value,
                    child: Text(
                      item.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? (widget.selectedItemColor ?? AppColors.primary)
                            : (widget.unselectedItemColor ?? 
                               (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                // Badge
                if (item.badge != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.badge!,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EnhancedAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final String? backButtonText;
  final bool animateTitle;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.flexibleSpace,
    this.bottom,
    this.onBackPressed,
    this.showBackButton = true,
    this.backButtonText,
    this.animateTitle = true,
  }) : super(key: key);

  @override
  State<EnhancedAppBar> createState() => _EnhancedAppBarState();
}

class _EnhancedAppBarState extends State<EnhancedAppBar>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    if (widget.animateTitle) {
      _titleController.forward();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
            (isDark ? AppColors.darkSurface : Colors.white),
        boxShadow: widget.elevation != null && widget.elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: widget.elevation!,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Leading widget
                  if (widget.leading != null)
                    widget.leading!
                  else if (widget.showBackButton && Navigator.canPop(context))
                    GestureDetector(
                      onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                      child: Container(
                        padding: AppSpacing.paddingAllSM,
                        decoration: BoxDecoration(
                          color: (widget.foregroundColor ?? 
                                 (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))
                              .withOpacity(0.1),
                          borderRadius: AppBorderRadius.radiusSM,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: widget.foregroundColor ?? 
                                 (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          size: 20,
                        ),
                      ),
                    )
                  else if (widget.automaticallyImplyLeading && Navigator.canPop(context))
                    GestureDetector(
                      onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                      child: Container(
                        padding: AppSpacing.paddingAllSM,
                        decoration: BoxDecoration(
                          color: (widget.foregroundColor ?? 
                                 (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))
                              .withOpacity(0.1),
                          borderRadius: AppBorderRadius.radiusSM,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: widget.foregroundColor ?? 
                                 (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          size: 20,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),

                  // Title
                  Expanded(
                    child: widget.animateTitle
                        ? AnimatedBuilder(
                            animation: _titleAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _titleAnimation.value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - _titleAnimation.value) * 10),
                                  child: Text(
                                    widget.title,
                                    style: (isDark ? AppTypography.darkHeading4 : AppTypography.heading4)
                                        .copyWith(
                                          color: widget.foregroundColor ?? 
                                                 (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                          fontWeight: FontWeight.w600,
                                        ),
                                    textAlign: widget.centerTitle ? TextAlign.center : TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          )
                        : Text(
                            widget.title,
                            style: (isDark ? AppTypography.darkHeading4 : AppTypography.heading4)
                                .copyWith(
                                  color: widget.foregroundColor ?? 
                                         (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: widget.centerTitle ? TextAlign.center : TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),

                  // Actions
                  if (widget.actions != null) ...widget.actions!,
                ],
              ),
            ),
            if (widget.bottom != null) widget.bottom!,
          ],
        ),
      ),
    );
  }
}

class SlideUpPanel extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final double? maxHeight;
  final bool isDraggable;
  final bool isCollapsible;
  final VoidCallback? onPanelOpened;
  final VoidCallback? onPanelClosed;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;

  const SlideUpPanel({
    Key? key,
    required this.child,
    this.minHeight = 100,
    this.maxHeight,
    this.isDraggable = true,
    this.isCollapsible = true,
    this.onPanelOpened,
    this.onPanelClosed,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<SlideUpPanel> createState() => _SlideUpPanelState();
}

class _SlideUpPanelState extends State<SlideUpPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;
  double _currentHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );
    _currentHeight = widget.minHeight;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        _currentHeight = widget.maxHeight ?? MediaQuery.of(context).size.height * 0.8;
        widget.onPanelOpened?.call();
      } else {
        _controller.reverse();
        _currentHeight = widget.minHeight;
        widget.onPanelClosed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveMaxHeight = widget.maxHeight ?? MediaQuery.of(context).size.height * 0.8;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPanelHeight = widget.minHeight + 
            (effectiveMaxHeight - widget.minHeight) * _animation.value;

        return GestureDetector(
          onVerticalDragUpdate: widget.isDraggable
              ? (details) {
                  final newHeight = _currentHeight - details.delta.dy;
                  if (newHeight >= widget.minHeight && newHeight <= effectiveMaxHeight) {
                    setState(() => _currentHeight = newHeight);
                  }
                }
              : null,
          onVerticalDragEnd: widget.isDraggable
              ? (details) {
                  if (details.velocity.pixelsPerSecond.dy > 500) {
                    // Swiped down
                    _controller.reverse();
                    setState(() {
                      _currentHeight = widget.minHeight;
                      _isExpanded = false;
                    });
                    widget.onPanelClosed?.call();
                  } else if (details.velocity.pixelsPerSecond.dy < -500) {
                    // Swiped up
                    _controller.forward();
                    setState(() {
                      _currentHeight = effectiveMaxHeight;
                      _isExpanded = true;
                    });
                    widget.onPanelOpened?.call();
                  } else {
                    // Snap to nearest position
                    final halfway = (effectiveMaxHeight + widget.minHeight) / 2;
                    if (_currentHeight > halfway) {
                      _controller.forward();
                      setState(() {
                        _currentHeight = effectiveMaxHeight;
                        _isExpanded = true;
                      });
                      widget.onPanelOpened?.call();
                    } else {
                      _controller.reverse();
                      setState(() {
                        _currentHeight = widget.minHeight;
                        _isExpanded = false;
                      });
                      widget.onPanelClosed?.call();
                    }
                  }
                }
              : null,
          child: Container(
            height: currentPanelHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? 
                  (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: widget.borderRadius ??
                  BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ??
                  BorderRadius.vertical(top: Radius.circular(20)),
              child: Column(
                children: [
                  // Handle bar
                  if (widget.isCollapsible)
                    Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.textTertiary,
                        borderRadius: AppBorderRadius.radiusRound,
                      ),
                    ),
                  // Content
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final String? badge;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.badge,
  });
}

enum NavigationType {
  standard,
  pill,
  floating,
}
