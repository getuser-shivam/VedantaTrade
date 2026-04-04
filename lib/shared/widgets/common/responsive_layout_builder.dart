import 'package:flutter/material.dart';

/// Responsive layout builder for adaptive UI
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget Function(BuildContext, ScreenSize)? builder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _getScreenSize(context));
    }

    return _buildResponsiveLayout(context);
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (widget.largeDesktop != null && screenWidth >= 1920) {
      return widget.largeDesktop!;
    }
    
    if (widget.desktop != null && screenWidth >= 1200) {
      return widget.desktop!;
    }
    
    if (widget.tablet != null && screenWidth >= 768) {
      return widget.tablet!;
    }
    
    return widget.mobile;
  }

  ScreenSize _getScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1920) {
      return ScreenSize.largeDesktop;
    } else if (screenWidth >= 1200) {
      return ScreenSize.desktop;
    } else if (screenWidth >= 768) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.mobile;
    }
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1200 && width < 1920;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1920;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets padding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double statusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double bottomBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}

/// Screen size enum
enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive value selector
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  T getValue(BuildContext context) {
    final screenSize = ResponsiveLayoutBuilder._getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
      default:
        return mobile;
    }
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing,
    this.runSpacing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveValue<int>(
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
      largeDesktop: largeDesktopColumns ?? 4,
    ).getValue(context);

    return GridView.count(
      crossAxisCount: columns,
      children: children,
      spacing: spacing ?? 8,
      runSpacing: runSpacing ?? 8,
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}

/// Responsive container with adaptive sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? largeDesktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? largeDesktopHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.largeDesktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.largeDesktopHeight,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveValue<double>(
      mobile: mobileWidth ?? double.infinity,
      tablet: tabletWidth,
      desktop: desktopWidth,
      largeDesktop: largeDesktopWidth,
    ).getValue(context);

    final height = ResponsiveValue<double>(
      mobile: mobileHeight,
      tablet: tabletHeight,
      desktop: desktopHeight,
      largeDesktop: largeDesktopHeight,
    ).getValue(context);

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
      ),
      constraints: constraints,
      child: child,
    );
  }
}

/// Responsive text with adaptive sizing
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextStyle? largeDesktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.largeDesktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = ResponsiveValue<TextStyle>(
      mobile: mobileStyle ?? const TextStyle(fontSize: 14),
      tablet: tabletStyle ?? const TextStyle(fontSize: 16),
      desktop: desktopStyle ?? const TextStyle(fontSize: 18),
      largeDesktop: largeDesktopStyle ?? const TextStyle(fontSize: 20),
    ).getValue(context);

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final Widget child;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? largeDesktopSpacing;
  final bool vertical;

  const ResponsiveSpacing({
    Key? key,
    required this.child,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.largeDesktopSpacing,
    this.vertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveValue<double>(
      mobile: mobileSpacing ?? 8,
      tablet: tabletSpacing ?? 12,
      desktop: desktopSpacing ?? 16,
      largeDesktop: largeDesktopSpacing ?? 20,
    ).getValue(context);

    return vertical
        ? SizedBox(height: spacing, child: child)
        : SizedBox(width: spacing, child: child);
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? largeDesktopPadding;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue<EdgeInsets>(
      mobile: mobilePadding ?? const EdgeInsets.all(8),
      tablet: tabletPadding ?? const EdgeInsets.all(12),
      desktop: desktopPadding ?? const EdgeInsets.all(16),
      largeDesktop: largeDesktopPadding ?? const EdgeInsets.all(20),
    ).getValue(context);

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive margin widget
class ResponsiveMargin extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobileMargin;
  final EdgeInsets? tabletMargin;
  final EdgeInsets? desktopMargin;
  final EdgeInsets? largeDesktopMargin;

  const ResponsiveMargin({
    Key? key,
    required this.child,
    this.mobileMargin,
    this.tabletMargin,
    this.desktopMargin,
    this.largeDesktopMargin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final margin = ResponsiveValue<EdgeInsets>(
      mobile: mobileMargin ?? const EdgeInsets.all(8),
      tablet: tabletMargin ?? const EdgeInsets.all(12),
      desktop: desktopMargin ?? const EdgeInsets.all(16),
      largeDesktop: largeDesktopMargin ?? const EdgeInsets.all(20),
    ).getValue(context);

    return Container(
      margin: margin,
      child: child,
    );
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool showOnMobile;
  final bool showOnTablet;
  final bool showOnDesktop;
  final bool showOnLargeDesktop;

  const ResponsiveVisibility({
    Key? key,
    required this.child,
    this.showOnMobile = true,
    this.showOnTablet = true,
    this.showOnDesktop = true,
    this.showOnLargeDesktop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayoutBuilder._getScreenSize(context);
    
    bool shouldShow = false;
    switch (screenSize) {
      case ScreenSize.largeDesktop:
        shouldShow = showOnLargeDesktop;
        break;
      case ScreenSize.desktop:
        shouldShow = showOnDesktop;
        break;
      case ScreenSize.tablet:
        shouldShow = showOnTablet;
        break;
      case ScreenSize.mobile:
        shouldShow = showOnMobile;
        break;
    }

    return shouldShow ? child : const SizedBox.shrink();
  }
}

/// Responsive orientation builder
class ResponsiveOrientationBuilder extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;
  final Widget Function(BuildContext, Orientation)? builder;

  const ResponsiveOrientationBuilder({
    Key? key,
    required this.portrait,
    this.landscape,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, MediaQuery.of(context).orientation);
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        return orientation == Orientation.portrait ? widget.portrait : widget.landscape;
      },
    );
  }
}

/// Responsive safe area widget
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;
  final EdgeInsets? maintainBottomViewPadding;

  const ResponsiveSafeArea({
    Key? key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum,
    this.maintainBottomViewPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}
