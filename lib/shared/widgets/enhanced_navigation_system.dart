import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/enhanced_theme.dart';
import 'enhanced_ui_kit.dart';

/// Enhanced Navigation System for VedantaTrade
/// Provides seamless navigation with glassmorphic design and smooth transitions
class EnhancedNavigationSystem {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation with enhanced transitions
  static Future<T?> navigateTo<T>({
    required BuildContext context,
    required String route,
    Object? arguments,
    NavigationType type = NavigationType.slide,
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      _buildRoute(
        route: route,
        arguments: arguments,
        type: type,
        duration: duration,
      ),
    );
  }

  // Replace current screen
  static Future<T?> replaceTo<T>({
    required BuildContext context,
    required String route,
    Object? arguments,
    NavigationType type = NavigationType.slide,
  }) {
    return Navigator.of(context).pushReplacement<T>(
      _buildRoute(
        route: route,
        arguments: arguments,
        type: type,
      ),
    );
  }

  // Navigate and clear stack
  static Future<T?> navigateAndClearTo<T>({
    required BuildContext context,
    required String route,
    Object? arguments,
    NavigationType type = NavigationType.slide,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _buildRoute(
        route: route,
        arguments: arguments,
        type: type,
      ),
      (route) => false,
    );
  }

  // Go back
  static void goBack<T>({T? result}) {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  // Show bottom sheet navigation
  static Future<T?> showBottomNav<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnhancedBottomSheet(
        title: title,
        actions: actions,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  // Show dialog navigation
  static Future<T?> showDialogNav<T>({
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

  // Build enhanced route
  static PageRoute<T> _buildRoute<T>({
    required String route,
    Object? arguments,
    required NavigationType type,
    Duration? duration,
  }) {
    switch (type) {
      case NavigationType.slide:
        return SlideRightPageRoute<T>(
          builder: (context) => _getScreenWidget(route),
          settings: RouteSettings(arguments: arguments),
          duration: duration ?? EnhancedTheme.durationNormal,
        );
      case NavigationType.fade:
        return FadePageRoute<T>(
          builder: (context) => _getScreenWidget(route),
          settings: RouteSettings(arguments: arguments),
          duration: duration ?? EnhancedTheme.durationNormal,
        );
      case NavigationType.scale:
        return ScalePageRoute<T>(
          builder: (context) => _getScreenWidget(route),
          settings: RouteSettings(arguments: arguments),
          duration: duration ?? EnhancedTheme.durationNormal,
        );
      case NavigationType.cupertino:
        return CupertinoPageRoute<T>(
          builder: (context) => _getScreenWidget(route),
          settings: RouteSettings(arguments: arguments),
        );
      case NavigationType.none:
        return MaterialPageRoute<T>(
          builder: (context) => _getScreenWidget(route),
          settings: RouteSettings(arguments: arguments),
        );
    }
  }

  // Get screen widget based on route (placeholder implementation)
  static Widget _getScreenWidget(String route) {
    // This would typically use a route generator or dependency injection
    return Container(
      child: Center(
        child: Text('Route: $route'),
      ),
    );
  }
}

// Navigation Types
enum NavigationType {
  slide,
  fade,
  scale,
  cupertino,
  none,
}

// Custom Page Route Implementations
class SlideRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideRightPageRoute({
    required this.child,
    required this.duration,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    required this.duration,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    required this.duration,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
      )),
      child: child,
    );
  }
}

// Enhanced Bottom Navigation Bar
class EnhancedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<EnhancedBottomNavItem> items;
  final Color? backgroundColor;
  final double? elevation;

  const EnhancedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  State<EnhancedBottomNav> createState() => _EnhancedBottomNavState();
}

