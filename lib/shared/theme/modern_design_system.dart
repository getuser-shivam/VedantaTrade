import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class ModernDesignSystem {
  // Color Palette
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  static const Color secondaryColor = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF2E7D32);
  
  static const Color accentColor = Color(0xFFFF6F00);
  static const Color accentLight = Color(0xFFFF8E00);
  static const Color accentDark = Color(0xFFE65100);
  
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Typography
  static const String fontFamily = 'Inter';
  static const String fontFamilySecondary = 'Roboto';
  
  // Spacing
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
  
  // Border Radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;
  
  // Shadows
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> heavyShadow = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryColor],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accentColor],
  );
  
  // Animations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
}

class ModernTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.3,
    letterSpacing: -0.25,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.4,
    letterSpacing: -0.15,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.4,
    letterSpacing: -0.1,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.4,
    letterSpacing: -0.05,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.5,
    letterSpacing: 0.0,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.5,
    letterSpacing: 0.0,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.5,
    letterSpacing: 0.1,
  );
  
  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.4,
    letterSpacing: 0.25,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: ModernDesignSystem.fontFamily,
    height: 1.6,
    letterSpacing: 1.5,
  );
}

class ModernButtonStyles {
  // Primary Button
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: ModernDesignSystem.primaryColor,
    foregroundColor: ModernDesignSystem.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing24,
      vertical: ModernDesignSystem.spacing16,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
  
  static ButtonStyle primaryButtonHovered = ElevatedButton.styleFrom(
    backgroundColor: ModernDesignSystem.primaryLight,
    foregroundColor: ModernDesignSystem.white,
    elevation: 4,
    shadowColor: ModernDesignSystem.primaryColor.withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing24,
      vertical: ModernDesignSystem.spacing16,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
  
  // Secondary Button
  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: ModernDesignSystem.secondaryColor,
    foregroundColor: ModernDesignSystem.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing24,
      vertical: ModernDesignSystem.spacing16,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
  
  // Outlined Button
  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: ModernDesignSystem.primaryColor,
    side: const BorderSide(
      color: ModernDesignSystem.primaryColor,
      width: 2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing24,
      vertical: ModernDesignSystem.spacing16,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
  
  // Text Button
  static ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: ModernDesignSystem.primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing16,
      vertical: ModernDesignSystem.spacing12,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
  
  // Ghost Button
  static ButtonStyle ghostButton = TextButton.styleFrom(
    foregroundColor: ModernDesignSystem.grey600,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing16,
      vertical: ModernDesignSystem.spacing12,
    ),
    textStyle: ModernTextStyles.buttonMedium,
  );
}

class ModernCardStyles {
  // Default Card
  static BoxDecoration defaultCard = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.lightShadow,
    border: Border.all(
      color: ModernDesignSystem.grey200,
      width: 1,
    ),
  );
  
  // Elevated Card
  static BoxDecoration elevatedCard = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.mediumShadow,
    border: Border.all(
      color: ModernDesignSystem.grey200,
      width: 1,
    ),
  );
  
  // Interactive Card
  static BoxDecoration interactiveCard = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.lightShadow,
    border: Border.all(
      color: ModernDesignSystem.grey300,
      width: 1,
    ),
  );
  
  static BoxDecoration interactiveCardHovered = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.mediumShadow,
    border: Border.all(
      color: ModernDesignSystem.primaryColor.withOpacity(0.3),
      width: 2,
    ),
  );
  
  // Selected Card
  static BoxDecoration selectedCard = BoxDecoration(
    color: ModernDesignSystem.primaryColor.withOpacity(0.05),
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.mediumShadow,
    border: Border.all(
      color: ModernDesignSystem.primaryColor,
      width: 2,
    ),
  );
}

