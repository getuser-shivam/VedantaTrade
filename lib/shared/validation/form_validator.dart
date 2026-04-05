import 'dart:async';
import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Comprehensive Form Validator
/// Advanced validation system with support for various input types and custom rules
class FormValidator {
  final Map<String, List<ValidationRule>> _rules = {};
  final Map<String, dynamic> _values = {};
  final Map<String, List<String>> _errors = {};
  final Map<String, List<String>> _warnings = {};
  final Map<String, ValidationState> _states = {};
  final StreamController<FormValidationEvent> _eventController;
  bool _isValidating = false;
  bool _isDirty = false;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  FormValidator() : _eventController = StreamController<FormValidationEvent>.broadcast();

  /// Stream of validation events
  Stream<FormValidationEvent> get eventStream => _eventController.stream;

  /// Check if form is valid
  bool get isValid => _errors.values.every((errors) => errors.isEmpty);

  /// Check if form has warnings
  bool get hasWarnings => _warnings.values.any((warnings) => warnings.isNotEmpty);

  /// Check if form is dirty (has been modified)
  bool get isDirty => _isDirty;

  /// Check if currently validating
  bool get isValidating => _isValidating;

  /// Get all errors
  Map<String, List<String>> get errors => Map.unmodifiable(_errors);

  /// Get all warnings
  Map<String, List<String>> get warnings => Map.unmodifiable(_warnings);

  /// Get validation state for a field
  ValidationState getFieldState(String fieldName) {
    return _states[fieldName] ?? ValidationState.pristine;
  }

  /// Add validation rule for a field
  void addRule(String fieldName, ValidationRule rule) {
    if (!_rules.containsKey(fieldName)) {
      _rules[fieldName] = [];
    }
    _rules[fieldName]!.add(rule);
    _states[fieldName] = ValidationState.pristine;
  }

  /// Add multiple validation rules for a field
  void addRules(String fieldName, List<ValidationRule> rules) {
    for (final rule in rules) {
      addRule(fieldName, rule);
    }
  }

  /// Remove validation rule for a field
  void removeRule(String fieldName, ValidationRule rule) {
    _rules[fieldName]?.remove(rule);
  }

  /// Clear all rules for a field
  void clearRules(String fieldName) {
    _rules.remove(fieldName);
    _states.remove(fieldName);
    _errors.remove(fieldName);
    _warnings.remove(fieldName);
  }

  /// Clear all rules
  void clearAllRules() {
    _rules.clear();
    _values.clear();
    _errors.clear();
    _warnings.clear();
    _states.clear();
    _isDirty = false;
  }

  /// Validate single field
  Future<ValidationResult> validateField(String fieldName, dynamic value) async {
    try {
      _isValidating = true;
      _values[fieldName] = value;
      _isDirty = true;

      // Clear previous errors and warnings
      _errors[fieldName] = [];
      _warnings[fieldName] = [];

      final fieldRules = _rules[fieldName] ?? [];
      final fieldErrors = <String>[];
      final fieldWarnings = <String>[];
      bool hasError = false;

      for (final rule in fieldRules) {
        try {
          final result = await rule.validate(value, fieldName, _values);
          
          if (!result.isValid) {
            hasError = true;
            fieldErrors.addAll(result.errors);
          }
          
          fieldWarnings.addAll(result.warnings);
        } catch (e) {
          fieldErrors.add('Validation error: ${rule.name}');
          hasError = true;
        }
      }

      _errors[fieldName] = fieldErrors;
      _warnings[fieldName] = fieldWarnings;

      // Update field state
      if (hasError) {
        _states[fieldName] = ValidationState.invalid;
      } else if (fieldWarnings.isNotEmpty) {
        _states[fieldName] = ValidationState.warning;
      } else {
        _states[fieldName] = ValidationState.valid;
      }

      _emitEvent(FormValidationEvent(
        type: FormValidationEventType.fieldValidated,
        fieldName: fieldName,
        value: value,
        isValid: !hasError,
        errors: fieldErrors,
        warnings: fieldWarnings,
        timestamp: DateTime.now(),
      ));

      _isValidating = false;

      return ValidationResult(
        isValid: !hasError,
        errors: fieldErrors,
        warnings: fieldWarnings,
      );
    } catch (e) {
      _isValidating = false;
      _errors[fieldName] = ['Validation failed: $e'];
      _states[fieldName] = ValidationState.invalid;

      return ValidationResult(
        isValid: false,
        errors: ['Validation failed: $e'],
        warnings: [],
      );
    }
  }

