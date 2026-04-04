import 'package:flutter/material.dart';
import '../theme/enhanced_theme.dart';
import 'enhanced_ui_kit.dart';

/// Enhanced Responsive Layout System for VedantaTrade
/// Provides responsive design utilities and widgets for all screen sizes
class EnhancedResponsiveLayout {
  // Breakpoint constants
  static const double mobileBreakpoint = EnhancedTheme.breakpointMobile;
  static const double tabletBreakpoint = EnhancedTheme.breakpointTablet;
  static const double desktopBreakpoint = EnhancedTheme.breakpointDesktop;

  // Device type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(EnhancedTheme.spacing32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(EnhancedTheme.spacing24);
    } else {
      return const EdgeInsets.all(EnhancedTheme.spacing16);
    }
  }

  // Responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(EnhancedTheme.spacing24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(EnhancedTheme.spacing16);
    } else {
      return const EdgeInsets.all(EnhancedTheme.spacing12);
    }
  }

  // Responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return baseSize * 1.2;
    } else if (width >= tabletBreakpoint) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  // Responsive columns count
  static int responsiveColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  // Responsive grid spacing
  static double responsiveGridSpacing(BuildContext context) {
    if (isDesktop(context)) {
      return EnhancedTheme.spacing24;
    } else if (isTablet(context)) {
      return EnhancedTheme.spacing16;
    } else {
      return EnhancedTheme.spacing12;
    }
  }
}

// Responsive Layout Builder
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = _getScreenType(context);
    return builder(context, screenType);
  }

  ScreenType _getScreenType(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return ScreenType.desktop;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
}

// Screen Type Enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

// Responsive Container
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;
  final bool centerContent;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.centerContent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containerMaxWidth = maxWidth ?? _getMaxWidth(context);
    final containerPadding = padding ?? EnhancedResponsiveLayout.responsivePadding(context);
    final containerMargin = margin ?? EnhancedResponsiveLayout.responsiveMargin(context);

    Widget container = Container(
      width: double.infinity,
      padding: containerPadding,
      margin: containerMargin,
      child: child,
    );

    if (centerContent) {
      container = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          child: container,
        ),
      );
    }

    return container;
  }

  double _getMaxWidth(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 1200;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 800;
    } else {
      return double.infinity;
    }
  }
}

// Responsive Grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gridColumns = columns ?? EnhancedResponsiveLayout.responsiveColumns(context);
    final gridSpacing = spacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);
    final gridRunSpacing = runSpacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          crossAxisSpacing: gridSpacing,
          mainAxisSpacing: gridRunSpacing,
          childAspectRatio: _getChildAspectRatio(context),
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  double _getChildAspectRatio(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 1.2;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 1.1;
    } else {
      return 1.0;
    }
  }
}

// Responsive Row
class ResponsiveRow extends StatelessWidget {
  final List<ResponsiveRowItem> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rowSpacing = spacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _buildChildren(context, rowSpacing),
    );
  }

  List<Widget> _buildChildren(BuildContext context, double spacing) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      final item = children[i];
      
      if (item.isVisible(context)) {
        widgets.add(
          Flexible(
            flex: item.getFlex(context),
            fit: item.getFit(context),
            child: item.child,
          ),
        );
        
        if (i < children.length - 1) {
          widgets.add(SizedBox(width: spacing));
        }
      }
    }
    
    return widgets;
  }
}

// Responsive Row Item
class ResponsiveRowItem {
  final Widget child;
  final int? mobileFlex;
  final int? tabletFlex;
  final int? desktopFlex;
  final bool? mobileVisible;
  final bool? tabletVisible;
  final bool? desktopVisible;
  final FlexFit? mobileFit;
  final FlexFit? tabletFit;
  final FlexFit? desktopFit;

  const ResponsiveRowItem({
    required this.child,
    this.mobileFlex,
    this.tabletFlex,
    this.desktopFlex,
    this.mobileVisible,
    this.tabletVisible,
    this.desktopVisible,
    this.mobileFit,
    this.tabletFit,
    this.desktopFit,
  });

  int getFlex(BuildContext context) {
    return EnhancedResponsiveLayout.responsiveValue(
      context: context,
      mobile: mobileFlex ?? 1,
      tablet: tabletFlex,
      desktop: desktopFlex,
    );
  }

  FlexFit getFit(BuildContext context) {
    return EnhancedResponsiveLayout.responsiveValue(
      context: context,
      mobile: mobileFit ?? FlexFit.loose,
      tablet: tabletFit,
      desktop: desktopFit,
    );
  }

  bool isVisible(BuildContext context) {
    return EnhancedResponsiveLayout.responsiveValue(
      context: context,
      mobile: mobileVisible ?? true,
      tablet: tabletVisible ?? true,
      desktop: desktopVisible ?? true,
    );
  }
}

// Responsive Column
class ResponsiveColumn extends StatelessWidget {
  final List<ResponsiveColumnItem> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? spacing;

  const ResponsiveColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columnSpacing = spacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _buildChildren(context, columnSpacing),
    );
  }

  List<Widget> _buildChildren(BuildContext context, double spacing) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      final item = children[i];
      
      if (item.isVisible(context)) {
        widgets.add(item.child);
        
        if (i < children.length - 1) {
          widgets.add(SizedBox(height: spacing));
        }
      }
    }
    
    return widgets;
  }
}

// Responsive Column Item
class ResponsiveColumnItem {
  final Widget child;
  final bool? mobileVisible;
  final bool? tabletVisible;
  final bool? desktopVisible;

  const ResponsiveColumnItem({
    required this.child,
    this.mobileVisible,
    this.tabletVisible,
    this.desktopVisible,
  });

