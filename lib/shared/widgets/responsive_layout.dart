import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/enhanced_app_theme.dart';

class ResponsiveLayout {
  // Breakpoint constants
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  static const double largeDesktopBreakpoint = 1920;

  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  // Responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= largeDesktopBreakpoint && largeDesktop != null) {
      return largeDesktop!;
    } else if (width >= desktopBreakpoint && desktop != null) {
      return desktop!;
    } else if (width >= mobileBreakpoint && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }

  // Responsive font size
  static double responsiveFontSize({
    required BuildContext context,
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
    double? largeDesktopSize,
  }) {
    return responsiveValue<double>(
      context: context,
      mobile: mobileSize,
      tablet: tabletSize ?? mobileSize * 1.2,
      desktop: desktopSize ?? mobileSize * 1.4,
      largeDesktop: largeDesktopSize ?? mobileSize * 1.6,
    );
  }

  // Responsive padding
  static EdgeInsets responsivePadding({
    required BuildContext context,
    required EdgeInsets mobilePadding,
    EdgeInsets? tabletPadding,
    EdgeInsets? desktopPadding,
    EdgeInsets? largeDesktopPadding,
  }) {
    return responsiveValue<EdgeInsets>(
      context: context,
      mobile: mobilePadding,
      tablet: tabletPadding ?? mobilePadding * 1.5,
      desktop: desktopPadding ?? mobilePadding * 2,
      largeDesktop: largeDesktopPadding ?? mobilePadding * 2.5,
    );
  }

  // Responsive width percentage
  static double responsiveWidth({
    required BuildContext context,
    required double mobilePercentage,
    double? tabletPercentage,
    double? desktopPercentage,
    double? largeDesktopPercentage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final percentage = responsiveValue<double>(
      context: context,
      mobile: mobilePercentage,
      tablet: tabletPercentage ?? mobilePercentage,
      desktop: desktopPercentage ?? mobilePercentage,
      largeDesktop: largeDesktopPercentage ?? mobilePercentage,
    );
    return screenWidth * (percentage / 100);
  }

  // Responsive grid columns
  static int responsiveColumns({
    required BuildContext context,
    required int mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    int? largeDesktopColumns,
  }) {
    return responsiveValue<int>(
      context: context,
      mobile: mobileColumns,
      tablet: tabletColumns ?? mobileColumns + 1,
      desktop: desktopColumns ?? tabletColumns ?? mobileColumns + 2,
      largeDesktop: largeDesktopColumns ?? desktopColumns ?? mobileColumns + 3,
    );
  }
}

/// Responsive Layout Builder for adaptive UI
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && largeDesktop != null) {
          return largeDesktop!;
        } else if (constraints.maxWidth >= 1024 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 768 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive Container with adaptive padding and constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double? maxWidth;
  final Color? backgroundColor;
  final Decoration? decoration;
  final Clip clipBehavior;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.maxWidth,
    this.backgroundColor,
    this.decoration,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double? computedMaxWidth = maxWidth;
    
    if (computedMaxWidth == null) {
      if (screenWidth >= 1920) {
        computedMaxWidth = 1200;
      } else if (screenWidth >= 1440) {
        computedMaxWidth = 900;
      } else if (screenWidth >= 1024) {
        computedMaxWidth = 600;
      } else {
        computedMaxWidth = null;
      }
    }

    return Container(
      width: width,
      height: height,
      constraints: BoxConstraints(maxWidth: computedMaxWidth),
      padding: padding ?? ResponsiveLayout.responsivePadding(
        context: context,
        mobilePadding: const EdgeInsets.all(16),
        tabletPadding: const EdgeInsets.all(24),
        desktopPadding: const EdgeInsets.all(32),
        largeDesktopPadding: const EdgeInsets.all(40),
      ),
      margin: margin,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Responsive Grid with adaptive columns
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.responsiveColumns(
      context: context,
      mobileColumns: mobileColumns,
      tabletColumns: tabletColumns,
      desktopColumns: desktopColumns,
      largeDesktopColumns: largeDesktopColumns,
    );

    return GridView.builder(
      padding: padding ?? ResponsiveLayout.responsivePadding(
        context: context,
        mobilePadding: const EdgeInsets.all(16),
        tabletPadding: const EdgeInsets.all(24),
        desktopPadding: const EdgeInsets.all(32),
        largeDesktopPadding: const EdgeInsets.all(40),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: ResponsiveLayout.responsiveValue<double>(
          context: context,
          mobile: 1.0,
          tablet: 1.2,
          desktop: 1.4,
          largeDesktop: 1.6,
        ),
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive Row with adaptive layout
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final EdgeInsets? padding;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final computedSpacing = ResponsiveLayout.responsiveValue<double>(
      context: context,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
      largeDesktop: 20.0,
    );

    if (isMobile) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children.map((child) {
          return Padding(
            padding: EdgeInsets.only(bottom: computedSpacing),
            child: child,
          );
        }).toList(),
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children.map((child) {
          return Padding(
            padding: EdgeInsets.only(right: computedSpacing),
            child: child,
          );
        }).toList(),
      );
    }
  }
}

