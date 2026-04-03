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

  // Glassmorphic Colors
  static const Color glassBg = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

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
          gradient: glassGradient,
          border: Border(
            bottom: BorderSide(color: glassBorderLight, width: 1),
          ),
        ),
      ),
    ),
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dividerDark, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 2)),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
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
    ),
    dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surfaceDark,
      selectedIconTheme: const IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.4)),
      selectedLabelTextStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(primary: primary, secondary: secondary),
    textTheme: GoogleFonts.interTextTheme(),
  );
}
