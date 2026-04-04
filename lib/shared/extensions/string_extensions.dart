import 'dart:core';

/// String extensions for common operations
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Capitalize first letter of string
  String get capitalize {
    if (isNullOrEmpty) return this ?? '';
    return '${this![0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isNullOrEmpty) return this ?? '';
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Convert to title case
  String get toTitleCase {
    if (isNullOrEmpty) return this ?? '';
    return split(' ')
        .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Convert to camelCase
  String get toCamelCase {
    if (isNullOrEmpty) return this ?? '';
    final words = split(RegExp(r'[_\s-]+'));
    if (words.isEmpty) return '';
    return words.first.toLowerCase() + words.skip(1).map((word) => word.capitalize).join('');
  }

  /// Convert to PascalCase
  String get toPascalCase {
    if (isNullOrEmpty) return this ?? '';
    return split(RegExp(r'[_\s-]+')).map((word) => word.capitalize).join('');
  }

  /// Convert to snake_case
  String get toSnakeCase {
    if (isNullOrEmpty) return this ?? '';
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}')
        .toLowerCase()
        .replaceAll(RegExp(r'[_\s-]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Convert to kebab-case
  String get toKebabCase {
    if (isNullOrEmpty) return this ?? '';
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) => '-${match.group(0)!.toLowerCase()}')
        .toLowerCase()
        .replaceAll(RegExp(r'[-\s_]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Remove all special characters except letters and numbers
  String get removeSpecialCharacters => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// Remove all non-digit characters
  String get removeNonDigits => replaceAll(RegExp(r'[^\d]'), '');

  /// Remove all non-letter characters
  String get removeNonLetters => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Check if string contains only digits
  bool get isDigits => replaceAll(RegExp(r'[^\d]'), '').length == length;

  /// Check if string contains only letters
  bool get isLetters => replaceAll(RegExp(r'[^a-zA-Z]'), '').length == length;

  /// Check if string is a valid email
  bool get isValidEmail {
    if (isNullOrEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this!);
  }

  /// Check if string is a valid phone number (Nepal format)
  bool get isValidNepalPhone {
    if (isNullOrEmpty) return false;
    final cleanPhone = replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^9[6-8]\d{8}$').hasMatch(cleanPhone);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    if (isNullOrEmpty) return false;
    return RegExp(r'^https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$').hasMatch(this!);
  }

  /// Check if string is a valid Nepal PAN number
  bool get isValidNepalPan {
    if (isNullOrEmpty) return false;
    return RegExp(r'^\d{9}$').hasMatch(this!);
  }

  /// Check if string is a valid Nepal VAT number
  bool get isValidNepalVat {
    if (isNullOrEmpty) return false;
    return RegExp(r'^\d{9}$|^\d{13}$').hasMatch(this!);
  }

  /// Format as Nepal phone number
  String get formatNepalPhone {
    if (isNullOrEmpty) return this ?? '';
    final cleanPhone = replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 10) return this!;
    return '${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
  }

  /// Format as currency (NPR)
  String get formatNprCurrency {
    if (isNullOrEmpty) return 'NPR 0.00';
    try {
      final amount = double.parse(this!);
      return 'NPR ${amount.toStringAsFixed(2)}';
    } catch (e) {
      return 'NPR 0.00';
    }
  }

  /// Truncate string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (isNullOrEmpty || length <= maxLength) return this ?? '';
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Mask sensitive information (e.g., email, phone)
  String mask({int visibleChars = 4, String maskChar = '*'}) {
    if (isNullOrEmpty) return this ?? '';
    if (length <= visibleChars) return this!;
    
    final visiblePart = substring(0, visibleChars);
    final maskedPart = List.filled(length - visibleChars, maskChar).join('');
    
    return '$visiblePart$maskedPart';
  }

  /// Extract numbers from string
  String get extractNumbers => replaceAll(RegExp(r'[^\d]'), '');

  /// Extract letters from string
  String get extractLetters => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Count words in string
  int get wordCount {
    if (isNullOrEmpty) return 0;
    return trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// Reverse string
  String get reverse {
    if (isNullOrEmpty) return this ?? '';
    return split('').reversed.join('');
  }

  /// Check if string is palindrome
  bool get isPalindrome {
    if (isNullOrEmpty) return false;
    final clean = replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return clean == clean.reverse;
  }

  /// Calculate similarity between two strings (Levenshtein distance)
  double similarityTo(String other) {
    if (isNullOrEmpty || other.isNullOrEmpty) return 0.0;
    if (this == other) return 1.0;
    
    final distance = _levenshteinDistance(this!, other);
    final maxLength = length > other.length ? length : other.length;
    
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Generate random string of specified length
  static String random(int length, {bool includeNumbers = true, bool includeSymbols = false}) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    var chars = letters;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;
    
    return List.generate(length, (index) => chars[DateTime.now().millisecondsSinceEpoch % chars.length])
        .join('');
  }

  /// Generate UUID v4
  static String generateUuid() {
    return '${random(8)}-${random(4)}-${random(4)}-${random(4)}-${random(12)}';
  }

  /// Check if string contains any of the substrings
  bool containsAny(List<String> substrings, {bool caseSensitive = true}) {
    if (isNullOrEmpty) return false;
    final searchStr = caseSensitive ? this! : this!.toLowerCase();
    
    for (final substring in substrings) {
      final searchSub = caseSensitive ? substring : substring.toLowerCase();
      if (searchStr.contains(searchSub)) return true;
    }
    
    return false;
  }

  /// Check if string starts with any of the prefixes
  bool startsWithAny(List<String> prefixes, {bool caseSensitive = true}) {
    if (isNullOrEmpty) return false;
    final searchStr = caseSensitive ? this! : this!.toLowerCase();
    
    for (final prefix in prefixes) {
      final searchPrefix = caseSensitive ? prefix : prefix.toLowerCase();
      if (searchStr.startsWith(searchPrefix)) return true;
    }
    
    return false;
  }

  /// Check if string ends with any of the suffixes
  bool endsWithAny(List<String> suffixes, {bool caseSensitive = true}) {
    if (isNullOrEmpty) return false;
    final searchStr = caseSensitive ? this! : this!.toLowerCase();
    
    for (final suffix in suffixes) {
      final searchSuffix = caseSensitive ? suffix : suffix.toLowerCase();
      if (searchStr.endsWith(searchSuffix)) return true;
    }
    
    return false;
  }

  /// Replace all occurrences of pattern with replacement
  String replaceAllMapped(Pattern pattern, String Function(Match) replace) {
    if (isNullOrEmpty) return this ?? '';
    return replaceAllMapped(pattern, replace);
  }
}
