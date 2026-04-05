import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class EnhancedAppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFF388E3C),
        tertiary: Color(0xFFD32F2F),
        surface: Color(0xFFFAFAFA),
        background: Color(0xFFF5F5F5),
        error: Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Color(0xFF212121),
        onBackground: Color(0xFF212121),
        onError: Colors.white,
        outline: Color(0xFFE0E0E0),
        outlineVariant: Color(0xFFBDBDBD),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF303030),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFF90CAF9),
        surfaceTint: Color(0xFF1976D2),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: Color(0xFF212121),
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: Color(0xFF212121),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: Color(0xFF212121),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Color(0xFF212121),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: Color(0xFF212121),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Color(0xFF212121),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: Color(0xFF212121),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Color(0xFF212121),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Color(0xFF212121),
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Color(0xFF212121),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        toolbarTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1976D2),
          side: const BorderSide(color: Color(0xFF1976D2), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1976D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFD32F2F),
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Color(0xFF757575),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE3F2FD),
        selectedColor: const Color(0xFF1976D2),
        deleteIconColor: const Color(0xFF1976D2),
        labelStyle: const TextStyle(
          color: Color(0xFF1976D2),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
        extendedTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF212121),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF1976D2),
        linearTrackColor: Color(0xFFE3F2FD),
        circularTrackColor: Color(0xFFE3F2FD),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF1976D2);
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF90CAF9);
          }
          return const Color(0xFFBDBDBD);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF1976D2);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF1976D2);
          }
          return const Color(0xFF757575);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF212121),
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF757575),
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF1976D2),
        unselectedLabelColor: Color(0xFF757575),
        indicatorColor: Color(0xFF1976D2),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 16,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppConstants.largeBorderRadius),
            bottomRight: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeBorderRadius),
            topRight: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF90CAF9),
        secondary: Color(0xFF81C784),
        tertiary: Color(0xFFEF5350),
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        error: Color(0xFFEF5350),
        onPrimary: Color(0xFF0D47A1),
        onSecondary: Color(0xFF1B5E20),
        onTertiary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
        outline: Color(0xFF424242),
        outlineVariant: Color(0xFF616161),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFFE0E0E0),
        onInverseSurface: Color(0xFF212121),
        inversePrimary: Color(0xFF1976D2),
        surfaceTint: Color(0xFF90CAF9),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        surfaceTintColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        toolbarTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90CAF9),
          foregroundColor: const Color(0xFF0D47A1),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          side: const BorderSide(color: Color(0xFF90CAF9), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF90CAF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF424242), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: Color(0xFFEF5350), width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF90CAF9),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFEF5350),
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Color(0xFF90CAF9),
        unselectedItemColor: Color(0xFFBDBDBD),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFF90CAF9),
        deleteIconColor: const Color(0xFF90CAF9),
        labelStyle: const TextStyle(
          color: Color(0xFF90CAF9),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF0D47A1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF90CAF9),
        foregroundColor: Color(0xFF0D47A1),
        elevation: 6,
        shape: CircleBorder(),
        extendedTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF90CAF9),
        linearTrackColor: Color(0xFF1E1E1E),
        circularTrackColor: Color(0xFF1E1E1E),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF90CAF9);
          }
          return const Color(0xFF424242);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF0D47A1);
          }
          return const Color(0xFF616161);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF90CAF9);
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(const Color(0xFF0D47A1)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF90CAF9);
          }
          return const Color(0xFFBDBDBD);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF424242),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFBDBDBD),
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF90CAF9),
        unselectedLabelColor: Color(0xFFBDBDBD),
        indicatorColor: Color(0xFF90CAF9),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: const Color(0xFF121212),
        elevation: 16,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppConstants.largeBorderRadius),
            bottomRight: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.largeBorderRadius),
            topRight: Radius.circular(AppConstants.largeBorderRadius),
          ),
        ),
      ),
    );
  }

  static ThemeData getTheme(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return darkTheme;
      case AppConstants.lightThemeKey:
      default:
        return lightTheme;
    }
  }

  static Color getPrimaryColor(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return const Color(0xFF90CAF9);
      case AppConstants.lightThemeKey:
      default:
        return const Color(0xFF1976D2);
    }
  }

  static Color getBackgroundColor(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return const Color(0xFF121212);
      case AppConstants.lightThemeKey:
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color getSurfaceColor(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return const Color(0xFF1E1E1E);
      case AppConstants.lightThemeKey:
      default:
        return const Color(0xFFFAFAFA);
    }
  }

  static Color getTextColor(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return Colors.white;
      case AppConstants.lightThemeKey:
      default:
        return const Color(0xFF212121);
    }
  }

  static Color getErrorColor(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return const Color(0xFFEF5350);
      case AppConstants.lightThemeKey:
      default:
        return const Color(0xFFD32F2F);
    }
  }

  static Color getSuccessColor() {
    return const Color(0xFF4CAF50);
  }

  static Color getWarningColor() {
    return const Color(0xFFFF9800);
  }

  static Color getInfoColor() {
    return const Color(0xFF2196F3);
  }

  static List<Color> getPrimaryGradient(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return [
          const Color(0xFF90CAF9),
          const Color(0xFF42A5F5),
        ];
      case AppConstants.lightThemeKey:
      default:
        return [
          const Color(0xFF1976D2),
          const Color(0xFF42A5F5),
        ];
    }
  }

  static List<Color> getSecondaryGradient(String themeMode) {
    switch (themeMode) {
      case AppConstants.darkThemeKey:
        return [
          const Color(0xFF81C784),
          const Color(0xFF4CAF50),
        ];
      case AppConstants.lightThemeKey:
      default:
        return [
          const Color(0xFF388E3C),
          const Color(0xFF4CAF50),
        ];
    }
  }

  static TextStyle getHeadlineStyle(String themeMode) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: getTextColor(themeMode),
    );
  }

  static TextStyle getTitleStyle(String themeMode) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: getTextColor(themeMode),
    );
  }

  static TextStyle getBodyStyle(String themeMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: getTextColor(themeMode),
    );
  }

  static TextStyle getCaptionStyle(String themeMode) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: getTextColor(themeMode).withOpacity(0.7),
    );
  }

  static BorderRadius getBorderRadius() {
    return BorderRadius.circular(AppConstants.defaultBorderRadius);
  }

  static BorderRadius getSmallBorderRadius() {
    return BorderRadius.circular(AppConstants.smallBorderRadius);
  }

  static BorderRadius getLargeBorderRadius() {
    return BorderRadius.circular(AppConstants.largeBorderRadius);
  }

  static EdgeInsets getDefaultPadding() {
    return const EdgeInsets.all(AppConstants.defaultPadding);
  }

  static EdgeInsets getSmallPadding() {
    return const EdgeInsets.all(AppConstants.smallPadding);
  }

  static EdgeInsets getLargePadding() {
    return const EdgeInsets.all(AppConstants.largePadding);
  }

  static EdgeInsets getHorizontalPadding() {
    return const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding);
  }

  static EdgeInsets getVerticalPadding() {
    return const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding);
  }

  static BoxShadow getDefaultShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    );
  }

  static BoxShadow getLargeShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    );
  }

  static BoxShadow getDarkShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    );
  }
}