/// Responsive Text with adaptive font size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? TextStyle(
      color: EnhancedAppTheme.textPrimary,
    );
    final responsiveStyle = baseStyle.copyWith(
      fontSize: ResponsiveLayout.responsiveFontSize(
        context: context,
        mobileSize: baseStyle.fontSize ?? 14,
        tabletSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 1.2 : null,
        desktopSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 1.4 : null,
        largeDesktopSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 1.6 : null,
      ),
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive Card with adaptive padding and elevation
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final double? width;
  final double? height;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.shadowColor,
    this.shape,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final computedElevation = elevation ?? ResponsiveLayout.responsiveValue<double>(
      context: context,
      mobile: 2.0,
      tablet: 4.0,
      desktop: 6.0,
      largeDesktop: 8.0,
    );

    return Card(
      elevation: computedElevation,
      color: color,
      shadowColor: shadowColor,
      shape: shape,
      clipBehavior: clipBehavior,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? ResponsiveLayout.responsivePadding(
          context: context,
          mobilePadding: const EdgeInsets.all(16),
          tabletPadding: const EdgeInsets.all(20),
          desktopPadding: const EdgeInsets.all(24),
          largeDesktopPadding: const EdgeInsets.all(28),
        ),
        margin: margin,
        child: child,
      ),
    );
  }
}

/// Responsive Navigation with adaptive layout
class ResponsiveNavigation extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveNavigation({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: desktop,
    );
  }
}

/// Responsive AppBar with adaptive title and actions
class ResponsiveAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ResponsiveText(
        text: title,
        style: TextStyle(
          color: foregroundColor ?? EnhancedAppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? EnhancedAppTheme.surfaceColor,
      foregroundColor: foregroundColor,
      elevation: elevation ?? ResponsiveLayout.responsiveValue<double>(
        context: context,
        mobile: 2.0,
        tablet: 4.0,
        desktop: 6.0,
        largeDesktop: 8.0,
      ),
    );
  }
}
        }
      },
    );
  }
}

/// Responsive Container with adaptive padding and margins
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;
  final bool center;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.center = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = maxWidth ?? _getMaxWidth(constraints.maxWidth);
        final containerPadding = padding ?? _getPadding(constraints.maxWidth);
        final containerMargin = margin ?? _getMargin(constraints.maxWidth);

        Widget container = Container(
          width: containerWidth,
          padding: containerPadding,
          margin: containerMargin,
          child: child,
        );

        if (center) {
          container = Center(child: container);
        }

        return container;
      },
    );
  }

  double _getMaxWidth(double width) {
    if (width >= 1200) return 1140;
    if (width >= 1024) return 960;
    if (width >= 768) return 720;
    return double.infinity;
  }

  EdgeInsetsGeometry _getPadding(double width) {
    if (width >= 1200) return const EdgeInsets.all(32);
    if (width >= 1024) return const EdgeInsets.all(24);
    if (width >= 768) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }

  EdgeInsetsGeometry _getMargin(double width) {
    if (width >= 1200) return const EdgeInsets.symmetric(horizontal: 32);
    if (width >= 1024) return const EdgeInsets.symmetric(horizontal: 24);
    if (width >= 768) return const EdgeInsets.symmetric(horizontal: 20);
    return const EdgeInsets.symmetric(horizontal: 16);
  }
}

