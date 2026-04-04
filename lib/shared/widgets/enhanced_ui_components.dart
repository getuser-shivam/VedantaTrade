import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:vedanta_trade/app/theme/app_theme.dart';

/// Enhanced UI/UX Components for Seamless User Experience
class EnhancedUIComponents {
  // Modern Glassmorphic Card with improved animations
  static Widget glassmorphicCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool withAnimation = true,
    bool withHover = true,
    bool withRipple = true,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeInOut,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isPressed = false;

        return MouseRegion(
          onEnter: (_) => withHover ? setState(() => isHovered = true) : null,
          onExit: (_) => withHover ? setState(() => isHovered = false) : null,
          child: GestureDetector(
            onTapDown: (_) => withRipple ? setState(() => isPressed = true) : null,
            onTapUp: (_) => withRipple ? setState(() => isPressed = false) : null,
            onTapCancel: () => withRipple ? setState(() => isPressed = false) : null,
            onTap: onTap,
            child: AnimatedContainer(
              duration: withAnimation ? animationDuration : Duration.zero,
              curve: animationCurve,
              width: width,
              height: height,
              margin: margin,
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppTheme.glassBg,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ?? AppTheme.glassBorderLight,
                  width: borderWidth ?? 1,
                ),
                boxShadow: [
                  if (isHovered || isPressed)
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: isPressed ? 8 : 12,
                      spreadRadius: isPressed ? 1 : 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              transform: Matrix4.identity()
                ..scale(isPressed ? 0.98 : (isHovered ? 1.02 : 1.0)),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // Enhanced Button with micro-interactions
  static Widget enhancedButton({
    required Widget child,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double? elevation,
    bool withAnimation = true,
    bool withLottieIcon = false,
    String? lottieAsset,
    Duration animationDuration = const Duration(milliseconds: 200),
    ButtonStyle? style,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isPressed = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: withAnimation ? animationDuration : Duration.zero,
            transform: Matrix4.identity()
              ..scale(isPressed ? 0.95 : (isHovered ? 1.05 : 1.0)),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => isPressed = true);
                Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() => isPressed = false);
                });
                onPressed();
              },
              style: (style ?? ElevatedButton.styleFrom()).copyWith(
                backgroundColor: WidgetStateProperty.all(backgroundColor ?? AppTheme.primaryColor),
                foregroundColor: WidgetStateProperty.all(foregroundColor ?? Colors.white),
                padding: WidgetStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.circular(12),
                  ),
                ),
                elevation: WidgetStateProperty.all(elevation ?? 4),
                shadowColor: WidgetStateProperty.all(
                  AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (withLottieIcon && lottieAsset != null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Lottie.asset(
                        lottieAsset,
                        animate: isHovered || isPressed,
                      ),
                    ),
                  if (withLottieIcon && lottieAsset != null) const SizedBox(width: 8),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Modern Input Field with enhanced UX
  static Widget enhancedTextField({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> inputFormatters = const [],
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool withAnimation = true,
    bool withValidation = true,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFocused = false;
        bool hasError = false;
        String? errorText;

        return Focus(
          onFocusChange: (hasFocus) {
            setState(() => isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: withAnimation ? animationDuration : Duration.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? Colors.red
                    : isFocused
                        ? AppTheme.primaryColor
                        : AppTheme.glassBorderLight,
                width: hasError ? 2 : 1.5,
              ),
              color: AppTheme.glassBg,
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: withValidation ? validator : null,
              onChanged: (value) {
                if (withValidation && validator != null) {
                  final validationResult = validator(value);
                  setState(() {
                    hasError = validationResult != null;
                    errorText = validationResult;
                  });
                }
                onChanged?.call(value);
              },
              onFieldSubmitted: onSubmitted,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: isFocused ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          suffixIcon,
                          color: isFocused ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                        ),
                        onPressed: onSuffixIconPressed,
                      )
                    : null,
                errorText: hasError ? errorText : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                labelStyle: TextStyle(
                  color: isFocused ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                ),
                hintStyle: TextStyle(
                  color: AppTheme.textSecondaryColor.withOpacity(0.7),
                ),
              ),
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced Loading Indicator with Lottie
  static Widget enhancedLoadingIndicator({
    double? size,
    Color? color,
    bool withLottie = true,
    String? lottieAsset,
    String? loadingText,
  }) {
    if (withLottie && lottieAsset != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 60,
            height: size ?? 60,
            child: Lottie.asset(lottieAsset),
          ),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        color: color ?? AppTheme.primaryColor,
        strokeWidth: 2,
      ),
    );
  }

  // Modern Snackbar with enhanced styling
  static void showEnhancedSnackbar({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
                textColor: textColor ?? Colors.white,
              )
            : null,
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        duration: duration,
        behavior: behavior,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
      ),
    );
  }

  // Enhanced Dialog with modern design
  static Future<T?> showEnhancedDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? backgroundColor,
    double? borderRadius,
    String? lottieAsset,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: backgroundColor ?? AppTheme.glassBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16),
          side: BorderSide(
            color: AppTheme.glassBorderLight,
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottieAsset != null) ...[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Lottie.asset(lottieAsset),
                ),
                const SizedBox(height: 16),
              ],
              title,
              const SizedBox(height: 16),
              content,
              if (actions != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Smooth Page Transition
  static PageRouteBuilder smoothPageTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Enhanced Bottom Sheet with modern design
  static Future<T?> showEnhancedBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
    bool isScrollControlled = true,
    Color? backgroundColor,
    double? borderRadius,
    bool withLottieHeader = false,
    String? lottieAsset,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.glassBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadius ?? 20),
          ),
          border: Border(
            top: BorderSide(color: AppTheme.glassBorderLight),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.glassBorderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Lottie header
            if (withLottieHeader && lottieAsset != null) ...[
              SizedBox(
                width: 60,
                height: 60,
                child: Lottie.asset(lottieAsset),
              ),
              const SizedBox(height: 16),
            ],
            
            // Content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Animation Utilities
class AnimationUtils {
  // Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide In Animation
  static Widget slideIn({
    required Widget child,
    Offset begin = const Offset(0.0, 1.0),
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale In Animation
  static Widget scaleIn({
    required Widget child,
    double begin = 0.8,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered Animation for Lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOut,
    double delayFactor = 0.1,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: duration,
          curve: curve,
          onEnd: () {},
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

/// Responsive Layout Utilities
class ResponsiveUtils {
  // Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200) return ScreenSize.desktop;
    if (width >= 800) return ScreenSize.tablet;
    if (width >= 600) return ScreenSize.largeMobile;
    return ScreenSize.mobile;
  }

  // Responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? largeMobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? largeMobile ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? largeMobile ?? mobile;
      case ScreenSize.largeMobile:
        return largeMobile ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  // Responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(
      responsiveValue<double>(
        context: context,
        mobile: 16,
        largeMobile: 20,
        tablet: 24,
        desktop: 32,
      ),
    );
  }

  // Responsive grid columns
  static int responsiveColumns(BuildContext context) {
    return responsiveValue<int>(
      context: context,
      mobile: 1,
      largeMobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }
}

enum ScreenSize {
  mobile,
  largeMobile,
  tablet,
  desktop,
}

/// Haptic Feedback Utilities
class HapticUtils {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
