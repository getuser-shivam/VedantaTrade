import 'package:flutter/material.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenSize) builder;

  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = _getScreenType(constraints.maxWidth);
        return builder(context, screenSize);
      },
    );
  }

  ScreenType _getScreenType(double width) {
    if (width < 600) return ScreenType.mobile;
    if (width < 1024) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        switch (screenSize) {
          case ScreenType.mobile:
            return mobile;
          case ScreenType.tablet:
            return tablet ?? mobile;
          case ScreenType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        int columns;
        switch (screenSize) {
          case ScreenType.mobile:
            columns = mobileColumns;
            break;
          case ScreenType.tablet:
            columns = tabletColumns;
            break;
          case ScreenType.desktop:
            columns = desktopColumns;
            break;
        }

        return GridView.count(
          crossAxisCount: columns,
          spacing: spacing,
          runSpacing: runSpacing,
          padding: padding,
          children: children,
        );
      },
    );
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const AdaptiveContainer({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        double containerMaxWidth;
        EdgeInsets containerPadding;

        switch (screenSize) {
          case ScreenType.mobile:
            containerMaxWidth = maxWidth ?? 600;
            containerPadding = padding ?? const EdgeInsets.all(16);
            break;
          case ScreenType.tablet:
            containerMaxWidth = maxWidth ?? 800;
            containerPadding = padding ?? const EdgeInsets.all(24);
            break;
          case ScreenType.desktop:
            containerMaxWidth = maxWidth ?? 1200;
            containerPadding = padding ?? const EdgeInsets.all(32);
            break;
        }

        return Container(
          width: double.infinity,
          alignment: alignment,
          padding: containerPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: containerMaxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class AdaptiveAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double? elevation;

  const AdaptiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        switch (screenSize) {
          case ScreenType.mobile:
            return AppBar(
              title: Text(title),
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              bottom: bottom,
              backgroundColor: backgroundColor,
              elevation: elevation,
            );
          case ScreenType.tablet:
          case ScreenType.desktop:
            return AppBar(
              title: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: actions,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              bottom: bottom,
              backgroundColor: backgroundColor,
              elevation: elevation,
              centerTitle: false,
            );
        }
      },
    );
  }
}

class AdaptiveNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Color? backgroundColor;
  final bool extended;

  const AdaptiveNavigationRail({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.extended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        switch (screenSize) {
          case ScreenType.mobile:
            return NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              backgroundColor: backgroundColor,
            );
          case ScreenType.tablet:
          case ScreenType.desktop:
            return NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations.map((dest) {
                return NavigationRailDestination(
                  icon: dest.icon,
                  label: Text(dest.label),
                );
              }).toList(),
              backgroundColor: backgroundColor,
              extended: extended,
            );
        }
      },
    );
  }
}

class AdaptiveDrawer extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;

  const AdaptiveDrawer({
    Key? key,
    required this.child,
    this.width,
    this.padding,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        double drawerWidth;
        EdgeInsets drawerPadding;

        switch (screenSize) {
          case ScreenType.mobile:
            drawerWidth = width ?? 280;
            drawerPadding = padding ?? const EdgeInsets.all(16);
            break;
          case ScreenType.tablet:
            drawerWidth = width ?? 320;
            drawerPadding = padding ?? const EdgeInsets.all(20);
            break;
          case ScreenType.desktop:
            drawerWidth = width ?? 360;
            drawerPadding = padding ?? const EdgeInsets.all(24);
            break;
        }

        return Container(
          width: drawerWidth,
          padding: drawerPadding,
          color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType buttonType;
  final ButtonSize buttonSize;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool fullWidth;

  const AdaptiveButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.buttonType = ButtonType.primary,
    this.buttonSize = ButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        double height;
        double fontSize;
        EdgeInsets padding;

        switch (screenSize) {
          case ScreenType.mobile:
            switch (buttonSize) {
              case ButtonSize.small:
                height = 32;
                fontSize = 12;
                padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
                break;
              case ButtonSize.medium:
                height = 40;
                fontSize = 14;
                padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
                break;
              case ButtonSize.large:
                height = 48;
                fontSize = 16;
                padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
                break;
            }
            break;
          case ScreenType.tablet:
            switch (buttonSize) {
              case ButtonSize.small:
                height = 36;
                fontSize = 13;
                padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
                break;
              case ButtonSize.medium:
                height = 44;
                fontSize = 15;
                padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14);
                break;
              case ButtonSize.large:
                height = 52;
                fontSize = 17;
                padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 18);
                break;
            }
            break;
          case ScreenType.desktop:
            switch (buttonSize) {
              case ButtonSize.small:
                height = 40;
                fontSize = 14;
                padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
                break;
              case ButtonSize.medium:
                height = 48;
                fontSize = 16;
                padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
                break;
              case ButtonSize.large:
                height = 56;
                fontSize = 18;
                padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
                break;
            }
            break;
        }

        Widget buttonChild = Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize * 1.2),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        );

        switch (buttonType) {
          case ButtonType.primary:
            return ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
                foregroundColor: textColor ?? Colors.white,
                minimumSize: Size(fullWidth ? double.infinity : 0, height),
                padding: padding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: buttonChild,
            );
          case ButtonType.secondary:
            return OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
                minimumSize: Size(fullWidth ? double.infinity : 0, height),
                padding: padding,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: buttonChild,
            );
          case ButtonType.text:
            return TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
                minimumSize: Size(fullWidth ? double.infinity : 0, height),
                padding: padding,
              ),
              child: buttonChild,
            );
        }
      },
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText({
    Key? key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        double fontSize;
        FontWeight fontWeight;

        switch (screenSize) {
          case ScreenType.mobile:
            fontSize = style?.fontSize ?? 14;
            fontWeight = style?.fontWeight ?? FontWeight.normal;
            break;
          case ScreenType.tablet:
            fontSize = (style?.fontSize ?? 14) * 1.1;
            fontWeight = style?.fontWeight ?? FontWeight.normal;
            break;
          case ScreenType.desktop:
            fontSize = (style?.fontSize ?? 14) * 1.2;
            fontWeight = style?.fontWeight ?? FontWeight.normal;
            break;
        }

        return Text(
          text,
          style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
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
}
