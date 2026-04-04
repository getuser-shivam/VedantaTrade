import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced navigation widgets with smooth transitions
class EnhancedNavigationWidget {
  /// Animated bottom navigation bar
  static Widget animatedBottomNavBar({
    required int currentIndex,
    required List<BottomNavigationBarItem> items,
    required ValueChanged<int> onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    double? iconSize,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableRipple = true,
    bool enableHapticFeedback = true,
  }) {
    return _AnimatedBottomNavBar(
      currentIndex: currentIndex,
      items: items,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      iconSize: iconSize,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableRipple: enableRipple,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Slide navigation drawer
  static Widget slideNavigationDrawer({
    required Widget child,
    required List<NavigationItem> items,
    required ValueChanged<int> onItemSelected,
    String? title,
    Widget? header,
    Color? backgroundColor,
    Color? itemBackgroundColor,
    Color? selectedItemColor,
    Color? textColor,
    double? width,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _SlideNavigationDrawer(
      child: child,
      items: items,
      onItemSelected: onItemSelected,
      title: title,
      header: header,
      backgroundColor: backgroundColor,
      itemBackgroundColor: itemBackgroundColor,
      selectedItemColor: selectedItemColor,
      textColor: textColor,
      width: width,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Tab navigation bar
  static Widget animatedTabBar({
    required List<Tab> tabs,
    required TabController controller,
    required ValueChanged<int> onTap,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? labelColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _AnimatedTabBar(
      tabs: tabs,
      controller: controller,
      onTap: onTap,
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      labelColor: labelColor,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Floating action menu
  static Widget floatingActionMenu({
    required Widget child,
    required List<MenuItem> items,
    required ValueChanged<MenuItem> onItemSelected,
    Color? backgroundColor,
    Color? itemColor,
    double? elevation,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _FloatingActionMenu(
      child: child,
      items: items,
      onItemSelected: onItemSelected,
      backgroundColor: backgroundColor,
      itemColor: itemColor,
      elevation: elevation,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Breadcrumb navigation
  static Widget breadcrumbNavigation({
    required List<BreadcrumbItem> items,
    required ValueChanged<BreadcrumbItem> onItemTap,
    Color? backgroundColor,
    Color? textColor,
    Color? separatorColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _BreadcrumbNavigation(
      items: items,
      onItemTap: onItemTap,
      backgroundColor: backgroundColor,
      textColor: textColor,
      separatorColor: separatorColor,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Page view navigation
  static Widget pageViewNavigation({
    required List<Widget> pages,
    required int currentIndex,
    required ValueChanged<int> onPageChanged,
    required PageController controller,
    bool enableSwipe = true,
    bool enableAnimation = true,
    Duration? animationDuration,
    Curve? curve,
    bool enableHapticFeedback = true,
  }) {
    return _PageViewNavigation(
      pages: pages,
      currentIndex: currentIndex,
      onPageChanged: onPageChanged,
      controller: controller,
      enableSwipe: enableSwipe,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      curve: curve,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Stepper navigation
  static Widget stepperNavigation({
    required List<Step> steps,
    required int currentStep,
    required ValueChanged<int> onStepTapped,
    required ValueChanged<int> onStepContinue,
    required ValueChanged<int> onStepCancel,
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _StepperNavigation(
      steps: steps,
      currentStep: currentStep,
      onStepTapped: onStepTapped,
      onStepContinue: onStepContinue,
      onStepCancel: onStepCancel,
      backgroundColor: backgroundColor,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Quick action navigation
  static Widget quickActionNavigation({
    required List<QuickAction> actions,
    required ValueChanged<QuickAction> onActionTapped,
    Color? backgroundColor,
    Color? actionColor,
    double? iconSize,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _QuickActionNavigation(
      actions: actions,
      onActionTapped: onActionTapped,
      backgroundColor: backgroundColor,
      actionColor: actionColor,
      iconSize: iconSize,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Search navigation bar
  static Widget searchNavigationBar({
    required TextEditingController controller,
    required String Function(String) onSearch,
    required VoidCallback onClear,
    String? hintText,
    IconData? searchIcon,
    IconData? clearIcon,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    double? height,
    bool enableAnimation = true,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
  }) {
    return _SearchNavigationBar(
      controller: controller,
      onSearch: onSearch,
      onClear: onClear,
      hintText: hintText,
      searchIcon: searchIcon,
      clearIcon: clearIcon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      height: height,
      enableAnimation: enableAnimation,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
    );
  }
}

/// Navigation item model
class NavigationItem {
  final IconData icon;
  final String label;
  final String? route;
  final Widget? badge;
  final bool isDisabled;
  final VoidCallback? onTap;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.route,
    this.badge,
    this.isDisabled = false,
    this.onTap,
  });
}

/// Menu item model
class MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final bool isDisabled;
  final VoidCallback? onTap;

  const MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.isDisabled = false,
    this.onTap,
  });
}

/// Breadcrumb item model
class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
    this.isActive = false,
    this.onTap,
  });
}

/// Quick action model
class QuickAction {
  final IconData icon;
  final String label;
  final String? description;
  final Color? color;
  final VoidCallback? onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    this.description,
    this.color,
    this.onTap,
  });
}

/// Private implementation classes for enhanced navigation widgets
class _AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? iconSize;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableRipple;
  final bool enableHapticFeedback;

  const _AnimatedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableRipple = true,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<_AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animations = List.generate(widget.items.length, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index / widget.items.length,
          (index + 1) / widget.items.length,
          Curves.easeInOut,
        ),
      ));
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final isSelected = index == widget.currentIndex;
          
          return Expanded(
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onTap(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (widget.selectedItemColor ?? Colors.blue).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: widget.iconSize ?? 24,
                          color: isSelected
                              ? (widget.selectedItemColor ?? Colors.blue)
                              : (widget.unselectedItemColor ?? Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label!,
                          style: TextStyle(
                            color: isSelected
                                ? (widget.selectedItemColor ?? Colors.blue)
                                : (widget.unselectedItemColor ?? Colors.grey),
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _SlideNavigationDrawer extends StatefulWidget {
  final Widget child;
  final List<NavigationItem> items;
  final ValueChanged<int> onItemSelected;
  final String? title;
  final Widget? header;
  final Color? backgroundColor;
  final Color? itemBackgroundColor;
  final Color? selectedItemColor;
  final Color? textColor;
  final double? width;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _SlideNavigationDrawer({
    Key? key,
    required this.child,
    required this.items,
    required this.onItemSelected,
    this.title,
    this.header,
    this.backgroundColor,
    this.itemBackgroundColor,
    this.selectedItemColor,
    this.textColor,
    this.width,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_SlideNavigationDrawer> createState() => _SlideNavigationDrawerState();
}

class _SlideNavigationDrawerState extends State<_SlideNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isOpen = !_isOpen;
    });

    if (_isOpen) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_slideAnimation.value * (widget.width ?? 300), 0),
              child: Container(
                width: widget.width ?? 300,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (widget.header != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: widget.header!,
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          return ListTile(
                            leading: Icon(
                              item.icon,
                              color: widget.textColor ?? Colors.black87,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: widget.textColor ?? Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: item.isDisabled ? null : () {
                              if (widget.enableHapticFeedback) {
                                HapticFeedback.lightImpact();
                              }
                              widget.onItemSelected(index);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _AnimatedTabBar extends StatefulWidget {
  final List<Tab> tabs;
  final TabController controller;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _AnimatedTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    required this.onTap,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<_AnimatedTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
      ),
      child: TabBar(
        controller: widget.controller,
        tabs: widget.tabs,
        indicatorColor: widget.indicatorColor,
        labelColor: widget.labelColor,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.tab,
        onTap: (index) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          widget.onTap(index);
        },
      ),
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _FloatingActionMenu extends StatefulWidget {
  final Widget child;
  final List<MenuItem> items;
  final ValueChanged<MenuItem> onItemSelected;
  final Color? backgroundColor;
  final Color? itemColor;
  final double? elevation;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _FloatingActionMenu({
    Key? key,
    required this.child,
    required this.items,
    required this.onItemSelected,
    this.backgroundColor,
    this.itemColor,
    this.elevation,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<_FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isMenuOpen ? _scaleAnimation.value : 1.0,
              child: Opacity(
                opacity: _isMenuOpen ? _fadeAnimation.value : 0.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minWidth: 200,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: widget.itemColor ?? Colors.black87,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: widget.itemColor ?? Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        trailing: item.trailing,
                        onTap: item.isDisabled ? null : () {
                          if (widget.enableHapticFeedback) {
                            HapticFeedback.lightImpact();
                          }
                          widget.onItemSelected(item);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final ValueChanged<BreadcrumbItem> onItemTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? separatorColor;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _BreadcrumbNavigation({
    Key? key,
    required this.items,
    required this.onItemTap,
    this.backgroundColor,
    this.textColor,
    this.separatorColor,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
      ),
      child: Row(
        children: List.generate(widget.items.length * 2 - 1, (index) {
          final itemIndex = index ~/ 2;
          final isSeparator = index % 2 == 1;
          
          if (isSeparator) {
            return Icon(
              Icons.chevron_right,
              color: widget.separatorColor ?? Colors.grey,
              size: 16,
            );
          } else {
            final item = widget.items[itemIndex];
            return GestureDetector(
              onTap: () {
                if (widget.enableHapticFeedback) {
                  HapticFeedback.lightImpact();
                }
                widget.onItemTap(item);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null)
                    Icon(
                      item.icon!,
                      color: widget.textColor ?? Colors.black87,
                      size: 16,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: item.isActive
                          ? (widget.textColor ?? Colors.blue)
                          : (widget.textColor ?? Colors.black87),
                      fontWeight: item.isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _PageViewNavigation extends StatelessWidget {
  final List<Widget> pages;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final PageController controller;
  final bool enableSwipe;
  final bool enableAnimation;
  final Duration? animationDuration;
  final Curve? curve;
  final bool enableHapticFeedback;

  const _PageViewNavigation({
    Key? key,
    required this.pages,
    required this.currentIndex,
    required this.onPageChanged,
    required this.controller,
    this.enableSwipe = true,
    this.enableAnimation = true,
    this.animationDuration,
    this.curve,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.pages.length,
      onPageChanged: (index) {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        widget.onPageChanged(index);
      },
      physics: widget.enableSwipe
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: widget.animationDuration ?? const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: widget.pages[index],
        );
      },
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _StepperNavigation extends StatelessWidget {
  final List<Step> steps;
  final int currentStep;
  final ValueChanged<int> onStepTapped;
  final ValueChanged<int> onStepContinue;
  final ValueChanged<int> onStepCancel;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _StepperNavigation({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onStepTapped,
    required this.onStepContinue,
    required this.onStepCancel,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
      ),
      child: Stepper(
        currentStep: widget.currentStep,
        steps: widget.steps,
        onStepTapped: (step) {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          widget.onStepTapped(step);
        },
        onStepContinue: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          widget.onStepContinue(widget.currentStep + 1);
        },
        onStepCancel: () {
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          widget.onStepCancel(widget.currentStep - 1);
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (details.currentStep > 0)
                TextButton(
                  onPressed: () {
                    if (widget.enableHapticFeedback) {
                      HapticFeedback.lightImpact();
                    }
                    widget.onStepCancel(details.currentStep - 1);
                  },
                  child: const Text('BACK'),
                ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.enableHapticFeedback) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onStepContinue(details.currentStep + 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.activeColor ?? Colors.blue,
                ),
                child: const Text('CONTINUE'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Placeholder implementations for other navigation widgets
class _QuickActionNavigation extends StatelessWidget {
  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onActionTapped;
  final Color? backgroundColor;
  final Color? actionColor;
  final double? iconSize;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _QuickActionNavigation({
    Key? key,
    required this.actions,
    required this.onActionTapped,
    this.backgroundColor,
    this.actionColor,
    this.iconSize,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: widget.actions.length,
        itemBuilder: (context, index) {
          final action = widget.actions[index];
          return GestureDetector(
            onTap: () {
              if (widget.enableHapticFeedback) {
                HapticFeedback.lightImpact();
              }
              widget.onActionTapped(action);
            },
            child: Container(
              decoration: BoxDecoration(
                color: action.color?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: action.color ?? Colors.blue,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action.icon,
                    size: widget.iconSize ?? 32,
                    color: action.color ?? Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: action.color ?? Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

/// Placeholder implementations for other navigation widgets
class _SearchNavigationBar extends StatefulWidget {
  final TextEditingController controller;
  final String Function(String) onSearch;
  final VoidCallback onClear;
  final String? hintText;
  final IconData? searchIcon;
  final IconData? clearIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? height;
  final bool enableAnimation;
  final Duration? animationDuration;
  final bool enableHapticFeedback;

  const _SearchNavigationBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.hintText,
    this.searchIcon,
    this.clearIcon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.height,
    this.enableAnimation = true,
    this.animationDuration,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<_SearchNavigationBar> createState() => _SearchNavigationBarState();
}

class _SearchNavigationBarState extends State<_SearchNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  void _handleFocusChange(bool focused) {
    setState(() {
      _isFocused = focused;
    });

    if (focused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onSearch,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: Icon(
                      widget.searchIcon ?? Icons.search,
                      color: widget.iconColor ?? Colors.grey,
                    ),
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              widget.clearIcon ?? Icons.clear,
                              color: widget.iconColor ?? Colors.grey,
                            ),
                            onPressed: () {
                              if (widget.enableHapticFeedback) {
                                HapticFeedback.lightImpact();
                              }
                              widget.onClear();
                            },
                          )
                        : null,
                    hintStyle: TextStyle(
                      color: widget.textColor ?? Colors.black54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    color: widget.textColor ?? Colors.black87,
                  ),
                  onTap: () => _handleFocusChange(true),
                  onEditingComplete: () => _handleFocusChange(false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
