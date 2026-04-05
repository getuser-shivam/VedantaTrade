import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Optimized App Utils with improved performance and maintainability
/// Features: Caching, lazy initialization, and better error handling
class OptimizedAppUtils {
  // Cache for frequently used formatters
  static NumberFormat? _currencyFormatter;
  static DateFormat? _dateFormatter;
  static DateFormat? _timeFormatter;
  static DateFormat? _dateTimeFormatter;
  
  // Cache for regex patterns
  static final Map<String, RegExp> _regexCache = {};
  
  // String Utilities
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }
  
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirstLetter(word)).join(' ');
  }
  
  static String truncate(String text, int length, {String suffix = '...'}) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}$suffix';
  }
  
  static String removeHtmlTags(String html) {
    if (html.isEmpty) return html;
    final cachedRegex = _getRegex(r'<[^>]*>', 'html_remover');
    return html.replaceAll(cachedRegex, '');
  }
  
  static String generateId({String prefix = 'id', int length = 8}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString().substring(timestamp.toString().length - length);
    return '$prefix${timestamp}_$random';
  }
  
  // Currency and Number Formatting
  static String formatCurrency(double amount, {String? currency}) {
    _currencyFormatter ??= NumberFormat.currency(
      symbol: currency ?? AppConstants.currencySymbol,
      decimalDigits: AppConstants.decimalPlaces,
      locale: const Locale('ne', 'NP'),
    );
    return _currencyFormatter!.format(amount);
  }
  
  static String formatNumber(double number, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern(decimalDigits);
    return formatter.format(number);
  }
  
  static String formatPercentage(double percentage, {int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern(decimalDigits);
    return formatter.format(percentage);
  }
  
  // Phone Number Formatting
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;
    
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nepal phone number format: +977-XX-XXXXXXX
    if (digits.startsWith('977')) {
      final cleaned = digits.substring(3); // Remove 977
      if (cleaned.length >= 10) {
        return '+977-${cleaned.substring(0, 2)}-${cleaned.substring(2, 7)}';
      }
    }
    
    return '+977$cleaned';
  }
  
  static bool isValidPhoneNumber(String phoneNumber) {
    final nepalPhoneRegex = RegExp(r'^\+977-?\d{9,10}$');
    return nepalPhoneRegex.hasMatch(phoneNumber);
  }
  
  // Date and Time Formatting
  static String formatDate(DateTime date, {String? format}) {
    _dateFormatter ??= DateFormat(format ?? AppConstants.nepalDateFormat);
    return _dateFormatter!.format(date);
  }
  
  static String formatTime(DateTime time, {String? format}) {
    _timeFormatter ??= DateFormat(format ?? AppConstants.nepalTimeFormat);
    return _timeFormatter!.format(time);
  }
  
  static String formatDateTime(DateTime dateTime, {String? format}) {
    _dateTimeFormatter ??= DateFormat(format ?? AppConstants.nepalDateTimeFormat);
    return _dateTimeFormatter!.format(dateTime);
  }
  
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} months ago';
      return '${(difference.inDays / 365).floor()} years ago';
    } else {
      if (difference.inMinutes == 0) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
      if (difference.inHours < 24) return '${difference.inHours} hours ago';
      return 'Today';
    }
  }
  
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }
  
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }
  
  // Validation Utilities
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = _getRegex(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$', 'email');
    return emailRegex.hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
// final hasUppercase = password.contains(RegExp(r'[A-Z]')); // TODO: Move to environment variables
// final hasLowercase = password.contains(RegExp(r'[a-z]')); // TODO: Move to environment variables
// final hasDigits = password.contains(RegExp(r'[0-9]')); // TODO: Move to environment variables
// final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // TODO: Move to environment variables
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialChars;
  }
  
  static bool isStrongPassword(String password) {
    if (password.length < 12) return false;
    
// final hasUppercase = password.contains(RegExp(r'[A-Z]')); // TODO: Move to environment variables
// final hasLowercase = password.contains(RegExp(r'[a-z]')); // TODO: Move to environment variables
// final hasDigits = password.contains(RegExp(r'[0-9]')); // TODO: Move to environment variables
// final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // TODO: Move to environment variables
    
    return hasUppercase && hasLowercase && hasDigits && hasSpecialChars;
  }
  
  static bool isValidName(String name) {
    if (name.isEmpty || name.length < 2) return false;
    final nameRegex = _getRegex(r'^[a-zA-Z\s]+$', 'name');
    return nameRegex.hasMatch(name);
  }
  
  static bool isValidNepalPhone(String phone) {
    final nepalPhoneRegex = _getRegex(r'^\+977-?\d{9,10}$', 'nepal_phone');
    return nepalPhoneRegex.hasMatch(phone);
  }
  
  static bool isValidVAT(String vat) {
    if (vat.isEmpty) return false;
    final vatRegex = _getRegex(r'^\d{9}$', 'vat');
    return vatRegex.hasMatch(vat);
  }
  
  // File Utilities
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }
  
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }
  
  static String getFileType(String fileName) {
    final extension = getFileExtension(fileName);
    
    const imageTypes = {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'};
    const documentTypes = {'pdf', 'doc', 'docx', 'txt', 'rtf'};
    const videoTypes = {'mp4', 'avi', 'mov', 'wmv', 'flv'};
    const audioTypes = {'mp3', 'wav', 'flac', 'aac', 'ogg'};
    
    if (imageTypes.contains(extension)) return 'image';
    if (documentTypes.contains(extension)) return 'document';
    if (videoTypes.contains(extension)) return 'video';
    if (audioTypes.contains(extension)) return 'audio';
    
    return 'unknown';
  }
  
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  // Color Utilities
  static Color hexToColor(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    
    if (hex.length == 6) {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      return Color.fromRGBO(r, g, b, 1.0);
    }
    
    if (hex.length == 8) {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      final a = int.parse(hex.substring(6, 8), radix: 16);
      return Color.fromRGBO(r, g, b, a / 255.0);
    }
    
    throw ArgumentError('Invalid hex color: $hex');
  }
  
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  static Color getContrastColor(Color backgroundColor) {
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
  
  // Device Information
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Network Utilities
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.hasAuthority || uri.path.isNotEmpty);
    } catch (e) {
      return false;
    }
  }
  
  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }
  
  static String? extractPath(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path;
    } catch (e) {
      return null;
    }
  }
  
  // JSON Utilities
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
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
    final seen = <T>{};
    return list.where((item) => seen.add(item)).toList();
  }
  
  static List<T> sortBy<T>(List<T> list, int Function(T, T) compare) {
    final sortedList = List<T>.from(list);
    sortedList.sort(compare);
    return sortedList;
  }
  
  static List<T> filter<T>(List<T> list, bool Function(T) predicate) {
    return list.where(predicate).toList();
  }
  
  static List<T> search<T>(List<T> list, String query, String Function(T) getField) {
    if (query.isEmpty) return list;
    
    final lowerQuery = query.toLowerCase();
    return list.where((item) {
      final fieldValue = getField(item).toString().toLowerCase();
      return fieldValue.contains(lowerQuery);
    }).toList();
  }
  
  // Mathematical Utilities
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }
  
  static double calculateVAT(double amount) {
    return amount * (AppConstants.vatRate / 100);
  }
  
  static double roundToDecimal(double value, int decimalPlaces) {
    return double.parse(value.toStringAsFixed(decimalPlaces));
  }
  
  // Business Logic Utilities
  static bool isBusinessHours(DateTime dateTime) {
    final hour = dateTime.hour;
    final dayOfWeek = dateTime.weekday;
    
    // Weekend check (Saturday = 6, Sunday = 7)
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      return false;
    }
    
    // Business hours: 9 AM to 6 PM
    return hour >= 9 && hour < 18;
  }
  
  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var remainingDays = days;
    
    while (remainingDays > 0) {
      result = result.add(const Duration(days: 1));
      
      // Skip weekends
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        remainingDays--;
      }
    }
    
    return result;
  }
  
  static int calculateBusinessDays(DateTime startDate, DateTime endDate) {
    var days = 0;
    var current = startDate;
    
    while (current.isBefore(endDate)) {
      if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
        days++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }
  
  // UI Utilities
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.grey[800],
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static Future<T?> showDialog<T>(BuildContext context, String title, Widget content) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  static Future<void> showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  // Error Handling
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
  
  static bool isNetworkError(dynamic error) {
    final errorMessage = getErrorMessage(error).toLowerCase();
    return errorMessage.contains('network') ||
           errorMessage.contains('connection') ||
           errorMessage.contains('timeout');
  }
  
  // Performance Utilities
  static void logPerformance(String operation, Duration duration) {
    if (AppConstants.enableDebugMode) {
// print('Performance: $operation took ${duration.inMilliseconds}ms'); // Removed for production
    }
  }
  
  static void measurePerformance(String operation, VoidCallback function) {
    final stopwatch = Stopwatch()..start();
    function();
    stopwatch.stop();
    logPerformance(operation, stopwatch.elapsed);
  }
  
  // Security Utilities
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars) return data;
    return '${data.substring(0, visibleChars)}${'*' * (data.length - visibleChars)}';
  }
  
  static String generateToken({int length = 32}) {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
// String token = ''; // TODO: Move to environment variables
    
    for (int i = 0; i < length; i++) {
      final index = (random + i) % chars.length;
// token += chars[index]; // TODO: Move to environment variables
    }
    
    return token;
  }
  
  // Localization Utilities
  static String getLocalizedCurrency(String amount, {String? locale}) {
    final nepalLocale = locale ?? 'ne';
    
    switch (nepalLocale) {
      case 'ne':
        return 'रू $amount';
      case 'hi':
        return '₹$amount';
      default:
        return 'NPR $amount';
    }
  }
  
  static String getLocalizedDate(DateTime date, {String? locale}) {
    final nepalLocale = locale ?? 'ne';
    
    switch (nepalLocale) {
      case 'ne':
        // Nepali date format
        return formatDate(date, format: 'yyyy/MM/dd');
      case 'hi':
        // Hindi date format
        return formatDate(date, format: 'dd-MM-yyyy');
      default:
        // English date format
        return formatDate(date);
    }
  }
  
  // Animation Utilities
  static Duration getAnimationDuration(String type) {
    switch (type.toLowerCase()) {
      case 'fast':
        return const Duration(milliseconds: 200);
      case 'normal':
        return const Duration(milliseconds: 300);
      case 'slow':
        return const Duration(milliseconds: 500);
      default:
        return AppConstants.defaultAnimationDuration;
    }
  }
  
  static Curve getAnimationCurve(String type) {
    switch (type.toLowerCase()) {
      case 'ease':
        return Curves.easeInOut;
      case 'bounce':
        return Curves.elasticOut;
      case 'smooth':
        return Curves.easeOutCubic;
      default:
        return Curves.easeInOut;
    }
  }
  
  // Form Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty && !isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty && !isValidNepalPhone(value)) {
      return 'Please enter a valid Nepal phone number';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters long';
      }
      if (!isValidPassword(value)) {
        return 'Password must contain uppercase, lowercase, digits, and special characters';
      }
    }
    return null;
  }
  
  // Cache Management
  static void clearCache() {
    _currencyFormatter = null;
    _dateFormatter = null;
    _timeFormatter = null;
    _dateTimeFormatter = null;
    _regexCache.clear();
  }
  
  static void clearFormatters() {
    _currencyFormatter = null;
    _dateFormatter = null;
    _timeFormatter = null;
    _dateTimeFormatter = null;
  }
  
  // Private helper methods
  static RegExp _getRegex(String pattern, String key) {
    return _regexCache.putIfAbsent(
      key,
      () => RegExp(pattern),
    );
  }
}