  bool isVisible(BuildContext context) {
    return EnhancedResponsiveLayout.responsiveValue(
      context: context,
      mobile: mobileVisible ?? true,
      tablet: tabletVisible ?? true,
      desktop: desktopVisible ?? true,
    );
  }
}

// Responsive Stack
class ResponsiveStack extends StatelessWidget {
  final List<Widget> children;
  final Alignment alignment;
  final StackFit fit;
  final EdgeInsetsGeometry? padding;

  const ResponsiveStack({
    Key? key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.fit = StackFit.loose,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Stack(
        alignment: alignment,
        fit: fit,
        children: children,
      ),
    );
  }
}

// Responsive Card Grid
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const ResponsiveCardGrid({
    Key? key,
    required this.children,
    this.padding,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = EnhancedResponsiveLayout.responsiveColumns(context);
    final spacing = crossAxisSpacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);
    final runSpacing = mainAxisSpacing ?? EnhancedResponsiveLayout.responsiveGridSpacing(context);
    final aspectRatio = childAspectRatio ?? _getAspectRatio(context);

    return Padding(
      padding: padding ?? EnhancedResponsiveLayout.responsivePadding(context),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  double _getAspectRatio(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 1.4;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 1.2;
    } else {
      return 1.0;
    }
  }
}

// Responsive Sidebar
class ResponsiveSidebar extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final double? sidebarWidth;
  final bool showSidebarOnMobile;
  final Widget? mobileNavigation;

  const ResponsiveSidebar({
    Key? key,
    required this.sidebar,
    required this.body,
    this.sidebarWidth,
    this.showSidebarOnMobile = false,
    this.mobileNavigation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return Row(
        children: [
          SizedBox(
            width: sidebarWidth ?? 250,
            child: sidebar,
          ),
          Expanded(child: body),
        ],
      );
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return Row(
        children: [
          SizedBox(
            width: sidebarWidth ?? 200,
            child: sidebar,
          ),
          Expanded(child: body),
        ],
      );
    } else {
      if (showSidebarOnMobile) {
        return Column(
          children: [
            if (mobileNavigation != null) mobileNavigation!,
            Expanded(child: body),
          ],
        );
      } else {
        return body;
      }
    }
  }
}

// Responsive AppBar
class ResponsiveAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const ResponsiveAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveActions = _getResponsiveActions(context);

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: EnhancedResponsiveLayout.responsiveFontSize(
                  context,
                  EnhancedTheme.heading4.fontSize!,
                ),
              ),
            )
          : null,
      actions: responsiveActions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }

  List<Widget>? _getResponsiveActions(BuildContext context) {
    if (actions == null) return null;

    if (EnhancedResponsiveLayout.isMobile(context)) {
      // Show only first 2 actions on mobile, rest in overflow menu
      final visibleActions = actions!.take(2).toList();
      if (actions!.length > 2) {
        visibleActions.add(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle overflow menu selection
            },
            itemBuilder: (context) {
              return actions!.skip(2).map((action) {
                return PopupMenuItem<String>(
                  value: action.toString(),
                  child: action,
                );
              }).toList();
            },
          ),
        );
      }
      return visibleActions;
    }

    return actions;
  }
}

// Responsive Scaffold
class ResponsiveScaffold extends StatelessWidget {
  final Widget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveBottomNav = _getResponsiveBottomNav(context);
    final responsiveDrawer = _getResponsiveDrawer(context);

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: responsiveBottomNav,
      floatingActionButton: floatingActionButton,
      drawer: responsiveDrawer,
      endDrawer: endDrawer,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
    );
  }

  Widget? _getResponsiveBottomNav(BuildContext context) {
    if (bottomNavigationBar == null) return null;

    if (EnhancedResponsiveLayout.isDesktop(context)) {
      // Don't show bottom navigation on desktop
      return null;
    }

    return bottomNavigationBar;
  }

  Widget? _getResponsiveDrawer(BuildContext context) {
    if (drawer == null) return null;

    if (EnhancedResponsiveLayout.isDesktop(context)) {
      // On desktop, drawer is typically not needed
      return null;
    }

    return drawer;
  }
}

// Responsive Text
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
    final responsiveStyle = _getResponsiveStyle(context);

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getResponsiveStyle(BuildContext context) {
    final baseStyle = style ?? EnhancedTheme.bodyMedium;
    final responsiveFontSize = EnhancedResponsiveLayout.responsiveFontSize(
      context,
      baseStyle.fontSize!,
    );

    return baseStyle.copyWith(fontSize: responsiveFontSize);
  }
}

// Responsive Icon
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const ResponsiveIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveSize = size ?? _getResponsiveSize(context);

    return Icon(
      icon,
      size: responsiveSize,
      color: color,
    );
  }

  double _getResponsiveSize(BuildContext context) {
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 28;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 24;
    } else {
      return 20;
    }
  }
}

// Responsive Image
class ResponsiveImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveWidth = width ?? _getResponsiveWidth(context);
    final responsiveHeight = height ?? _getResponsiveHeight(context);

    return Image.network(
      imageUrl,
      width: responsiveWidth,
      height: responsiveHeight,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }

  double _getResponsiveWidth(BuildContext context) {
    if (width != null) return width!;
    
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 300;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 250;
    } else {
      return 200;
    }
  }

  double _getResponsiveHeight(BuildContext context) {
    if (height != null) return height!;
    
    if (EnhancedResponsiveLayout.isDesktop(context)) {
      return 200;
    } else if (EnhancedResponsiveLayout.isTablet(context)) {
      return 150;
    } else {
      return 100;
    }
  }
}
