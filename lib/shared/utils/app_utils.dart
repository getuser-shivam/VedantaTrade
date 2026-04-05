import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // String Utilities
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatCurrency(double amount, {String? currency}) {
    final formatter = NumberFormat.currency(
      symbol: currency ?? AppConstants.currencySymbol,
      decimalDigits: AppConstants.decimalPlaces,
    );
    return formatter.format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Format phone number for Nepal: +977-XX-XXXXXXX
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+977')) {
      return cleaned.replaceFirstMapped(
        RegExp(r'^(\+977)(\d{2})(\d{7})$'),
        (match) => '${match.group(1)}-${match.group(2)}-${match.group(3)}',
      );
    }
    return cleaned;
  }

  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.nepalDateFormat);
    return formatter.format(date);
  }

  static String formatTime(DateTime time, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.nepalTimeFormat);
    return formatter.format(time);
  }

  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.nepalDateTimeFormat);
    return formatter.format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  static String removeHtmlTags(String htmlText) {
    final document = RegExp(r'<[^>]*>');
    return htmlText.replaceAll(document, '');
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final result = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      final index = (random + i) % chars.length;
      result.write(chars[index]);
    }
    
    return result.toString();
  }

  // Validation Utilities
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailPattern).hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(AppConstants.phonePattern).hasMatch(phone);
  }

  static bool isValidPassword(String password) {
    return RegExp(AppConstants.passwordPattern).hasMatch(password);
  }

  static bool isValidName(String name) {
    return RegExp(AppConstants.namePattern).hasMatch(name);
  }

  static bool isStrongPassword(String password) {
// final hasUppercase = password.contains(RegExp(r'[A-Z]')); // TODO: Move to environment variables
// final hasLowercase = password.contains(RegExp(r'[a-z]')); // TODO: Move to environment variables
// final hasDigits = password.contains(RegExp(r'[0-9]')); // TODO: Move to environment variables
// final hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // TODO: Move to environment variables
// final hasMinLength = password.length >= AppConstants.minPasswordLength; // TODO: Move to environment variables

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters && hasMinLength;
  }

  // File Utilities
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.supportedImageFormats.contains(extension);
  }

  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return AppConstants.supportedDocumentFormats.contains(extension);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Color Utilities
  static Color hexToColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine contrast color
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static Color lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  // Device Utilities
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide > 1200;
  }

  static bool isMobile(BuildContext context) {
    return !isTablet(context) && !isDesktop(context);
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getBottomBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  // Network Utilities
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return '';
    }
  }

  // JSON Utilities
  static Map<String, dynamic> parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static String encodeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return '{}';
    }
  }

  // List Utilities
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static List<T> sortByProperty<T>(List<T> list, String property, {bool descending = false}) {
    final sortedList = List<T>.from(list);
    sortedList.sort((a, b) {
      final aValue = (a as dynamic)[property];
      final bValue = (b as dynamic)[property];
      
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return descending ? 1 : -1;
      if (bValue == null) return descending ? -1 : 1;
      
      final comparison = aValue.compareTo(bValue);
      return descending ? -comparison : comparison;
    });
    return sortedList;
  }

  static List<T> filterByProperty<T>(List<T> list, String property, dynamic value) {
    return list.where((item) => (item as dynamic)[property] == value).toList();
  }

  static List<T> searchInList<T>(List<T> list, String searchTerm, List<String> searchFields) {
    if (searchTerm.isEmpty) return list;
    
    final lowerSearchTerm = searchTerm.toLowerCase();
    return list.where((item) {
      for (final field in searchFields) {
        final fieldValue = (item as dynamic)[field]?.toString().toLowerCase() ?? '';
        if (fieldValue.contains(lowerSearchTerm)) return true;
      }
      return false;
    }).toList();
  }

  // Math Utilities
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }

  static double calculateVAT(double amount, {double vatRate = AppConstants.defaultVAT}) {
    return amount * vatRate;
  }

  static double calculateTotalWithVAT(double amount, {double vatRate = AppConstants.defaultVAT}) {
    return amount + calculateVAT(amount, vatRate: vatRate);
  }

  static double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = math.pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }

  // Date Utilities
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime getStartOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  static DateTime getEndOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return date.add(Duration(days: daysToAdd));
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Business Logic Utilities
  static bool isBusinessHours(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    final dayOfWeek = dateTime.weekday;
    
    return AppConstants.businessDays.contains(dayOfWeek) &&
        time.hour >= AppConstants.businessStart.hour &&
        time.hour < AppConstants.businessEnd.hour;
  }

  static DateTime addBusinessDays(DateTime date, int days) {
    var currentDate = date;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      currentDate = currentDate.add(const Duration(days: 1));
      if (AppConstants.businessDays.contains(currentDate.weekday)) {
        remainingDays--;
      }
    }
    
    return currentDate;
  }

  static int calculateBusinessDays(DateTime startDate, DateTime endDate) {
    var businessDays = 0;
    var currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || isSameDay(currentDate, endDate)) {
      if (AppConstants.businessDays.contains(currentDate.weekday)) {
        businessDays++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return businessDays;
  }

  // UI Utilities
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Theme.of(context).primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.red);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.green);
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Storage Utilities
  static Future<void> saveToPreferences(String key, String value) async {
    // Implementation would depend on shared_preferences package
    // await SharedPreferences.getInstance().then((prefs) => prefs.setString(key, value));
  }

  static Future<String?> getFromPreferences(String key) async {
    // Implementation would depend on shared_preferences package
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(key);
    return null;
  }

  static Future<void> removeFromPreferences(String key) async {
    // Implementation would depend on shared_preferences package
    // await SharedPreferences.getInstance().then((prefs) => prefs.remove(key));
  }

  // Error Handling Utilities
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return AppConstants.genericErrorMessage;
  }

  static bool isNetworkError(dynamic error) {
    final errorMessage = getErrorMessage(error).toLowerCase();
    return errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('internet');
  }

  static bool isServerError(dynamic error) {
    final errorMessage = getErrorMessage(error).toLowerCase();
    return errorMessage.contains('server') ||
        errorMessage.contains('internal') ||
        errorMessage.contains('500');
  }

  static bool isAuthError(dynamic error) {
    final errorMessage = getErrorMessage(error).toLowerCase();
    return errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden') ||
        errorMessage.contains('401') ||
        errorMessage.contains('403');
  }

  // Performance Utilities
  static void logPerformance(String operation, Duration duration) {
// print('Performance: $operation took ${duration.inMilliseconds}ms'); // Removed for production
  }

  static Future<T> measurePerformance<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    final result = await function();
    stopwatch.stop();
    logPerformance(operation, stopwatch.elapsed);
    return result;
  }

  // Security Utilities
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final maskedUsername = username.substring(0, 2) + '*' * (username.length - 2);
    return '$maskedUsername@$domain';
  }

  static String maskPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length <= 4) return phoneNumber;
    
    return cleaned.substring(0, 4) + '*' * (cleaned.length - 4);
  }

  static String generateSecureToken() {
    final bytes = List<int>.generate(32, (_) => DateTime.now().millisecond + 1);
    return base64.encode(bytes);
  }

  // Localization Utilities
  static String translate(String key, {Map<String, String>? params}) {
    // Implementation would depend on localization package
    // return AppLocalizations.of(context)?.translate(key) ?? key;
    return key;
  }

  static String getLocalizedCurrency(String currencyCode) {
    return AppConstants.currencySymbols[currencyCode] ?? currencyCode;
  }

  static String getLocalizedCountry(String countryCode) {
    return AppConstants.countryCodes[countryCode] ?? countryCode;
  }

  // Animation Utilities
  static Duration getAnimationDuration(AnimationType type) {
    switch (type) {
      case AnimationType.short:
        return AppConstants.shortAnimation;
      case AnimationType.medium:
        return AppConstants.mediumAnimation;
      case AnimationType.long:
        return AppConstants.longAnimation;
    }
  }

  static Curve getAnimationCurve(AnimationCurve curve) {
    switch (curve) {
      case AnimationCurve.easeIn:
        return Curves.easeIn;
      case AnimationCurve.easeOut:
        return Curves.easeOut;
      case AnimationCurve.easeInOut:
        return Curves.easeInOut;
      case AnimationCurve.linear:
        return Curves.linear;
    }
  }

  // Validation Utilities
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (!isStrongPassword(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!isValidName(value)) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }
}

enum AnimationType { short, medium, long }

enum AnimationCurve { easeIn, easeOut, easeInOut, linear }