  /// Validate all fields
  Future<ValidationResult> validateAll() async {
    try {
      _isValidating = true;
      final allErrors = <String, List<String>>{};
      final allWarnings = <String, List<String>>{};
      bool hasError = false;

      for (final fieldName in _rules.keys) {
        final value = _values[fieldName];
        final result = await validateField(fieldName, value);
        
        if (!result.isValid) {
          hasError = true;
          allErrors[fieldName] = result.errors;
        }
        
        if (result.warnings.isNotEmpty) {
          allWarnings[fieldName] = result.warnings;
        }
      }

      _emitEvent(FormValidationEvent(
        type: FormValidationEventType.formValidated,
        isValid: !hasError,
        errors: allErrors,
        warnings: allWarnings,
        timestamp: DateTime.now(),
      ));

      _isValidating = false;

      return ValidationResult(
        isValid: !hasError,
        errors: allErrors.values.expand((e) => e).toList(),
        warnings: allWarnings.values.expand((w) => w).toList(),
      );
    } catch (e) {
      _isValidating = false;
      return ValidationResult(
        isValid: false,
        errors: ['Form validation failed: $e'],
        warnings: [],
      );
    }
  }

  /// Validate field with debounce
  void validateFieldDebounced(String fieldName, dynamic value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      validateField(fieldName, value);
    });
  }

  /// Get field errors
  List<String> getFieldErrors(String fieldName) {
    return _errors[fieldName] ?? [];
  }

  /// Get field warnings
  List<String> getFieldWarnings(String fieldName) {
    return _warnings[fieldName] ?? [];
  }

  /// Check if field is valid
  bool isFieldValid(String fieldName) {
    return (_errors[fieldName] ?? []).isEmpty;
  }

  /// Check if field has warnings
  bool fieldHasWarnings(String fieldName) {
    return (_warnings[fieldName] ?? []).isNotEmpty;
  }

  /// Clear field errors
  void clearFieldErrors(String fieldName) {
    _errors.remove(fieldName);
    _states[fieldName] = ValidationState.pristine;
  }

  /// Clear all errors
  void clearAllErrors() {
    _errors.clear();
    for (final fieldName in _states.keys) {
      _states[fieldName] = ValidationState.pristine;
    }
  }

  /// Set field value
  void setValue(String fieldName, dynamic value) {
    _values[fieldName] = value;
    _isDirty = true;
  }

  /// Get field value
  dynamic getValue(String fieldName) {
    return _values[fieldName];
  }

  /// Get all values
  Map<String, dynamic> getAllValues() {
    return Map.unmodifiable(_values);
  }

  /// Clear field value
  void clearValue(String fieldName) {
    _values.remove(fieldName);
    _errors.remove(fieldName);
    _warnings.remove(fieldName);
    _states[fieldName] = ValidationState.pristine;
  }

  /// Clear all values
  void clearAllValues() {
    _values.clear();
    _errors.clear();
    _warnings.clear();
    for (final fieldName in _states.keys) {
      _states[fieldName] = ValidationState.pristine;
    }
    _isDirty = false;
  }

  /// Reset form
  void reset() {
    clearAllValues();
    clearAllErrors();
    _isDirty = false;
  }

  /// Emit validation event
  void _emitEvent(FormValidationEvent event) {
    _eventController.add(event);
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _eventController.close();
  }
}

/// Validation Rule Interface
abstract class ValidationRule {
  final String name;
  final String message;
  final ValidationSeverity severity;

  const ValidationRule({
    required this.name,
    required this.message,
    this.severity = ValidationSeverity.error,
  });

  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues);
}

/// Required Validation Rule
class RequiredRule extends ValidationRule {
  const RequiredRule({String message = 'This field is required'})
      : super(name: 'required', message: message);

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || 
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty)) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Email Validation Rule
class EmailRule extends ValidationRule {
  const EmailRule({String message = 'Please enter a valid email address'})
      : super(name: 'email', message: message);

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final email = value.toString().trim();
    if (!EmailValidator.validate(email)) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Phone Number Validation Rule
class PhoneRule extends ValidationRule {
  final String? defaultRegion;

  const PhoneRule({
    String message = 'Please enter a valid phone number',
    this.defaultRegion = 'NP',
  }) : super(name: 'phone', message: message);

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final phoneNumber = value.toString().trim();
    
