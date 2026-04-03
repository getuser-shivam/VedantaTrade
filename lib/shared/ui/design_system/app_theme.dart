import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  // Theme Mode Provider
  static ThemeMode get defaultThemeMode => ThemeMode.dark;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.primarySurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Typography
      textTheme: AppTypography.buildTextTheme(isDark: false),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.heading4.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.textTertiary.withOpacity(0.2))),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusCard,
          side: BorderSide(color: AppColors.textTertiary.withOpacity(0.1)),
        ),
        margin: AppSpacing.marginBetweenCards,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primarySurface,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: BorderSide(color: AppColors.textTertiary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: BorderSide(color: AppColors.textTertiary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
        errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
        contentPadding: AppSpacing.paddingInput,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        selectedColor: AppColors.primary.withOpacity(0.15),
        disabledColor: AppColors.textTertiary.withOpacity(0.1),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.primary),
        brightness: Brightness.light,
        padding: AppSpacing.chipPadding,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusChip),
        side: BorderSide(color: AppColors.textTertiary.withOpacity(0.2)),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.textTertiary.withOpacity(0.2),
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusDialog),
        titleTextStyle: AppTypography.heading5.copyWith(color: AppColors.textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        actionsPadding: AppSpacing.paddingDialog,
        insetPadding: AppSpacing.paddingScreenSM,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusBottomSheet,
        ),
        modalElevation: 8,
        padding: AppSpacing.paddingBottomSheet,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.textTertiary,
        circularTrackColor: AppColors.textTertiary,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return AppColors.textTertiary.withOpacity(0.2);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.textTertiary),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusXS),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.textTertiary.withOpacity(0.2),
        thumbColor: AppColors.primary,
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelMedium,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.textTertiary.withOpacity(0.2),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listTilePadding,
        titleTextStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        leadingAndTrailingTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primarySurface,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusSM),
        dense: false,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      // Typography
      textTheme: AppTypography.buildTextTheme(isDark: true),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.heading4.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.darkBorder.withOpacity(0.3))),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusCard,
          side: BorderSide(color: AppColors.darkBorder.withOpacity(0.2)),
        ),
        margin: AppSpacing.marginBetweenCards,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusButton),
          padding: AppSpacing.paddingButton,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkTextSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextTertiary),
        errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
        contentPadding: AppSpacing.paddingInput,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primary.withOpacity(0.2),
        disabledColor: AppColors.darkBorder.withOpacity(0.2),
        labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(color: AppColors.primary),
        brightness: Brightness.dark,
        padding: AppSpacing.chipPadding,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusChip),
        side: BorderSide(color: AppColors.darkBorder.withOpacity(0.3)),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkBorder.withOpacity(0.3),
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusDialog),
        titleTextStyle: AppTypography.heading5.copyWith(color: AppColors.darkTextPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        actionsPadding: AppSpacing.paddingDialog,
        insetPadding: AppSpacing.paddingScreenSM,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.radiusBottomSheet,
        ),
        modalElevation: 8,
        padding: AppSpacing.paddingBottomSheet,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkBorder,
        circularTrackColor: AppColors.darkBorder,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkTextTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return AppColors.darkBorder.withOpacity(0.3);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusXS),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkTextTertiary;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.darkBorder.withOpacity(0.3),
        thumbColor: AppColors.primary,
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.labelMedium,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.darkBorder.withOpacity(0.3),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listTilePadding,
        titleTextStyle: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        subtitleTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        leadingAndTrailingTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.radiusSM),
        dense: false,
      ),
    );
  }

  // Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  // Get role-based color
  static Color getRoleColor(String role) {
    return AppColors.getRoleColor(role);
  }

  // Get status-based color
  static Color getStatusColor(String status) {
    return AppColors.getStatusColor(status);
  }
}
