import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Font Family
  static const String primaryFont = 'Inter';
  static const String secondaryFont = 'Poppins';

  // Text Styles
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static TextStyle get heading5 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static TextStyle get heading6 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  // Body Text Styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );

  // Label Text Styles
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.25,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Caption Text Styles
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );

  // Button Text Styles
  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonTextSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // Custom Text Styles with Color
  static TextStyle heading1WithColor(Color color) => heading1.copyWith(color: color);
  static TextStyle heading2WithColor(Color color) => heading2.copyWith(color: color);
  static TextStyle heading3WithColor(Color color) => heading3.copyWith(color: color);
  static TextStyle heading4WithColor(Color color) => heading4.copyWith(color: color);
  static TextStyle heading5WithColor(Color color) => heading5.copyWith(color: color);
  static TextStyle heading6WithColor(Color color) => heading6.copyWith(color: color);

  static TextStyle bodyLargeWithColor(Color color) => bodyLarge.copyWith(color: color);
  static TextStyle bodyMediumWithColor(Color color) => bodyMedium.copyWith(color: color);
  static TextStyle bodySmallWithColor(Color color) => bodySmall.copyWith(color: color);

  static TextStyle labelLargeWithColor(Color color) => labelLarge.copyWith(color: color);
  static TextStyle labelMediumWithColor(Color color) => labelMedium.copyWith(color: color);
  static TextStyle labelSmallWithColor(Color color) => labelSmall.copyWith(color: color);

  static TextStyle captionWithColor(Color color) => caption.copyWith(color: color);
  static TextStyle buttonTextWithColor(Color color) => buttonText.copyWith(color: color);

  // Dark Theme Text Styles
  static TextStyle get darkHeading1 => heading1.copyWith(color: const Color(0xFFFFFFFF));
  static TextStyle get darkHeading2 => heading2.copyWith(color: const Color(0xFFFFFFFF));
  static TextStyle get darkHeading3 => heading3.copyWith(color: const Color(0xFFFFFFFF));
  static TextStyle get darkHeading4 => heading4.copyWith(color: const Color(0xFFFFFFFF));
  static TextStyle get darkHeading5 => heading5.copyWith(color: const Color(0xFFFFFFFF));
  static TextStyle get darkHeading6 => heading6.copyWith(color: const Color(0xFFFFFFFF));

  static TextStyle get darkBodyLarge => bodyLarge.copyWith(color: const Color(0xFFE2E8F0));
  static TextStyle get darkBodyMedium => bodyMedium.copyWith(color: const Color(0xFFE2E8F0));
  static TextStyle get darkBodySmall => bodySmall.copyWith(color: const Color(0xFF94A3B8));

  static TextStyle get darkLabelLarge => labelLarge.copyWith(color: const Color(0xFFE2E8F0));
  static TextStyle get darkLabelMedium => labelMedium.copyWith(color: const Color(0xFF94A3B8));
  static TextStyle get darkLabelSmall => labelSmall.copyWith(color: const Color(0xFF94A3B8));

  static TextStyle get darkCaption => caption.copyWith(color: const Color(0xFF94A3B8));
  static TextStyle get darkButtonText => buttonText.copyWith(color: const Color(0xFFFFFFFF));

  // Utility Methods
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }

  // Text Theme Builder
  static TextTheme buildTextTheme({bool isDark = false}) {
    final primaryColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1F2937);
    final secondaryColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF6B7280);
    final tertiaryColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF);

    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: heading1.copyWith(color: primaryColor),
      displayMedium: heading2.copyWith(color: primaryColor),
      displaySmall: heading3.copyWith(color: primaryColor),
      headlineLarge: heading4.copyWith(color: primaryColor),
      headlineMedium: heading5.copyWith(color: primaryColor),
      headlineSmall: heading6.copyWith(color: primaryColor),
      titleLarge: bodyLarge.copyWith(color: primaryColor),
      titleMedium: bodyMedium.copyWith(color: primaryColor),
      titleSmall: bodySmall.copyWith(color: primaryColor),
      bodyLarge: bodyLarge.copyWith(color: secondaryColor),
      bodyMedium: bodyMedium.copyWith(color: secondaryColor),
      bodySmall: bodySmall.copyWith(color: tertiaryColor),
      labelLarge: labelLarge.copyWith(color: primaryColor),
      labelMedium: labelMedium.copyWith(color: secondaryColor),
      labelSmall: labelSmall.copyWith(color: tertiaryColor),
    );
  }
}