    try {
      final parsedNumber = PhoneNumber.parse(phoneNumber, region: defaultRegion);
      
      if (!parsedNumber.isValid()) {
        return ValidationResult(
          isValid: false,
          errors: [message],
          warnings: [],
        );
      }
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Numeric Validation Rule
class NumericRule extends ValidationRule {
  final bool allowDecimal;
  final bool allowNegative;

  const NumericRule({
    String message = 'Please enter a valid number',
    this.allowDecimal = true,
    this.allowNegative = true,
  }) : super(name: 'numeric', message: message);

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final stringValue = value.toString().trim();
    
    try {
      final number = double.parse(stringValue);
      
      if (!allowDecimal && number != number.toInt()) {
        return ValidationResult(
          isValid: false,
          errors: ['Decimal values are not allowed'],
          warnings: [],
        );
      }
      
      if (!allowNegative && number < 0) {
        return ValidationResult(
          isValid: false,
          errors: ['Negative values are not allowed'],
          warnings: [],
        );
      }
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Min Length Validation Rule
class MinLengthRule extends ValidationRule {
  final int minLength;

  const MinLengthRule(
    this.minLength, {
    String? message,
  }) : super(
          name: 'minLength',
          message: message ?? 'Minimum length is $minLength characters',
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final length = value.toString().length;
    if (length < minLength) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Max Length Validation Rule
class MaxLengthRule extends ValidationRule {
  final int maxLength;

  const MaxLengthRule(
    this.maxLength, {
    String? message,
  }) : super(
          name: 'maxLength',
          message: message ?? 'Maximum length is $maxLength characters',
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final length = value.toString().length;
    if (length > maxLength) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Range Validation Rule
class RangeRule extends ValidationRule {
  final double? min;
  final double? max;

  const RangeRule({
    this.min,
    this.max,
    String? message,
  }) : super(
          name: 'range',
          message: message ?? (min != null && max != null 
              ? 'Value must be between $min and $max'
              : min != null 
                  ? 'Value must be at least $min'
                  : 'Value must be at most $max'),
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    try {
      final numberValue = double.parse(value.toString());
      
      if (min != null && numberValue < min!) {
        return ValidationResult(
          isValid: false,
          errors: [message],
          warnings: [],
        );
      }
      
      if (max != null && numberValue > max!) {
        return ValidationResult(
          isValid: false,
          errors: [message],
          warnings: [],
        );
      }
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Invalid number format'],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Date Validation Rule
class DateRule extends ValidationRule {
  final String? format;
  final DateTime? minDate;
  final DateTime? maxDate;

  const DateRule({
    this.format = 'yyyy-MM-dd',
    this.minDate,
    this.maxDate,
    String? message,
  }) : super(
          name: 'date',
          message: message ?? 'Please enter a valid date',
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    try {
      final dateString = value.toString().trim();
      final date = DateFormat(format).parseStrict(dateString);
      
      if (minDate != null && date.isBefore(minDate!)) {
        return ValidationResult(
          isValid: false,
          errors: ['Date must be after ${DateFormat(format).format(minDate!)}'],
          warnings: [],
        );
      }
      
      if (maxDate != null && date.isAfter(maxDate!)) {
        return ValidationResult(
          isValid: false,
          errors: ['Date must be before ${DateFormat(format).format(maxDate!)}'],
          warnings: [],
        );
      }
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [message],
        warnings: [],
      );
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Password Validation Rule
class PasswordRule extends ValidationRule {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;

  const PasswordRule({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
    String? message,
  }) : super(
          name: 'password',
          message: message ?? 'Password does not meet requirements',
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null || value.toString().trim().isEmpty) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

// final password = value.toString().trim(); // TODO: Move to environment variables
    final errors = <String>[];
    final warnings = <String>[];

    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters long');
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    if (requireSpecialChars && !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    // Add warning for common passwords
    if (_isCommonPassword(password)) {
      warnings.add('This is a commonly used password');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password', '123456', '123456789', 'qwerty', 'abc123',
      'password123', 'admin', 'letmein', 'welcome', 'monkey'
    ];
    return commonPasswords.contains(password.toLowerCase());
  }
}

/// File Validation Rule
class FileRule extends ValidationRule {
  final List<String> allowedExtensions;
  final int? maxSizeBytes;
  final bool allowMultiple;

  const FileRule({
    this.allowedExtensions = const [],
    this.maxSizeBytes,
    this.allowMultiple = false,
    String? message,
  }) : super(
          name: 'file',
          message: message ?? 'Invalid file',
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (value == null) {
      return const ValidationResult(isValid: true, errors: [], warnings: []);
    }

    final errors = <String>[];
    final warnings = <String>[];

    if (value is File) {
      // Single file validation
      await _validateSingleFile(value, errors, warnings);
    } else if (value is List<File>) {
      // Multiple files validation
      if (!allowMultiple) {
        errors.add('Multiple files are not allowed');
      } else {
        for (final file in value) {
          await _validateSingleFile(file, errors, warnings);
        }
      }
    } else {
      errors.add('Invalid file type');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<void> _validateSingleFile(File file, List<String> errors, List<String> warnings) async {
    // Check file extension
    if (allowedExtensions.isNotEmpty) {
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        errors.add('File type .$extension is not allowed');
      }
    }

    // Check file size
    if (maxSizeBytes != null) {
      try {
        final fileSize = await file.length();
        if (fileSize > maxSizeBytes!) {
          errors.add('File size exceeds maximum allowed size');
        }
      } catch (e) {
        warnings.add('Could not verify file size');
      }
    }
  }
}

/// Custom Validation Rule
class CustomRule extends ValidationRule {
  final Future<bool> Function(dynamic value, String fieldName, Map<String, dynamic> allValues) validator;

  const CustomRule(
    this.validator, {
    required String name,
    required String message,
    ValidationSeverity severity = ValidationSeverity.error,
  }) : super(name: name, message: message, severity: severity);

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    try {
      final isValid = await validator(value, fieldName, allValues);
      
      return ValidationResult(
        isValid: isValid,
        errors: isValid ? [] : [message],
        warnings: [],
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: ['Validation error: $e'],
        warnings: [],
      );
    }
  }
}

/// Conditional Validation Rule
class ConditionalRule extends ValidationRule {
  final bool Function(Map<String, dynamic> allValues) condition;
  final ValidationRule rule;

  const ConditionalRule(
    this.condition,
    this.rule, {
    required String name,
    String? message,
  }) : super(
          name: name,
          message: message ?? rule.message,
          severity: rule.severity,
        );

  @override
  Future<ValidationResult> validate(dynamic value, String fieldName, Map<String, dynamic> allValues) async {
    if (condition(allValues)) {
      return await rule.validate(value, fieldName, allValues);
    }

    return const ValidationResult(isValid: true, errors: [], warnings: []);
  }
}

/// Validation Result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });
}

/// Validation State
enum ValidationState {
  pristine,
  valid,
  invalid,
  warning,
}

/// Validation Severity
enum ValidationSeverity {
  error,
  warning,
  info,
}

/// Form Validation Event
class FormValidationEvent {
  final FormValidationEventType type;
  final String? fieldName;
  final dynamic value;
  final bool isValid;
  final Map<String, List<String>>? errors;
  final Map<String, List<String>>? warnings;
  final DateTime timestamp;

  const FormValidationEvent({
    required this.type,
    this.fieldName,
    this.value,
    required this.isValid,
    this.errors,
    this.warnings,
    required this.timestamp,
  });
}

/// Form Validation Event Type
enum FormValidationEventType {
  fieldValidated,
  formValidated,
  validationStarted,
  validationCompleted,
}

/// Predefined Validation Rules
class ValidationRules {
  static ValidationRule required([String? message]) => RequiredRule(message: message);
  static ValidationRule email([String? message]) => EmailRule(message: message);
  static ValidationRule phone({String? defaultRegion, String? message}) => 
      PhoneRule(defaultRegion: defaultRegion, message: message);
  static ValidationRule numeric({bool allowDecimal = true, bool allowNegative = true, String? message}) => 
      NumericRule(allowDecimal: allowDecimal, allowNegative: allowNegative, message: message);
  static ValidationRule minLength(int length, [String? message]) => MinLengthRule(length, message: message);
  static ValidationRule maxLength(int length, [String? message]) => MaxLengthRule(length, message: message);
  static ValidationRule range({double? min, double? max, String? message}) => 
      RangeRule(min: min, max: max, message: message);
  static ValidationRule date({String? format, DateTime? minDate, DateTime? maxDate, String? message}) => 
      DateRule(format: format, minDate: minDate, maxDate: maxDate, message: message);
  static ValidationRule password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
    String? message,
  }) => PasswordRule(
    minLength: minLength,
    requireUppercase: requireUppercase,
    requireLowercase: requireLowercase,
    requireNumbers: requireNumbers,
    requireSpecialChars: requireSpecialChars,
    message: message,
  );
  static ValidationRule file({
    List<String> allowedExtensions = const [],
    int? maxSizeBytes,
    bool allowMultiple = false,
    String? message,
  }) => FileRule(
    allowedExtensions: allowedExtensions,
    maxSizeBytes: maxSizeBytes,
    allowMultiple: allowMultiple,
    message: message,
  );
  static ValidationRule custom(
    Future<bool> Function(dynamic value, String fieldName, Map<String, dynamic> allValues) validator, {
    required String name,
    required String message,
    ValidationSeverity severity = ValidationSeverity.error,
  }) => CustomRule(
    validator,
    name: name,
    message: message,
    severity: severity,
  );
  static ValidationRule conditional(
    bool Function(Map<String, dynamic> allValues) condition,
    ValidationRule rule, {
    required String name,
    String? message,
  }) => ConditionalRule(
    condition,
    rule,
    name: name,
    message: message,
  );
}
