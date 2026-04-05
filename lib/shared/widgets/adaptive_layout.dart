import 'package:flutter/material.dart';
import '../theme/enhanced_app_theme.dart';
import '../constants/app_constants.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? fallback;

  const AdaptiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1600 && largeDesktop != null) {
          return largeDesktop!;
        } else if (constraints.maxWidth >= 1200 && desktop != null) {
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

class AdaptiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    ScreenSize screenSize,
    BoxConstraints constraints,
  ) builder;

  const AdaptiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = _getScreenSize(constraints);
        return builder(context, screenSize, constraints);
      },
    );
  }

  ScreenSize _getScreenSize(BoxConstraints constraints) {
    if (constraints.maxWidth >= 1600) {
      return ScreenSize.largeDesktop;
    } else if (constraints.maxWidth >= 1200) {
      return ScreenSize.desktop;
    } else if (constraints.maxWidth >= 768) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.mobile;
    }
  }
}

enum ScreenSize {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final bool centerContent;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.centerContent = true,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final defaultPadding = _getAdaptivePadding(screenSize);
        final defaultMaxWidth = _getAdaptiveMaxWidth(screenSize);
        
        return Container(
          margin: margin,
          padding: padding ?? defaultPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
            boxShadow: boxShadow,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? defaultMaxWidth,
              ),
              child: centerContent ? child : child,
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getAdaptivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(24);
      case ScreenSize.desktop:
        return const EdgeInsets.all(32);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(40);
    }
  }

  double _getAdaptiveMaxWidth(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return double.infinity;
      case ScreenSize.tablet:
        return 768;
      case ScreenSize.desktop:
        return 1200;
      case ScreenSize.largeDesktop:
        return 1600;
    }
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final bool shrinkWrap;

  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final columns = _getColumnsForScreenSize(screenSize);
        
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: _getChildAspectRatio(screenSize),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getColumnsForScreenSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileColumns;
      case ScreenSize.tablet:
        return tabletColumns ?? 2;
      case ScreenSize.desktop:
        return desktopColumns ?? 3;
      case ScreenSize.largeDesktop:
        return largeDesktopColumns ?? 4;
    }
  }

  double _getChildAspectRatio(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 1.2;
      case ScreenSize.tablet:
        return 1.1;
      case ScreenSize.desktop:
        return 1.0;
      case ScreenSize.largeDesktop:
        return 0.9;
    }
  }
}

class AdaptiveRow extends StatelessWidget {
  final List<AdaptiveColumn> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const AdaptiveRow({
    Key? key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        if (screenSize == ScreenSize.mobile) {
          // Stack columns vertically on mobile
          return Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: children.map((column) => column.child).toList(),
          );
        } else {
          // Layout columns horizontally on larger screens
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _buildColumnsWithSpacing(screenSize),
          );
        }
      },
    );
  }

  List<Widget> _buildColumnsWithSpacing(ScreenSize screenSize) {
    final List<Widget> result = [];
    
    for (int i = 0; i < children.length; i++) {
      final column = children[i];
      final flex = column.getFlexForScreenSize(screenSize);
      
      result.add(Expanded(
        flex: flex,
        child: Padding(
          padding: EdgeInsets.only(right: i < children.length - 1 ? spacing : 0),
          child: column.child,
        ),
      ));
    }
    
    return result;
  }
}

class AdaptiveColumn {
  final Widget child;
  final int? mobileFlex;
  final int? tabletFlex;
  final int? desktopFlex;
  final int? largeDesktopFlex;

  const AdaptiveColumn({
    required this.child,
    this.mobileFlex,
    this.tabletFlex,
    this.desktopFlex,
    this.largeDesktopFlex,
  });

  int getFlexForScreenSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobileFlex ?? 1;
      case ScreenSize.tablet:
        return tabletFlex ?? desktopFlex ?? 1;
      case ScreenSize.desktop:
        return desktopFlex ?? 1;
      case ScreenSize.largeDesktop:
        return largeDesktopFlex ?? desktopFlex ?? 1;
    }
  }
}

