import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Glassmorphic Theme with advanced animations and effects
class EnhancedGlassmorphicTheme {
  static const double defaultBlur = 10.0;
  static const double defaultOpacity = 0.1;
  static const double defaultBorderOpacity = 0.2;
  static const Color defaultBorderColor = Colors.white;
  static const Color defaultShadowColor = Colors.black;

  /// Create glassmorphic container with enhanced effects
  static Widget buildEnhancedGlassContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? blur,
    double? opacity,
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
    bool isAnimated = true,
    Duration? animationDuration,
    bool enableGlow = false,
    bool enableGradient = false,
    Gradient? gradient,
  }) {
    return _GlassmorphicContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      blur: blur,
      opacity: opacity,
      boxShadow: boxShadow,
      onTap: onTap,
      isAnimated: isAnimated,
      animationDuration: animationDuration,
      enableGlow: enableGlow,
      enableGradient: enableGradient,
      gradient: gradient,
      child: child,
    );
  }

  /// Create animated glassmorphic button with ripple effects
  static Widget buildAnimatedGlassButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? width,
    double? height,
    double? borderRadius,
    bool isLoading = false,
    bool isDisabled = false,
    Duration? animationDuration,
    bool enableRipple = true,
    bool enableScale = true,
    bool enableGlow = false,
  }) {
    return _AnimatedGlassButton(
      child: child,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      width: width,
      height: height,
      borderRadius: borderRadius,
      isLoading: isLoading,
      isDisabled: isDisabled,
      animationDuration: animationDuration,
      enableRipple: enableRipple,
      enableScale: enableScale,
      enableGlow: enableGlow,
    );
  }

  /// Create floating glassmorphic card with 3D effect
  static Widget buildFloatingGlassCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? elevation,
