import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedThemeProvider extends ChangeNotifier {
  static const Color _primaryColor = Color(0xFF4F46E5);
  static const Color _primaryDark = Color(0xFF3730A3);
  static const Color _secondaryColor = Color(0xFF06B6D4);
  static const Color _accentColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _infoColor = Color(0xFF3B82F6);

  // Glassmorphic colors
  static const Color _glassSurface = Color(0x1FFFFFFF);
  static const Color _glassBorder = Color(0x33FFFFFF);
  static const Color _glassBackground = Color(0x0AFFFFFF);

  // Text colors
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0x99FFFFFF);
  static const Color _textTertiary = Color(0x66FFFFFF);
  static const Color _textDisabled = Color(0x33FFFFFF);

  // Background colors
  static const Color _backgroundPrimary = Color(0xFF0F172A);
  static const Color _backgroundSecondary = Color(0xFF1E293B);
  static const Color _backgroundTertiary = Color(0xFF334155);

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isGlassmorphic = true;
  double _borderRadius = 16.0;
  double _cardElevation = 8.0;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isGlassmorphic => _isGlassmorphic;
  double get borderRadius => _borderRadius;
  double get cardElevation => _cardElevation;

  // Light theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: Colors.white,
        background: Color(0xFFF8FAFC),
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B),
        onBackground: Color(0xFF1E293B),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1E293B),
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF334155),
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF334155),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: Color(0xFF334155),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Dark theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _backgroundSecondary,
        background: _backgroundPrimary,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimary,
        onBackground: _textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: _textPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardTheme(
        color: _backgroundSecondary,
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _backgroundTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: _textTertiary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: _textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: _textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: _textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: _textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: _textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: _textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: _textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: _textDisabled,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Glassmorphic theme
  ThemeData get glassmorphicTheme {
    return darkTheme.copyWith(
      cardTheme: CardTheme(
        color: _glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(color: _glassBorder, width: 1),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _glassSurface,
          foregroundColor: _textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            side: BorderSide(color: _glassBorder, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: _textTertiary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  // Methods
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleGlassmorphic() {
    _isGlassmorphic = !_isGlassmorphic;
    notifyListeners();
  }

  void setGlassmorphic(bool enabled) {
    _isGlassmorphic = enabled;
    notifyListeners();
  }

  void updateBorderRadius(double radius) {
    _borderRadius = radius.clamp(8.0, 32.0);
    notifyListeners();
  }

  void updateCardElevation(double elevation) {
    _cardElevation = elevation.clamp(0.0, 16.0);
    notifyListeners();
  }

  // Get current theme based on settings
  ThemeData get currentTheme {
    if (_isGlassmorphic && isDarkMode) {
      return glassmorphicTheme;
    }
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Color helpers
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  Color get warningColor => _warningColor;
  Color get errorColor => _errorColor;
  Color get successColor => _successColor;
  Color get infoColor => _infoColor;

  Color get glassSurface => _glassSurface;
  Color get glassBorder => _glassBorder;
  Color get glassBackground => _glassBackground;

  Color get textPrimary => _textPrimary;
  Color get textSecondary => _textSecondary;
  Color get textTertiary => _textTertiary;
  Color get textDisabled => _textDisabled;

  Color get backgroundPrimary => _backgroundPrimary;
  Color get backgroundSecondary => _backgroundSecondary;
  Color get backgroundTertiary => _backgroundTertiary;

  // Gradient helpers
  LinearGradient get primaryGradient => const LinearGradient(
    colors: [_primaryColor, _primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get secondaryGradient => const LinearGradient(
    colors: [_secondaryColor, Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get glassGradient => const LinearGradient(
    colors: [_glassSurface, _glassBackground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get backgroundGradient => const LinearGradient(
    colors: [_backgroundPrimary, _backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
