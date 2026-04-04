import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';

/// Responsive Layout System for VedantaTrade
/// Provides adaptive layouts for different screen sizes

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final bool useConstrained;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.useConstrained = true,
    this.maxWidth,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget child = _getLayoutForScreenSize(constraints.maxWidth);

        if (useConstrained) {
          child = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? _getMaxWidthForScreenSize(constraints.maxWidth),
            ),
            child: child,
          );
        }

        if (padding != null) {
          child = Padding(
            padding: padding!,
            child: child,
          );
        }

        return child;
      },
    );
  }

  Widget _getLayoutForScreenSize(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop && largeDesktop != null) {
      return largeDesktop!;
    } else if (width >= ResponsiveBreakpoints.desktop && desktop != null) {
      return desktop!;
    } else if (width >= ResponsiveBreakpoints.tablet && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }

  double _getMaxWidthForScreenSize(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return 1400;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return 1200;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 800;
    } else {
      return double.infinity;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = _getScreenType(constraints.maxWidth);
        return builder(context, screenType);
      },
    );
  }

  ScreenType _getScreenType(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return ScreenType.largeDesktop;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return ScreenType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        final columns = _getColumnsForScreenType(screenType);
        
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: _getChildAspectRatio(screenType),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getColumnsForScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobileColumns;
      case ScreenType.tablet:
        return tabletColumns;
      case ScreenType.desktop:
        return desktopColumns;
      case ScreenType.largeDesktop:
        return largeDesktopColumns;
    }
  }

  double _getChildAspectRatio(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 1.2;
      case ScreenType.tablet:
        return 1.1;
      case ScreenType.desktop:
        return 1.0;
      case ScreenType.largeDesktop:
        return 0.9;
    }
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment runCrossAlignment;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
    this.runAlignment = WrapAlignment.start,
    this.runCrossAlignment = WrapCrossAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          // Use Column for mobile
          return Column(
            mainAxisSize: mainAxisSize,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: child,
            )).toList(),
          );
        } else {
          // Use Row for larger screens
          return Row(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) => Padding(
              padding: EdgeInsets.only(right: spacing),
              child: Flexible(child: child),
            )).toList(),
          );
        }
      },
    );
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final bool isCompact;

  const ResponsiveColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        final adjustedSpacing = isCompact ? spacing * 0.5 : spacing;
        
        return Column(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.map((child) => Padding(
            padding: EdgeInsets.only(bottom: adjustedSpacing),
            child: child,
          )).toList(),
        );
      },
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? largeDesktopPadding;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final double? largeDesktopMaxWidth;
  final bool useConstrained;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.largeDesktopMaxWidth,
    this.useConstrained = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        EdgeInsets padding;
        double? maxWidth;

        switch (screenType) {
          case ScreenType.mobile:
            padding = mobilePadding ?? const EdgeInsets.all(16);
            maxWidth = mobileMaxWidth;
            break;
          case ScreenType.tablet:
            padding = tabletPadding ?? const EdgeInsets.all(24);
            maxWidth = tabletMaxWidth ?? 800;
            break;
          case ScreenType.desktop:
            padding = desktopPadding ?? const EdgeInsets.all(32);
            maxWidth = desktopMaxWidth ?? 1200;
            break;
          case ScreenType.largeDesktop:
            padding = largeDesktopPadding ?? const EdgeInsets.all(40);
            maxWidth = largeDesktopMaxWidth ?? 1400;
            break;
        }

        Widget container = Padding(
          padding: padding,
          child: child,
        );

        if (useConstrained && maxWidth != null) {
          container = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: container,
          );
        }

        return container;
      },
    );
  }
}

class ResponsiveSidebar extends StatelessWidget {
  final Widget sidebar;
  final Widget mainContent;
  final double sidebarWidth;
  final double mobileSidebarWidth;
  final bool showSidebarOnMobile;
  final Widget? mobileBottomNavigation;

