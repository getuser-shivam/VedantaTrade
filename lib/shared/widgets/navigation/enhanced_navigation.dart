import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';
import '../animations/enhanced_animations.dart';
import '../responsive/responsive_layout.dart';

/// Enhanced Navigation System for VedantaTrade
/// Provides intuitive, accessible, and responsive navigation

class EnhancedNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;
  final NavigationType type;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;
  final bool showBadges;
  final Map<int, int> badgeCounts;
  final double? elevation;
  final EdgeInsets? padding;

  const EnhancedNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.type = NavigationType.bottom,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
    this.showBadges = false,
    this.badgeCounts = const {},
    this.elevation,
    this.padding,
  }) : super(key: key);

  @override
  State<EnhancedNavigation> createState() => _EnhancedNavigationState();
}

class _EnhancedNavigationState extends State<EnhancedNavigation> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case NavigationType.bottom:
        return _buildBottomNavigation(context);
      case NavigationType.rail:
        return _buildNavigationRail(context);
      case NavigationType.drawer:
        return _buildNavigationDrawer(context);
      case NavigationType.tabs:
        return _buildTabBar(context);
    }
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;
              
              return Expanded(
                child: _AnimatedNavigationItem(
                  isSelected: isSelected,
                  onTap: () => widget.onTap(index),
                  item: item,
                  showLabel: widget.showLabels,
                  badgeCount: widget.showBadges ? widget.badgeCounts[index] : null,
                  selectedItemColor: widget.selectedItemColor,
                  unselectedItemColor: widget.unselectedItemColor,
                  isBottom: true,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(2, 0),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _AnimatedNavigationItem(
                  isSelected: isSelected,
                  onTap: () => widget.onTap(index),
                  item: item,
                  showLabel: widget.showLabels,
                  badgeCount: widget.showBadges ? widget.badgeCounts[index] : null,
                  selectedItemColor: widget.selectedItemColor,
                  unselectedItemColor: widget.unselectedItemColor,
                  isBottom: false,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'VedantaTrade',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: widget.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = widget.currentIndex == index;
                  
                  return _AnimatedNavigationItem(
                    isSelected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onTap(index);
                    },
                    item: item,
                    showLabel: widget.showLabels,
                    badgeCount: widget.showBadges ? widget.badgeCounts[index] : null,
                    selectedItemColor: widget.selectedItemColor,
                    unselectedItemColor: widget.unselectedItemColor,
                    isBottom: false,
                    isDrawer: true,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = widget.currentIndex == index;
              
              return _AnimatedNavigationItem(
                isSelected: isSelected,
                onTap: () => widget.onTap(index),
                item: item,
                showLabel: widget.showLabels,
                badgeCount: widget.showBadges ? widget.badgeCounts[index] : null,
                selectedItemColor: widget.selectedItemColor,
                unselectedItemColor: widget.unselectedItemColor,
                isBottom: false,
                isTab: true,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavigationItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final NavigationItem item;
  final bool showLabel;
  final int? badgeCount;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool isBottom;
  final bool isDrawer;
  final bool isTab;

  const _AnimatedNavigationItem({
    required this.isSelected,
    required this.onTap,
    required this.item,
    required this.showLabel,
    this.badgeCount,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.isBottom = false,
    this.isDrawer = false,
    this.isTab = false,
  });

  @override
  State<_AnimatedNavigationItem> createState() => _AnimatedNavigationItemState();
}

class _AnimatedNavigationItemState extends State<_AnimatedNavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedAnimations.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedColor = widget.unselectedItemColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    
    Color itemColor = widget.isSelected ? selectedColor : unselectedColor;
    
    Widget iconWidget = Icon(
      widget.isSelected ? widget.selectedIcon ?? widget.item.icon : widget.item.icon,
      size: widget.isDrawer ? 24 : 22,
      color: itemColor,
    );

    if (widget.badgeCount != null && widget.badgeCount! > 0) {
      iconWidget = Stack(
        children: [
          iconWidget,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                widget.badgeCount! > 99 ? '99+' : widget.badgeCount.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    Widget content;
    EdgeInsetsGeometry padding;
    CrossAxisAlignment alignment;

    if (widget.isDrawer) {
      padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      alignment = CrossAxisAlignment.start;
      content = Row(
        children: [
          iconWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.item.label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: itemColor,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    } else if (widget.isTab) {
      padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      alignment = CrossAxisAlignment.center;
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              widget.item.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: itemColor,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ],
      );
    } else {
      padding = const EdgeInsets.symmetric(vertical: 8);
      alignment = CrossAxisAlignment.center;
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (widget.showLabel) ...[
            const SizedBox(height: 4),
            Text(
              widget.item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: itemColor,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: widget.isSelected && !widget.isBottom && !widget.isDrawer
                    ? selectedColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget? get selectedIcon => widget.item.selectedIcon;
}

class EnhancedAppBar extends StatefulWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final List<Widget>? actionsOverflow;

  const EnhancedAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
    this.actionsOverflow,
  }) : super(key: key);

  @override
  State<EnhancedAppBar> createState() => _EnhancedAppBarState();
}

class _EnhancedAppBarState extends State<EnhancedAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveBuilder(
      builder: (context, screenType) {
        return AppBar(
          title: ResponsiveBuilder(
            builder: (context, screenType) {
              return Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: widget.foregroundColor,
                  fontSize: screenType == ScreenType.mobile ? 20 : 24,
                ),
              );
            },
          ),
          centerTitle: widget.centerTitle || screenType == ScreenType.mobile,
          actions: _buildActions(context, screenType),
          leading: widget.leading ?? _buildLeading(context, screenType),
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          flexibleSpace: widget.flexibleSpace,
          bottom: widget.bottom,
          elevation: widget.elevation ?? (screenType == ScreenType.mobile ? 2 : 4),
          backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
          foregroundColor: widget.foregroundColor ?? theme.colorScheme.onSurface,
          titleSpacing: screenType == ScreenType.mobile ? 0 : 24,
        );
      },
    );
  }

  Widget? _buildLeading(BuildContext context, ScreenType screenType) {
    if (widget.showBackButton && widget.automaticallyImplyLeading) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
      );
    }
    return widget.leading;
  }

  List<Widget>? _buildActions(BuildContext context, ScreenType screenType) {
    final allActions = [...?widget.actions, ...?widget.actionsOverflow];
    
    if (screenType == ScreenType.mobile) {
      // Show only first 2 actions on mobile
      return allActions.take(2).toList();
    } else {
      // Show all actions on larger screens
      return allActions;
    }
  }
}

class EnhancedBottomSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool isScrollControlled;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onDismiss;
  final bool showDragHandle;
  final String? title;

  const EnhancedBottomSheet({
    Key? key,
    required this.child,
    this.height,
    this.isScrollControlled = true,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.onDismiss,
    this.showDragHandle = true,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle) ...[
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        Flexible(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ],
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: content,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double? height,
    bool isScrollControlled = true,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onDismiss,
    bool showDragHandle = true,
    String? title,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      builder: (context) => EnhancedBottomSheet(
        height: height,
        isScrollControlled: isScrollControlled,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        onDismiss: onDismiss,
        showDragHandle: showDragHandle,
        title: title,
        child: Builder(builder: builder),
      ),
    );
  }
}

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? separatorColor;
  final Widget? separator;
  final TextStyle? textStyle;
  final VoidCallback? onItemTap;

  const BreadcrumbNavigation({
    Key? key,
    required this.items,
    this.separatorColor,
    this.separator,
    this.textStyle,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _buildBreadcrumbItems(theme),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(ThemeData theme) {
    final List<Widget> items = [];
    
    for (int i = 0; i < this.items.length; i++) {
      final item = this.items[i];
      final isLast = i == this.items.length - 1;
      
      items.add(
        GestureDetector(
          onTap: item.onTap ?? onItemTap,
          child: _buildBreadcrumbItem(item, isLast, theme),
        ),
      );
      
      if (!isLast) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: separator ?? Icon(
              Icons.chevron_right,
              size: 16,
              color: separatorColor ?? theme.colorScheme.outline,
            ),
          ),
        );
      }
    }
    
    return items;
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, bool isLast, ThemeData theme) {
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isLast
          ? theme.colorScheme.onSurface
          : theme.colorScheme.primary,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          item.icon!,
          const SizedBox(width: 8),
        ],
        Text(
          item.label,
          style: textStyle ?? defaultStyle,
        ),
      ],
    );
  }
}

// Navigation Models
class NavigationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? tooltip;
  final bool requiresAuth;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.requiresAuth = false,
  });
}

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}

// Navigation Enums
enum NavigationType {
  bottom,
  rail,
  drawer,
  tabs,
}

// Navigation Extensions
extension NavigationExtensions on BuildContext {
  Future<T?> navigateTo<T>({
    required Widget page,
    String? routeName,
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
  }) {
    if (clearStack) {
      return Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName, arguments: arguments),
        ),
        (route) => false,
      );
    } else if (replace) {
      return Navigator.of(this).pushReplacement(
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName, arguments: arguments),
        ),
      );
    } else {
      return Navigator.of(this).push(
        MaterialPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName, arguments: arguments),
        ),
      );
    }
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  bool canPop() {
    return Navigator.of(this).canPop();
  }
}
