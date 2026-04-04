import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Theme System for VedantaTrade
/// Provides comprehensive theming with glassmorphic design, animations, and accessibility
class EnhancedTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFF2E7D32); // Material Green 800
  static const Color secondaryColor = Color(0xFF1976D2); // Material Blue 700
  static const Color accentColor = Color(0xFFFF6F00); // Material Amber 700
  static const Color errorColor = Color(0xFFD32F2F); // Material Red 700
  static const Color warningColor = Color(0xFFFFA000); // Material Amber 700
  static const Color successColor = Color(0xFF388E3C); // Material Green 700

  // Glassmorphic Colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x4DFFFFFF);
  static const Color glassSurface = Color(0x2AFFFFFF);
  
  // Surface Colors
  static const Color surfaceColor = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF1E1E1E);
  static const Color onSurfaceColor = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFB3B3B3);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF4D4D4D);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF6F00),
    Color(0xFFFFB300),
  ];

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0D000000);

  // Spacing System
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border Radius System
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;

  // Typography System
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    color: textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: textTertiary,
  );

  // Button Styles
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: textPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.25,
    color: textPrimary,
  );

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationSlower = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBounceIn = Curves.bounceIn;
  static const Curve curveBounceOut = Curves.bounceOut;
  static const Curve curveElasticOut = Curves.elasticOut;

  // Elevation System
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;

  // Breakpoints for Responsive Design
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        surfaceVariant: surfaceVariant,
        onSurface: onSurfaceColor,
        onSurfaceVariant: onSurfaceVariant,
      ),
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: heading4,
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        color: glassBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          elevation: elevation4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: glassBackground,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: glassBackground,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: bodySmall.copyWith(color: textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing12,
          vertical: spacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius20),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      textTheme: const TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineLarge: heading4,
        headlineMedium: heading5,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelSmall: caption,
      ),
    );
  }

  // Glassmorphic Decoration
  static BoxDecoration glassDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = radius16,
    double borderWidth = 1,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? glassBorder,
        width: borderWidth,
      ),
      boxShadow: boxShadow ?? [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Gradient Decoration
  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double borderRadius = radius16,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Shadow Styles
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Responsive Helper Methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointTablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointTablet;
  }

  // Accessibility Helper Methods
  static Color getContrastColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }
}
