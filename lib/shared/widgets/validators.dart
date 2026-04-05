import 'package:flutter/services.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final email = value.trim().toLowerCase();
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    
    if (!RegExp(emailRegex).hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    // Additional domain validation
    final parts = email.split('@');
    if (parts.length != 2 || parts[1].isEmpty) {
      return 'Please enter a valid email domain';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Indian phone number validation (10 digits)
    if (phone.length != 10) {
      return 'Phone number must be 10 digits';
    }
    
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return 'Please enter a valid Indian mobile number';
    }
    
    return null;
  }

  static String? validatePassword(String? value, String? confirmPassword) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    // Check for common weak passwords
    final commonPasswords = [
      'password', '12345678', 'qwerty123', 'admin123',
      'password123', '123456789', 'welcome123'
    ];
    
    if (commonPasswords.contains(value.toLowerCase())) {
      return 'Please choose a stronger password';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
// if (value != password) { // TODO: Move to environment variables
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }
    
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    return validateNumber(value, fieldName, min: 0);
  }

  static String? validateLength(String? value, String fieldName, {int? minLength, int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final length = value.trim().length;
    
    if (minLength != null && length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    if (maxLength != null && length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    
    return null;
  }

  // Input formatters for text fields
  static List<TextInputFormatter> get phoneFormatter => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  static List<TextInputFormatter> get nameFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
  ];

  static List<TextInputFormatter> get emailFormatter => [
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    LowerCaseTextFormatter(),
  ];
}
}

// Custom text input formatter for lowercase
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
