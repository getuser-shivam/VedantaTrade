import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Slate & Indigo Color Palette
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3); // Dark Indigo
  static const Color primaryLight = Color(0xFF6366F1); // Light Indigo
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFFF43F5E); // Rose
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Role Colors (Premium Variants)
  static const Color adminColor = Color(0xFF4F46E5); // Indigo
  static const Color mrColor = Color(0xFF06B6D4); // Cyan
  static const Color accountantColor = Color(0xFF8B5CF6); // Violet
  static const Color doctorColor = Color(0xFF3B82F6); // Blue
  static const Color stockistColor = Color(0xFFF59E0B); // Amber
  static const Color retailerColor = Color(0xFFF43F5E); // Rose

  // Premium Dark Theme Surfaces (Slate)
  static const Color bgDark = Color(0xFF0F172A); // Slate-900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate-800
  static const Color cardDark = Color(0xFF334155); // Slate-700
  static const Color dividerDark = Color(0xFF475569); // Slate-600
  static const Color glassSurface = Color(0x1AFFFFFF); // Glass effect
  static const Color glassBorder = Color(0x33FFFFFF); // Glass border

  // Enhanced Glassmorphic Colors
  static const Color glassBg = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  static const Color glassShadow = Color(0x1A000000);
  static const Color glassHighlight = Color(0x0DFFFFFF);
  static const Color glassReflection = Color(0x26FFFFFF);

  // Legacy colors for backward compatibility
  static const Color background = bgDark;
  static const Color cardColor = cardDark;

  // Enhanced Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF3730A3), Color(0xFF312E81)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2), Color(0x0E7490)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48), Color(0xFFBE123C)],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF), Color(0x0AFFFFFF)],
  );
  
  static const LinearGradient premiumGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color shadowGlow = Color(0x33FFFFFF);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: bgDark,
    cardTheme: CardThemeData(
      color: glassBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: glassBorderLight, width: 1),
      ),
      shadowColor: shadowMedium,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: glassBg,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: premiumGlassGradient,
          border: Border(
            bottom: BorderSide(color: glassBorderLight, width: 1),
          ),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 4,
        shadowColor: shadowMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        side: const BorderSide(color: primaryLight, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardDark,
      selectedColor: primary.withOpacity(0.3),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: dividerDark, width: 1),
    ),
    dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surfaceDark,
      selectedIconTheme: const IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.4)),
      selectedLabelTextStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primary,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: primary,
      labelColor: primary,
      unselectedLabelColor: Colors.white.withOpacity(0.6),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: shadowDark,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      circularTrackColor: dividerDark,
      linearTrackColor: dividerDark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primary;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primary.withOpacity(0.5);
        }
        return dividerDark;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primary;
        }
        return Colors.white;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: dividerDark,
      thumbColor: primary,
      overlayColor: primary.withOpacity(0.2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.25,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(primary: primary, secondary: secondary),
    textTheme: GoogleFonts.interTextTheme(),
  );

  // Enhanced Input Decoration
  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintText: hint,
    );
  }

  // Enhanced Glassmorphic Decoration
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: premiumGlassGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? glassBorderLight,
        width: borderWidth ?? 1,
      ),
      boxShadow: shadows ?? [
        BoxShadow(
          color: shadowMedium,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Premium Card Decoration
  static BoxDecoration premiumCardDecoration({
    BorderRadius? borderRadius,
    Color? borderColor,
    LinearGradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? glassGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? glassBorderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: shadowMedium,
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Enhanced Button Styles
  static ButtonStyle premiumButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primary,
      foregroundColor: foregroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(12)),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: textStyle ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      elevation: 4,
      shadowColor: shadowMedium,
    );
  }

  // Glass Button Style
  static ButtonStyle glassButtonStyle({
    Color? borderColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: borderColor ?? glassBorderLight, width: 1),
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(12)),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      backgroundColor: glassBg,
    );
  }

  // Enhanced Shadow Styles
  static List<BoxShadow> get cardShadows => [
    BoxShadow(
      color: shadowMedium,
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedCardShadows => [
    BoxShadow(
      color: shadowDark,
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: shadowMedium,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleShadows => [
    BoxShadow(
      color: shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Spacing Constants
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius Constants
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(20));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(100));
}