/// Responsive Grid with adaptive columns
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumns(constraints.maxWidth);
        final aspectRatio = childAspectRatio ?? _getChildAspectRatio(constraints.maxWidth);

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return children[index];
          },
        );
      },
    );
  }

  int _getColumns(double width) {
    if (width >= 1200) return desktopColumns ?? 4;
    if (width >= 768) return tabletColumns ?? 2;
    return mobileColumns;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1200) return 1.2;
    if (width >= 768) return 1.0;
    return 0.8;
  }
}

/// Responsive Navigation with adaptive layout
class ResponsiveNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<EnhancedBottomNavItem> items;
  final bool useRail;

  const ResponsiveNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.useRail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024 && useRail) {
          return _buildNavigationRail();
        } else {
          return _buildBottomNavigation();
        }
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: _buildNavItem(item, isSelected),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          right: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 24,
                      color: isSelected
                          ? (item.color ?? AppTheme.primary)
                          : AppTheme.glassBorderLight,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? (item.color ?? AppTheme.primary)
                            : AppTheme.glassBorderLight,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(EnhancedBottomNavItem item, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
            decoration: isSelected
                ? BoxDecoration(
                    color: item.color?.withOpacity(0.2) ?? AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Icon(
              item.icon,
              size: 24,
              color: isSelected
                  ? (item.color ?? AppTheme.primary)
                  : AppTheme.glassBorderLight,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? (item.color ?? AppTheme.primary)
                    : AppTheme.glassBorderLight,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive AppBar with adaptive layout
class ResponsiveAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _buildDesktopAppBar(context);
        } else {
          return _buildMobileAppBar(context);
        }
      },
    );
  }

  Widget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      backgroundColor: AppTheme.surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildDesktopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (automaticallyImplyLeading && Navigator.canPop(context))
            IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (actions != null) ...actions,
        ],
      ),
    );
  }
}

/// Responsive Scaffold with adaptive layout
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const ResponsiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return _buildDesktopScaffold(context);
        } else {
          return _buildMobileScaffold(context);
        }
      },
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar != null ? PreferredSizeWidget(appBar!) : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Row(
      children: [
        if (drawer != null)
          Container(
            width: 280,
            color: AppTheme.surfaceDark,
            child: drawer!,
          ),
        Expanded(
          child: Scaffold(
            appBar: appBar != null ? PreferredSizeWidget(appBar!) : null,
            body: body,
            floatingActionButton: floatingActionButton,
            endDrawer: endDrawer,
            extendBody: extendBody,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
          ),
        ),
        if (endDrawer != null)
          Container(
            width: 280,
            color: AppTheme.surfaceDark,
            child: endDrawer!,
          ),
      ],
    );
  }
}

/// Responsive Text with adaptive font sizes
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _getFontSize(constraints.maxWidth, style?.fontSize);
        final fontWeight = _getFontWeight(constraints.maxWidth, style?.fontWeight);

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  double _getFontSize(double width, double? baseFontSize) {
    final base = baseFontSize ?? 16;
    if (width >= 1200) return base * 1.2;
    if (width >= 768) return base * 1.1;
    return base;
  }

  FontWeight _getFontWeight(double width, FontWeight? baseFontWeight) {
    return baseFontWeight ?? FontWeight.normal;
  }
}

class EnhancedBottomNavItem {
  final IconData icon;
  final String label;
  final Color? color;

  const EnhancedBottomNavItem({
    required this.icon,
    required this.label,
    this.color,
  });
}