  const ResponsiveSidebar({
    Key? key,
    required this.sidebar,
    required this.mainContent,
    this.sidebarWidth = 280,
    this.mobileSidebarWidth = 280,
    this.showSidebarOnMobile = false,
    this.mobileBottomNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          if (showSidebarOnMobile) {
            return Scaffold(
              body: mainContent,
              drawer: Drawer(
                width: mobileSidebarWidth,
                child: sidebar,
              ),
              bottomNavigationBar: mobileBottomNavigation,
            );
          } else {
            return Scaffold(
              body: mainContent,
              bottomNavigationBar: mobileBottomNavigation,
            );
          }
        } else {
          return Row(
            children: [
              Container(
                width: sidebarWidth,
                child: sidebar,
              ),
              Expanded(
                child: mainContent,
              ),
            ],
          );
        }
      },
    );
  }
}

class ResponsiveAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ResponsiveAppBar({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        final theme = Theme.of(context);
        
        if (screenType == ScreenType.mobile) {
          return AppBar(
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor,
              ),
            ),
            actions: actions?.take(3).toList(),
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            flexibleSpace: flexibleSpace,
            bottom: bottom,
            elevation: elevation,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          );
        } else {
          return AppBar(
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: foregroundColor,
              ),
            ),
            actions: actions,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            flexibleSpace: flexibleSpace,
            bottom: bottom,
            elevation: elevation,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            titleSpacing: 24,
          );
        }
      },
    );
  }
}

class ResponsiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;

  const ResponsiveNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        if (screenType == ScreenType.mobile) {
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            items: items.map((item) => BottomNavigationBarItem(
              icon: item.icon,
              label: item.label,
            )).toList(),
          );
        } else {
          return NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            extended: screenType == ScreenType.desktop || screenType == ScreenType.largeDesktop,
            destinations: items.map((item) => NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.selectedIcon ?? item.icon,
              label: Text(item.label),
            )).toList(),
          );
        }
      },
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? largeDesktopPadding;
  final double? mobileMargin;
  final double? tabletMargin;
  final double? desktopMargin;
  final double? largeDesktopMargin;
  final double? mobileBorderRadius;
  final double? tabletBorderRadius;
  final double? desktopBorderRadius;
  final double? largeDesktopBorderRadius;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
    this.mobileMargin,
    this.tabletMargin,
    this.desktopMargin,
    this.largeDesktopMargin,
    this.mobileBorderRadius,
    this.tabletBorderRadius,
    this.desktopBorderRadius,
    this.largeDesktopBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        EdgeInsets padding;
        double margin;
        double borderRadius;

        switch (screenType) {
          case ScreenType.mobile:
            padding = mobilePadding ?? const EdgeInsets.all(16);
            margin = mobileMargin ?? 8;
            borderRadius = mobileBorderRadius ?? 8;
            break;
          case ScreenType.tablet:
            padding = tabletPadding ?? const EdgeInsets.all(20);
            margin = tabletMargin ?? 12;
            borderRadius = tabletBorderRadius ?? 12;
            break;
          case ScreenType.desktop:
            padding = desktopPadding ?? const EdgeInsets.all(24);
            margin = desktopMargin ?? 16;
            borderRadius = desktopBorderRadius ?? 16;
            break;
          case ScreenType.largeDesktop:
            padding = largeDesktopPadding ?? const EdgeInsets.all(28);
            margin = largeDesktopMargin ?? 20;
            borderRadius = largeDesktopBorderRadius ?? 20;
            break;
        }

        return Container(
          margin: EdgeInsets.all(margin),
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

// Responsive Breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

// Screen Type Enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

// Navigation Item Model
class NavigationItem {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

// Responsive Extensions
extension ResponsiveContext on BuildContext {
  ScreenType get screenType {
    final width = MediaQuery.of(this).size.width;
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return ScreenType.largeDesktop;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return ScreenType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
  bool get isLargeDesktop => screenType == ScreenType.largeDesktop;
  
  bool get isMobileOrTablet => isMobile || isTablet;
  bool get isDesktopOrLarge => isDesktop || isLargeDesktop;
}

extension ResponsiveWidget on Widget {
  Widget responsive({
    Widget? tablet,
    Widget? desktop,
    Widget? largeDesktop,
    bool useConstrained = true,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    return ResponsiveLayout(
      mobile: this,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      useConstrained: useConstrained,
      maxWidth: maxWidth,
      padding: padding,
    );
  }
}