class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool showHoverEffect;
  final Duration? animationDuration;

  const AdaptiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.shadowColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.showHoverEffect = true,
    this.animationDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final defaultPadding = _getAdaptivePadding(screenSize);
        final defaultBorderRadius = _getAdaptiveBorderRadius(screenSize);
        final defaultElevation = _getAdaptiveElevation(screenSize);
        
        return AnimatedContainer(
          duration: animationDuration ?? AppConstants.defaultAnimationDuration,
          padding: padding ?? defaultPadding,
          margin: margin,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
            border: border,
            boxShadow: boxShadow ?? _getAdaptiveBoxShadow(screenSize, defaultElevation),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? defaultBorderRadius),
              splashFactory: showHoverEffect ? InkRipple.splashFactory : NoSplash.splashFactory,
              highlightColor: showHoverEffect ? Colors.black.withOpacity(0.05) : Colors.transparent,
              child: child,
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getAdaptivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(16);
      case ScreenSize.tablet:
        return const EdgeInsets.all(20);
      case ScreenSize.desktop:
        return const EdgeInsets.all(24);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.all(28);
    }
  }

  double _getAdaptiveBorderRadius(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 12;
      case ScreenSize.tablet:
        return 14;
      case ScreenSize.desktop:
        return 16;
      case ScreenSize.largeDesktop:
        return 18;
    }
  }

  double _getAdaptiveElevation(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 4;
      case ScreenSize.desktop:
        return 6;
      case ScreenSize.largeDesktop:
        return 8;
    }
  }

  List<BoxShadow> _getAdaptiveBoxShadow(ScreenSize screenSize, double elevation) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const AdaptiveText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final defaultStyle = _getAdaptiveTextStyle(screenSize);
        final combinedStyle = defaultStyle.merge(style);
        
        return Text(
          text,
          style: combinedStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          semanticsLabel: semanticsLabel,
        );
      },
    );
  }

  TextStyle _getAdaptiveTextStyle(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const TextStyle(fontSize: 14, height: 1.4);
      case ScreenSize.tablet:
        return const TextStyle(fontSize: 15, height: 1.4);
      case ScreenSize.desktop:
        return const TextStyle(fontSize: 16, height: 1.5);
      case ScreenSize.largeDesktop:
        return const TextStyle(fontSize: 17, height: 1.5);
    }
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? child;
  final bool isLoading;
  final bool showLoadingIndicator;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const AdaptiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style,
    this.child,
    this.isLoading = false,
    this.showLoadingIndicator = true,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final defaultHeight = _getAdaptiveHeight(screenSize);
        final defaultPadding = _getAdaptivePadding(screenSize);
        final defaultFontSize = _getAdaptiveFontSize(screenSize);
        
        return SizedBox(
          width: width,
          height: height ?? defaultHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: (style ?? ElevatedButton.styleFrom()).copyWith(
              padding: padding ?? defaultPadding,
              textStyle: TextStyle(fontSize: defaultFontSize),
            ),
            child: isLoading && showLoadingIndicator
                ? _buildLoadingIndicator()
                : child ??
                    Text(
                      text,
                      style: TextStyle(fontSize: defaultFontSize),
                    ),
          ),
        );
      },
    );
  }

  double _getAdaptiveHeight(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 44;
      case ScreenSize.tablet:
        return 48;
      case ScreenSize.desktop:
        return 52;
      case ScreenSize.largeDesktop:
        return 56;
    }
  }

  EdgeInsets _getAdaptivePadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ScreenSize.largeDesktop:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 18);
    }
  }

  double _getAdaptiveFontSize(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 14;
      case ScreenSize.tablet:
        return 15;
      case ScreenSize.desktop:
        return 16;
      case ScreenSize.largeDesktop:
        return 17;
    }
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white,
        ),
      ),
    );
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const AdaptiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, screenSize, constraints) {
        final defaultElevation = _getAdaptiveElevation(screenSize);
        final titleSpacing = _getTitleSpacing(screenSize);
        
        return AppBar(
          title: _buildTitle(screenSize),
          actions: _buildActions(screenSize),
          leading: leading,
          centerTitle: centerTitle,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation ?? defaultElevation,
          titleSpacing: titleSpacing,
          bottom: bottom,
        );
      },
    );
  }

  Widget _buildTitle(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      case ScreenSize.tablet:
        return Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
    }
  }

  List<Widget>? _buildActions(ScreenSize screenSize) {
    if (actions == null) return null;
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return actions!.take(2).toList(); // Show max 2 actions on mobile
      case ScreenSize.tablet:
        return actions!.take(3).toList(); // Show max 3 actions on tablet
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return actions; // Show all actions on desktop
    }
  }

  double _getTitleSpacing(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 20;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 24;
    }
  }

  double _getAdaptiveElevation(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 4;
      case ScreenSize.desktop:
      case ScreenSize.largeDesktop:
        return 6;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class AdaptiveSpacing {
  static double getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1600) return 40;
    if (screenWidth >= 1200) return 32;
    if (screenWidth >= 768) return 24;
    return 16;
  }

  static double getVerticalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1600) return 32;
    if (screenWidth >= 1200) return 24;
    if (screenWidth >= 768) return 20;
    return 16;
  }

  static double getCardSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1600) return 24;
    if (screenWidth >= 1200) return 20;
    if (screenWidth >= 768) return 16;
    return 12;
  }

  static double getSectionSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1600) return 48;
    if (screenWidth >= 1200) return 40;
    if (screenWidth >= 768) return 32;
    return 24;
  }
}

class AdaptiveBreakpoints {
  static const double mobile = 767;
  static const double tablet = 1023;
  static const double desktop = 1199;
  static const double largeDesktop = 1599;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobile && width <= tablet;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > tablet && width <= desktop;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > desktop;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobile;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobile && width <= desktop;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > desktop;
  }
}
