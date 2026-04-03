import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium Slate & Indigo Glassmorphic Design System for VedantaTrade
class PremiumGlassmorphicTheme {
  // Core Color Palette - Slate & Indigo
  static const Color _slate50 = Color(0xFFF8FAFC);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _slate200 = Color(0xFFE2E8F0);
  static const Color _slate300 = Color(0xFFCBD5E1);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate600 = Color(0xFF475569);
  static const Color _slate700 = Color(0xFF334155);
  static const Color _slate800 = Color(0xFF1E293B);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate950 = Color(0xFF020617);

  static const Color _indigo50 = Color(0xFFEEF2FF);
  static const Color _indigo100 = Color(0xFFE0E7FF);
  static const Color _indigo200 = Color(0xFFC7D2FE);
  static const Color _indigo300 = Color(0xFFA5B4FC);
  static const Color _indigo400 = Color(0xFF818CF8);
  static const Color _indigo500 = Color(0xFF6366F1);
  static const Color _indigo600 = Color(0xFF4F46E5);
  static const Color _indigo700 = Color(0xFF4338CA);
  static const Color _indigo800 = Color(0xFF3730A3);
  static const Color _indigo900 = Color(0xFF312E81);
  static const Color _indigo950 = Color(0xFF1E1B4B);

