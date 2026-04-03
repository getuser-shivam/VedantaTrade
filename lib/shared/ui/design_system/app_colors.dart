import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primarySurface = Color(0xFFEEF2FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);

  // Accent Colors
  static const Color accent = Color(0xFFF43F5E);
  static const Color accentDark = Color(0xFFE11D48);
  static const Color accentLight = Color(0xFFFB7185);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSurface = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningSurface = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSurface = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // Role-Based Colors
  static const Color adminColor = Color(0xFF4F46E5);
  static const Color mrColor = Color(0xFF06B6D4);
  static const Color accountantColor = Color(0xFF8B5CF6);
  static const Color doctorColor = Color(0xFF3B82F6);
  static const Color stockistColor = Color(0xFFF59E0B);
  static const Color retailerColor = Color(0xFFF43F5E);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkDivider = Color(0xFF64748B);

  // Glassmorphic Colors
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkTextInverse = Color(0xFF0F172A);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [glassBackground, Color(0x0DFFFFFF)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFDC2626)],
  );

  // Utility Methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'approved':
        return success;
      case 'warning':
      case 'pending':
      case 'processing':
        return warning;
      case 'error':
      case 'failed':
      case 'rejected':
        return error;
      case 'info':
      case 'draft':
        return info;
      default:
        return textSecondary;
    }
  }

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminColor;
      case 'mr':
      case 'medical_rep':
        return mrColor;
      case 'accountant':
        return accountantColor;
      case 'doctor':
        return doctorColor;
      case 'stockist':
        return stockistColor;
      case 'retailer':
        return retailerColor;
      default:
        return primary;
    }
  }
}