class ModernInputStyles {
  // Default Input
  static InputDecoration defaultInput = InputDecoration(
    filled: true,
    fillColor: ModernDesignSystem.grey50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
      borderSide: const BorderSide(
        color: ModernDesignSystem.grey300,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
      borderSide: const BorderSide(
        color: ModernDesignSystem.grey300,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
      borderSide: const BorderSide(
        color: ModernDesignSystem.primaryColor,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
      borderSide: const BorderSide(
        color: ModernDesignSystem.errorColor,
        width: 2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
      borderSide: const BorderSide(
        color: ModernDesignSystem.errorColor,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing16,
      vertical: ModernDesignSystem.spacing16,
    ),
    hintStyle: const TextStyle(
      color: ModernDesignSystem.grey500,
      fontSize: 16,
      fontFamily: ModernDesignSystem.fontFamily,
    ),
    labelStyle: const TextStyle(
      color: ModernDesignSystem.grey600,
      fontSize: 14,
      fontFamily: ModernDesignSystem.fontFamily,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: const TextStyle(
      color: ModernDesignSystem.primaryColor,
      fontSize: 14,
      fontFamily: ModernDesignSystem.fontFamily,
      fontWeight: FontWeight.w500,
    ),
    errorStyle: const TextStyle(
      color: ModernDesignSystem.errorColor,
      fontSize: 12,
      fontFamily: ModernDesignSystem.fontFamily,
    ),
  );
  
  // Search Input
  static InputDecoration searchInput = InputDecoration(
    filled: true,
    fillColor: ModernDesignSystem.grey100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius24),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius24),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ModernDesignSystem.radius24),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: ModernDesignSystem.spacing20,
      vertical: ModernDesignSystem.spacing16,
    ),
    hintStyle: const TextStyle(
      color: ModernDesignSystem.grey500,
      fontSize: 16,
      fontFamily: ModernDesignSystem.fontFamily,
    ),
    prefixIcon: const Icon(
      Icons.search,
      color: ModernDesignSystem.grey500,
      size: 20,
    ),
  );
}

class ModernComponentStyles {
  // App Bar
  static BoxDecoration appBar = BoxDecoration(
    gradient: ModernDesignSystem.primaryGradient,
    boxShadow: ModernDesignSystem.lightShadow,
  );
  
  // Bottom Navigation
  static BoxDecoration bottomNavigation = BoxDecoration(
    color: ModernDesignSystem.white,
    boxShadow: ModernDesignSystem.lightShadow,
    border: Border(
      top: BorderSide(
        color: ModernDesignSystem.grey200,
        width: 1,
      ),
    ),
  );
  
  // Floating Action Button
  static BoxDecoration floatingActionButton = BoxDecoration(
    gradient: ModernDesignSystem.accentGradient,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius24),
    boxShadow: ModernDesignSystem.mediumShadow,
  );
  
  // Chip
  static BoxDecoration chip = BoxDecoration(
    color: ModernDesignSystem.grey100,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius20),
    border: Border.all(
      color: ModernDesignSystem.grey300,
      width: 1,
    ),
  );
  
  static BoxDecoration selectedChip = BoxDecoration(
    color: ModernDesignSystem.primaryColor,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius20),
  );
  
  // Badge
  static BoxDecoration badge = BoxDecoration(
    color: ModernDesignSystem.errorColor,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    boxShadow: ModernDesignSystem.lightShadow,
  );
  
  // Divider
  static BoxDecoration divider = BoxDecoration(
    color: ModernDesignSystem.grey200,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius2),
  );
}

class ModernAnimations {
  // Scale Animation
  static Widget scaleAnimation({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: ModernDesignSystem.bounceCurve,
        ),
      ),
      child: child,
    );
  }
  
  // Fade Animation
  static Widget fadeAnimation({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: ModernDesignSystem.defaultCurve,
        ),
      ),
      child: child,
    );
  }
  
  // Slide Animation
  static Widget slideAnimation({
    required Widget child,
    required Animation<Offset> animation,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: ModernDesignSystem.smoothCurve,
        ),
      ),
      child: child,
    );
  }
  
  // Rotation Animation
  static Widget rotationAnimation({
    required Widget child,
    required Animation<double> animation,
    double turns = 1.0,
  }) {
    return RotationTransition(
      turns: Tween<double>(begin: 0, end: turns).animate(
        CurvedAnimation(
          parent: animation,
          curve: ModernDesignSystem.defaultCurve,
        ),
      ),
      child: child,
    );
  }
}