class _EnhancedBottomNavState extends State<EnhancedBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: EnhancedTheme.durationNormal,
        vsync: this,
      ),
    );
    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: EnhancedTheme.curveEaseInOut,
              ),
            ))
        .toList();

    // Animate selected item
    _controllers[widget.currentIndex].forward();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(EnhancedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedUIKit.glassContainer(
      margin: const EdgeInsets.all(EnhancedTheme.spacing16),
      padding: const EdgeInsets.symmetric(
        horizontal: EnhancedTheme.spacing20,
        vertical: EnhancedTheme.spacing12,
      ),
      borderRadius: EnhancedTheme.radius24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;

          return _buildNavItem(item, index, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(EnhancedBottomNavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedBuilder(
        animation: _animations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 1.1 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: EnhancedTheme.spacing12,
                vertical: EnhancedTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? EnhancedTheme.primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected
                        ? EnhancedTheme.primaryColor
                        : EnhancedTheme.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: EnhancedTheme.spacing4),
                  Text(
                    item.label,
                    style: EnhancedTheme.bodySmall.copyWith(
                      color: isSelected
                          ? EnhancedTheme.primaryColor
                          : EnhancedTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Bottom Navigation Item
class EnhancedBottomNavItem {
  final IconData icon;
  final String label;
  final String? badgeCount;
  final bool showBadge;

  EnhancedBottomNavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
    this.showBadge = false,
  });
}

// Enhanced App Bar
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final TextStyle? titleStyle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const EnhancedAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = true,
    this.titleStyle,
    this.flexibleSpace,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: titleStyle ?? EnhancedTheme.heading4,
            )
          : null,
      centerTitle: centerTitle,
      actions: actions,
      leading: leading ?? (showBackButton ? _buildBackButton() : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: onBackPressed ?? () => EnhancedNavigationSystem.goBack(),
      child: Container(
        margin: const EdgeInsets.all(EnhancedTheme.spacing8),
        padding: const EdgeInsets.all(EnhancedTheme.spacing8),
        decoration: BoxDecoration(
          color: EnhancedTheme.glassBackground,
          borderRadius: BorderRadius.circular(EnhancedTheme.radius8),
          border: Border.all(color: EnhancedTheme.glassBorder),
        ),
        child: Icon(
          Icons.arrow_back,
          color: EnhancedTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

// Enhanced Navigation Rail
class EnhancedNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<EnhancedNavigationRailDestination> destinations;
  final bool extended;
  final double? width;
  final Color? backgroundColor;

  const EnhancedNavigationRail({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.width,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? (extended ? 200 : 80),
      decoration: BoxDecoration(
        color: backgroundColor ?? EnhancedTheme.glassBackground,
        border: Border(
          right: BorderSide(color: EnhancedTheme.glassBorder),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: EnhancedTheme.spacing16,
              ),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final destination = destinations[index];
                final isSelected = index == selectedIndex;

                return _buildRailDestination(destination, index, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRailDestination(
    EnhancedNavigationRailDestination destination,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onDestinationSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: EnhancedTheme.spacing8,
          vertical: EnhancedTheme.spacing4,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: extended ? EnhancedTheme.spacing16 : EnhancedTheme.spacing8,
          vertical: EnhancedTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? EnhancedTheme.primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
          border: isSelected
              ? Border.all(color: EnhancedTheme.primaryColor)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              destination.icon,
              color: isSelected
                  ? EnhancedTheme.primaryColor
                  : EnhancedTheme.textSecondary,
              size: 24,
            ),
            if (extended) ...[
              const SizedBox(width: EnhancedTheme.spacing12),
              Expanded(
                child: Text(
                  destination.label,
                  style: EnhancedTheme.bodyMedium.copyWith(
                    color: isSelected
                        ? EnhancedTheme.primaryColor
                        : EnhancedTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Enhanced Navigation Rail Destination
class EnhancedNavigationRailDestination {
  final IconData icon;
  final String label;
  final String? badgeCount;

  EnhancedNavigationRailDestination({
    required this.icon,
    required this.label,
    this.badgeCount,
  });
}

// Enhanced Tab Bar
class EnhancedTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? textStyle;
  final bool showIndicator;
  final double? height;

  const EnhancedTabBar({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.textStyle,
    this.showIndicator = true,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnhancedUIKit.glassContainer(
      height: height ?? 48,
      padding: const EdgeInsets.symmetric(
        horizontal: EnhancedTheme.spacing8,
        vertical: EnhancedTheme.spacing4,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: _buildTab(tab, index, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTab(String tab, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnhancedTheme.spacing12,
          vertical: EnhancedTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? EnhancedTheme.primaryColor).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(EnhancedTheme.radius8),
          border: isSelected && showIndicator
              ? Border(
                  bottom: BorderSide(
                    color: selectedColor ?? EnhancedTheme.primaryColor,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          tab,
          style: textStyle ?? EnhancedTheme.bodyMedium.copyWith(
            color: isSelected
                ? (selectedColor ?? EnhancedTheme.primaryColor)
                : (unselectedColor ?? EnhancedTheme.textSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Enhanced Floating Action Button
class EnhancedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;
  final bool extended;
  final String? label;
  final bool showBadge;
  final String? badgeCount;

  const EnhancedFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.extended = false,
    this.label,
    this.showBadge = false,
    this.badgeCount,
  }) : super(key: key);

  @override
  State<EnhancedFAB> createState() => _EnhancedFABState();
}

class _EnhancedFABState extends State<EnhancedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EnhancedTheme.durationNormal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedTheme.curveElasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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
    Widget fab = Container(
      width: widget.size ?? 56,
      height: widget.size ?? 56,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? EnhancedTheme.primaryColor,
        borderRadius: BorderRadius.circular(widget.size ?? 56 / 2),
        boxShadow: EnhancedTheme.mediumShadow,
      ),
      child: Stack(
        children: [
          Center(
            child: widget.extended && widget.label != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnhancedTheme.spacing16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.foregroundColor ?? EnhancedTheme.textPrimary,
                          size: 24,
                        ),
                        const SizedBox(width: EnhancedTheme.spacing8),
                        Text(
                          widget.label!,
                          style: EnhancedTheme.buttonText.copyWith(
                            color: widget.foregroundColor ?? EnhancedTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: widget.foregroundColor ?? EnhancedTheme.textPrimary,
                    size: 24,
                  ),
          ),
          if (widget.showBadge && widget.badgeCount != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(EnhancedTheme.spacing2),
                decoration: BoxDecoration(
                  color: EnhancedTheme.errorColor,
                  borderRadius: BorderRadius.circular(EnhancedTheme.radius12),
                  border: Border.all(
                    color: widget.backgroundColor ?? EnhancedTheme.primaryColor,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  widget.badgeCount!,
                  style: EnhancedTheme.caption.copyWith(
                    color: EnhancedTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.tooltip != null) {
      fab = Tooltip(
        message: widget.tooltip!,
        child: fab,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTap: () {
                _controller.reverse().then((_) {
                  _controller.forward();
                });
                widget.onPressed();
              },
              child: fab,
            ),
          ),
        );
      },
    );
  }
}
