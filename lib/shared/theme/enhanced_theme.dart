import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Theme System for VedantaTrade
/// Provides modern, accessible, and responsive theming
class EnhancedTheme {
  // Brand Colors for Pharmaceutical Distribution
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1E3A8A);
  
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealLight = Color(0xFF5EEAD4);
  static const Color accentTealDark = Color(0xFF0F766E);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoIndigo = Color(0xFF6366F1);
  
  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  
  // Semantic Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFFCFCFD);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x0F000000);
  static const Color border = Color(0xFFE5E7EB);
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
    );
  }

  // Light Color Scheme
  static ColorScheme get lightColorScheme {
    return ColorScheme.light(
      primary: primaryBlue,
      primaryContainer: primaryBlueLight.withOpacity(0.1),
      secondary: accentTeal,
        secondaryContainer: accentTealLight.withOpacity(0.1),
        surface: surface,
        surfaceVariant: surfaceVariant,
        background: background,
        error: errorRed,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: neutral800,
        onBackground: neutral800,
        outline: neutral300,
        outlineVariant: neutral200,
        shadow: shadow,
        scrim: shadow,
        inverseSurface: neutral800,
        onInverseSurface: Colors.white,
        inversePrimary: primaryBlueLight,
        surfaceTint: primaryBlue,
      );
    }

    // Dark Color Scheme
    static ColorScheme get darkColorScheme {
      return ColorScheme.dark(
        primary: primaryBlueLight,
        primaryContainer: primaryBlueDark.withOpacity(0.3),
        secondary: accentTealLight,
        secondaryContainer: accentTealDark.withOpacity(0.3),
        surface: neutral800,
        surfaceVariant: neutral700,
        background: neutral900,
        error: errorRed,
        onError: Colors.white,
        onPrimary: neutral900,
        onSecondary: neutral900,
        onSurface: neutral100,
        onBackground: neutral100,
        outline: neutral600,
        outlineVariant: neutral700,
        shadow: const Color(0x3F000000),
        scrim: const Color(0x3F000000),
        inverseSurface: neutral100,
        onInverseSurface: neutral900,
        inversePrimary: primaryBlueDark,
        surfaceTint: primaryBlueLight,
      );
    }
      
    // Text Theme
    static TextTheme get _lightTextTheme => _buildTextTheme(Brightness.light);
    static TextTheme get _darkTextTheme => _buildTextTheme(Brightness.dark);
  }
      
  // Build Text Theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light ? neutral800 : neutral100;
    final Color secondaryTextColor = brightness == Brightness.light ? neutral600 : neutral400;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: secondaryTextColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryTextColor,
        height: 1.4,
      ),
    );
  }

  // Custom Colors for Specific Use Cases
  static const Map<String, Color> customColors = {
    'pharmaPrimary': primaryBlue,
    'pharmaSecondary': accentTeal,
    'success': successGreen,
    'warning': warningAmber,
    'error': errorRed,
    'info': infoIndigo,
    'surface': surface,
    'card': cardBackground,
    'border': border,
    'divider': divider,
  };
  
  // Get Color by Name
  static Color getColor(String name) {
    return customColors[name] ?? neutral500;
  }
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [accentTeal, accentTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorRed, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Definitions
  static const BoxShadow cardShadow = BoxShadow(
    color: shadow,
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );
  
  static const BoxShadow elevatedShadow = BoxShadow(
    color: shadow,
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );
  
  static const BoxShadow buttonShadow = BoxShadow(
    color: shadow,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );
}