class ModernMicroInteractions {
  // Hover Effect
  static Widget hoverEffect({
    required Widget child,
    required Widget Function(bool isHovered) builder,
  }) {
    return MouseRegion(
      onEnter: (_) => builder(true),
      onExit: (_) => builder(false),
      child: child,
    );
  }
  
  // Ripple Effect
  static Widget rippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color? splashColor,
    BorderRadius? borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: splashColor ?? ModernDesignSystem.primaryColor.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(ModernDesignSystem.radius12),
        child: child,
      ),
    );
  }
  
  // Pulse Effect
  static Widget pulseEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.1),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // Shimmer Effect
  static Widget shimmerEffect({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            baseColor ?? ModernDesignSystem.grey100,
            highlightColor ?? ModernDesignSystem.grey200,
            baseColor ?? ModernDesignSystem.grey100,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class ModernLayoutStyles {
  // Container Styles
  static BoxDecoration pageContainer = BoxDecoration(
    color: ModernDesignSystem.grey50,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius24),
    boxShadow: ModernDesignSystem.lightShadow,
  );
  
  static BoxDecoration sectionContainer = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius16),
    boxShadow: ModernDesignSystem.lightShadow,
  );
  
  static BoxDecoration modalContainer = BoxDecoration(
    color: ModernDesignSystem.white,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius20),
    boxShadow: ModernDesignSystem.heavyShadow,
  );
  
  // Navigation Styles
  static BoxDecoration navigationItem = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
  );
  
  static BoxDecoration navigationItemSelected = BoxDecoration(
    color: ModernDesignSystem.primaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(ModernDesignSystem.radius12),
    border: Border.all(
      color: ModernDesignSystem.primaryColor.withOpacity(0.3),
      width: 1,
    ),
  );
  
  // Status Colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'delivered':
        return ModernDesignSystem.successColor;
      case 'warning':
      case 'pending':
      case 'processing':
        return ModernDesignSystem.warningColor;
      case 'error':
      case 'failed':
      case 'cancelled':
        return ModernDesignSystem.errorColor;
      case 'info':
      case 'in_transit':
      case 'shipped':
        return ModernDesignSystem.infoColor;
      default:
        return ModernDesignSystem.grey500;
    }
  }
  
  static Color getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'delivered':
        return ModernDesignSystem.successColor.withOpacity(0.1);
      case 'warning':
      case 'pending':
      case 'processing':
        return ModernDesignSystem.warningColor.withOpacity(0.1);
      case 'error':
      case 'failed':
      case 'cancelled':
        return ModernDesignSystem.errorColor.withOpacity(0.1);
      case 'info':
      case 'in_transit':
      case 'shipped':
        return ModernDesignSystem.infoColor.withOpacity(0.1);
      default:
        return ModernDesignSystem.grey100;
    }
  }
}

class ModernAccessibility {
  // Semantic Labels
  static String getSemanticLabel(String type, String content) {
    switch (type.toLowerCase()) {
      case 'button':
        return 'Button: $content';
      case 'link':
        return 'Link: $content';
      case 'image':
        return 'Image: $content';
      case 'input':
        return 'Input field: $content';
      case 'dropdown':
        return 'Dropdown: $content';
      case 'checkbox':
        return 'Checkbox: $content';
      case 'radio':
        return 'Radio button: $content';
      case 'switch':
        return 'Switch: $content';
      default:
        return content;
    }
  }
  
  // Contrast Colors
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? ModernDesignSystem.black : ModernDesignSystem.white;
  }
  
  // Accessible Text Styles
  static TextStyle getAccessibleTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? ModernDesignSystem.grey900,
      fontFamily: ModernDesignSystem.fontFamily,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }
  
  // Accessible Button Sizes
  static double getAccessibleButtonSize() {
    return 48.0; // Minimum touch target size
  }
  
  // Accessible Spacing
  static double getAccessibleSpacing() {
    return 8.0; // Minimum spacing between interactive elements
  }
}