  // Role-based Colors with Indigo Accents
  static const Color adminColor = _indigo600;
  static const Color mrColor = _indigo500;
  static const Color doctorColor = _indigo400;
  static const Color stockistColor = _indigo700;
  static const Color retailerColor = _indigo800;
  static const Color accountantColor = _indigo900;

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);

  // Background Colors
  static const Color backgroundDark = _slate950;
  static const Color surfaceDark = _slate900;
  static const Color surfaceLight = _slate800;
  static const Color cardBackground = Color(0x1A1E293B); // 10% slate900

  // Text Colors
  static const Color textPrimary = _slate50;
  static const Color textSecondary = _slate400;
  static const Color textTertiary = _slate500;
  static const Color textDisabled = _slate600;

  // Border Colors
  static const Color borderLight = Color(0x1A475569); // 10% slate600
  static const Color borderMedium = Color(0x33475569); // 20% slate600
  static const Color borderDark = Color(0x4D475569); // 30% slate600

  // Glassmorphic Properties
  static const double glassOpacity = 0.1;
  static const double glassBlur = 12.0;
  static const double glassBorderWidth = 1.0;
  static const double glassBorderOpacity = 0.2;

  // Shadow Properties
  static const double shadowBlur = 20.0;
  static const double shadowSpread = 0.0;
  static const Color shadowColor = Color(0x40000000); // 25% black

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;

  // Typography
  static const String fontFamily = 'Inter';
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSize3xl = 30.0;
  static const double fontSize4xl = 36.0;

  // Getters for dynamic values
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminColor;
      case 'mr':
      case 'medical_representative':
        return mrColor;
      case 'doctor':
        return doctorColor;
      case 'stockist':
        return stockistColor;
      case 'retailer':
        return retailerColor;
      case 'accountant':
        return accountantColor;
      default:
        return indigo600;
    }
  }

  static Color getGlassColor({double opacity = glassOpacity}) {
    return _slate900.withOpacity(opacity);
  }

  static Color getGlassBorderColor({double opacity = glassBorderOpacity}) {
    return _slate600.withOpacity(opacity);
  }

  // Glassmorphic Decorations
  static BoxDecoration getGlassDecoration({
    Color? color,
    Color? borderColor,
    double? borderRadius,
    double? blur,
    double? borderWidth,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? getGlassColor(),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
      border: Border.all(
        color: borderColor ?? getGlassBorderColor(),
        width: borderWidth ?? glassBorderWidth,
      ),
      boxShadow: withShadow ? [
        BoxShadow(
          color: shadowColor,
          blurRadius: blur ?? shadowBlur,
          spreadRadius: shadowSpread,
        ),
      ] : null,
    );
  }

  // Glassmorphic Input Decoration
  static InputDecoration getInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool filled = true,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: textTertiary,
        fontSize: fontSizeSm,
        fontFamily: fontFamily,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: filled,
      fillColor: getGlassColor(opacity: 0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: getGlassBorderColor(),
          width: glassBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: getGlassBorderColor(),
          width: glassBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: indigo500,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 2.0,
        ),
      ),
    );
  }

  // Glassmorphic Card
  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    Color? borderColor,
    double? borderRadius,
    double? blur,
    bool withShadow = true,
    VoidCallback? onTap,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: getGlassDecoration(
        color: color,
        borderColor: borderColor,
        borderRadius: borderRadius,
        blur: blur,
        withShadow: withShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(spacingMd),
            child: child,
          ),
        ),
      ),
    );
  }

  // Glassmorphic Button
  static Widget glassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
    bool disabled = false,
    double? width,
    double? height,
  }) {
    final buttonColor = backgroundColor ?? indigo600;
    final textColor = foregroundColor ?? textPrimary;
    final isDisabled = disabled || isLoading;

    return Container(
      width: width,
      height: height,
      decoration: getGlassDecoration(
        color: isDisabled ? textDisabled.withOpacity(0.2) : buttonColor.withOpacity(0.8),
        borderColor: borderColor ?? getGlassBorderColor(),
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: spacingLg,
              vertical: spacingMd,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: textPrimary,
                        strokeWidth: 2.0,
                      ),
                    )
                  : DefaultTextStyle(
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSizeSm,
                        fontWeight: FontWeight.w600,
                        fontFamily: fontFamily,
                      ),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Glassmorphic Stat Card
  static Widget glassStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return glassCard(
      padding: padding ?? const EdgeInsets.all(spacingMd),
      margin: margin,
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(spacingSm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: spacingMd),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: fontSizeXxl,
              fontWeight: FontWeight.w700,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: spacingXs),
          Text(
            title,
            style: const TextStyle(
              color: textSecondary,
              fontSize: fontSizeSm,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // Glassmorphic List Item
  static Widget glassListItem({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return glassCard(
      padding: padding ?? const EdgeInsets.all(spacingMd),
      margin: margin ?? const EdgeInsets.only(bottom: spacingSm),
      onTap: onTap,
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(spacingSm),
              decoration: BoxDecoration(
                color: (iconColor ?? indigo500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(radiusSm),
              ),
              child: Icon(
                leadingIcon,
                color: iconColor ?? indigo500,
                size: 20,
              ),
            ),
            const SizedBox(width: spacingMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: fontSizeMd,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: spacingXs),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: fontSizeSm,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Glassmorphic Background
  static Widget glassBackground({
    required Widget child,
    List<Color>? gradientColors,
    double? opacity,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ?? [
            _slate950,
            _slate900,
            _indigo950.withOpacity(0.3),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity ?? 0.02),
          ),
          child: child,
        ),
      ),
    );
  }

  // Glassmorphic Modal
  static Widget glassModal({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(spacingLg),
      decoration: getGlassDecoration(
        color: surfaceDark.withOpacity(0.95),
        borderColor: getGlassBorderColor(opacity: 0.3),
        borderRadius: borderRadius ?? radiusXl,
        blur: 25.0,
      ),
      child: child,
    );
  }

  // Glassmorphic AppBar
  static PreferredSizeWidget glassAppBar({
    required String title,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    bool centerTitle = true,
  }) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? textPrimary,
          fontSize: fontSizeLg,
          fontWeight: FontWeight.w700,
          fontFamily: fontFamily,
        ),
      ),
      backgroundColor: backgroundColor ?? surfaceDark.withOpacity(0.8),
      foregroundColor: foregroundColor ?? textPrimary,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surfaceDark.withOpacity(0.9),
              surfaceDark.withOpacity(0.7),
            ],
          ),
        ),
      ),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  // Glassmorphic Floating Action Button
  static Widget glassFab({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    double? size,
    bool extended = false,
    String? label,
  }) {
    final fabSize = size ?? 56.0;
    final bgColor = backgroundColor ?? indigo600;

    if (extended && label != null) {
      return Container(
        height: 48,
        decoration: getGlassDecoration(
          color: bgColor.withOpacity(0.9),
          borderRadius: radiusXl,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radiusXl),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: spacingLg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                  const SizedBox(width: spacingSm),
                  Text(
                    label,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: fontSizeSm,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: fabSize,
      height: fabSize,
      decoration: getGlassDecoration(
        color: bgColor.withOpacity(0.9),
        borderRadius: radiusFull,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radiusFull),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: foregroundColor ?? textPrimary,
                fontSize: fontSizeMd,
                fontFamily: fontFamily,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // Glassmorphic Tab Bar
  static Widget glassTabBar({
    required List<String> tabs,
    required int selectedIndex,
    required Function(int) onTap,
    Color? selectedColor,
    Color? unselectedColor,
    Color? indicatorColor,
  }) {
    return Container(
      decoration: getGlassDecoration(
        color: surfaceDark.withOpacity(0.6),
        borderColor: getGlassBorderColor(),
        borderRadius: radiusMd,
      ),
      padding: const EdgeInsets.all(spacingXs),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: animationMedium,
                padding: const EdgeInsets.symmetric(vertical: spacingSm),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (selectedColor ?? indigo600).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(radiusSm),
                  border: isSelected 
                      ? Border.all(
                          color: selectedColor ?? indigo600,
                          width: 1.0,
                        )
                      : null,
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                        ? selectedColor ?? indigo600
                        : unselectedColor ?? textSecondary,
                    fontSize: fontSizeSm,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Glassmorphic Chip
  static Widget glassChip({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    Color? selectedColor,
    Color? unselectedColor,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: animationMedium,
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        decoration: getGlassDecoration(
          color: selected 
              ? (selectedColor ?? indigo600).withOpacity(0.2)
              : surfaceDark.withOpacity(0.4),
          borderColor: selected 
              ? selectedColor ?? indigo600
              : getGlassBorderColor(),
          borderRadius: borderRadius ?? radiusXl,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? (selected ? selectedColor ?? indigo600 : textSecondary),
            fontSize: fontSizeSm,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );
  }

  // Glassmorphic Progress Indicator
  static Widget glassProgress({
    required double value,
    Color? color,
    double? height,
    double? borderRadius,
    Color? backgroundColor,
  }) {
    return Container(
      height: height ?? 8.0,
      decoration: BoxDecoration(
        color: backgroundColor ?? surfaceDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(borderRadius ?? radiusFull),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? indigo600,
            borderRadius: BorderRadius.circular(borderRadius ?? radiusFull),
          ),
        ),
      ),
    );
  }

  // Glassmorphic Loading Animation
  static Widget glassLoading({
    Color? color,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 24.0,
      height: size ?? 24.0,
      child: CircularProgressIndicator(
        color: color ?? indigo600,
        strokeWidth: 2.0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  // Glassmorphic Error/Success Message
  static Widget glassMessage({
    required String message,
    required IconData icon,
    required Color color,
    VoidCallback? onClose,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(spacingMd),
      decoration: getGlassDecoration(
        color: color.withOpacity(0.1),
        borderColor: color.withOpacity(0.3),
        borderRadius: borderRadius ?? radiusMd,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: spacingMd),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: textPrimary,
                fontSize: fontSizeSm,
                fontFamily: fontFamily,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: spacingMd),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, color: color, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension methods for easier usage
extension GlassmorphicExtensions on Widget {
  Widget withGlass({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Color? borderColor,
    double? borderRadius,
    double? blur,
    bool withShadow = true,
    VoidCallback? onTap,
  }) {
    return PremiumGlassmorphicTheme.glassCard(
      child: this,
      padding: padding,
      margin: margin,
      color: color,
      borderColor: borderColor,
      borderRadius: borderRadius,
      blur: blur,
      withShadow: withShadow,
      onTap: onTap,
    );
  }
}
