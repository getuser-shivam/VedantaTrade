/// Theme-related constants
class ThemeConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Glassmorphic colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);
  
  // Text colors
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0x99FFFFFF);
  static const Color disabledTextColor = Color(0x66FFFFFF);
  static const Color hintTextColor = Color(0x80FFFFFF);
  
  // Background colors
  static const Color backgroundColor = Color(0xFF0A0A0A);
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF2A2A2A);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Typography
  static const String fontFamily = 'Roboto';
  static const double fontSizeSmall = 12.0;
  static const double fontSizeNormal = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 32.0;
  
  // Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Spacing
  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 999.0;
  
  // Shadows
  static const BoxShadow smallShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4.0,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow mediumShadow = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 8.0,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow largeShadow = BoxShadow(
    color: Color(0x4D000000),
    blurRadius: 16.0,
    offset: Offset(0, 8),
  );
  
  // Glassmorphic shadow
  static const BoxShadow glassShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20.0,
    offset: Offset(0, 10),
    spreadRadius: 0.0,
  );
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);
  
  // Animation curves
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
  
  // Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;
  
  // Component heights
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double cardMinHeight = 120.0;
  static const double listItemHeight = 72.0;
  
  // Icon sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;
  
  // Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityHint = 0.60;
  static const double opacitySecondary = 0.70;
  static const double opacityPrimary = 0.87;
  static const double opacityFull = 1.0;
  
  // Glassmorphic opacity
  static const double glassOpacity = 0.10;
  static const double glassBorderOpacity = 0.20;
  static const double glassShadowOpacity = 0.10;
  
  // Private constructor to prevent instantiation
  ThemeConstants._();
}
